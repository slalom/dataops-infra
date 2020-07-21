import os
import json
import pickle
import sys
import traceback

from sagemaker.tensorflow import TensorFlow

prefix = "/opt/ml/"

input_path = prefix + "input/data"
hyperparams_path = prefix + "input/config/hyperparameters.json"
output_path = os.path.join(prefix, "output")
model_path = os.path.join(prefix, "model")

hvd_instance_type = "ml.m5.4xlarge"
hvd_processes_per_host = 1
hvd_instance_count = 4

distributions = {
    "mpi": {
        "enabled": True,
        "processes_per_host": hvd_processes_per_host,
        "custom_mpi_options": "-verbose --NCCL_DEBUG=INFO -x OMPI_MCA_btl_vader_single_copy_mechanism=none",
    }
}

remote_inputs = {
    "train": input_path + "/train",
    "validation": input_path + "/validate",
    "eval": input_path + "/test",
}

# The function to execute the training.
def train():
    print("Starting the training.")
    try:

        # Read the hyperparameter config json file
        with open(hyperparams_path) as _in_file:
            hyperparams_dict = json.load(_in_file)

        # Usually max_delta_step is not needed, but it might help in logistic regression when class is extremely imbalanced.
        params = {
            # hyperparameters
            "learning_rate": float(hyperparams_dict["learning_rate"]),
            "epochs": int(hyperparams_dict["epochs"]),
            "batch-size": float(hyperparams_dict["batch-size"]),
            "activation": float(hyperparams_dict["activation"]),
            "loss_fn": float(hyperparams_dict["loss_fn"]),
        }

        estimator_hvd = TensorFlow(
            source_dir="source",
            entry_point="train_horovod.py",
            model_dir=model_path,
            base_job_name="sagemaker-horovod",
            hyperparameters=params,
            framework_version="1.14",
            py_version="py3",
            train_instance_count=hvd_instance_count,
            train_instance_type=hvd_instance_type,
            distributions=distributions,
        )

        # train model on whole dataset
        estimator_hvd.fit(remote_inputs)

        # save the model
        with open(os.path.join(model_path, "resnet18-model.pkl"), "wb") as out:
            pickle.dump(estimator_hvd, out, protocol=0)
            print("Training complete.")

    except Exception as e:
        # Write out an error file. This will be returned as the failureReason in the
        # DescribeTrainingJob result.
        trc = traceback.format_exc()
        with open(os.path.join(output_path, "failure"), "w") as s:
            s.write("Exception during training: " + str(e) + "\n" + trc)
        # Printing this causes the exception to be in the training job logs, as well.
        print("Exception during training: " + str(e) + "\n" + trc, file=sys.stderr)
        # A non-zero exit code causes the training job to be marked as Failed.
        sys.exit(255)


if __name__ == "__main__":
    train()

    # A zero exit code causes the job to be marked a Succeeded.
    sys.exit(0)
