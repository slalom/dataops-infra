import os
import subprocess
import sys
import logging
import datetime
import argparse
import dataset
import model_def
import s3_utils
import json

import tensorflow as tf
from tensorflow.keras import backend as K
from tensorflow.keras.callbacks import (
    ModelCheckpoint,
    LearningRateScheduler,
    TensorBoard,
    EarlyStopping,
    CSVLogger,
)
import numpy as np

print("Tensorflow version ", tf.__version__)
logging.getLogger().setLevel(logging.INFO)

prefix = "/opt/ml/"
bucket = "s3://${aws_s3_bucket.ml_bucket.id}/"
hyperparams_path = prefix + "input/config/hyperparameters.json"


class CustomTensorBoardCallback(TensorBoard):
    def on_batch_end(self, batch, logs=None):
        pass


def main(args):
    # Read the hyperparameter config json file
    with open(hyperparams_path) as _in_file:
        hyperparams_dict = json.load(_in_file)

    epochs = int(hyperparams_dict["epochs"])
    learning_rate = float(hyperparams_dict["learning_rate"])
    curr_dt = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    strategy = tf.distribute.MirroredStrategy()
    batch_size = float(hyperparams_dict["batch-size"]) * strategy.num_replicas_in_sync
    model_dir = bucket + args.model_name + curr_dt

    gpus = tf.config.experimental.list_physical_devices("GPU")
    if gpus:
        try:
            # Currently, memory growth needs to be the same across GPUs
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
            logical_gpus = tf.config.experimental.list_logical_devices("GPU")
            print(len(gpus), "Physical GPUs,", len(logical_gpus), "Logical GPUs")
        except RuntimeError as e:
            # Memory growth must be set before GPUs have been initialized
            print(e)

    nb_train_samples = sum([len(files) for r, d, files in os.walk(args.train)])
    nb_validation_samples = sum(
        [len(files) for r, d, files in os.walk(args.validation)]
    )
    nb_test_samples = sum([len(files) for r, d, files in os.walk(args.eval)])
    logging.info("Number of training samples={}".format(nb_train_samples))

    train_data_generator = dataset.read_dataset(
        args.train, batch_size=batch_size, train_mode=True
    )
    validation_data_generator = dataset.read_dataset(
        args.validation, batch_size=batch_size, train_mode=False
    )
    test_data_generator = dataset.read_dataset(
        args.eval, batch_size=batch_size, train_mode=False
    )

    tensorboard_cb = CustomTensorBoardCallback(
        log_dir=model_dir + "/tensorboard/" + curr_dt
    )
    checkpoints_cb = ModelCheckpoint(
        filepath=os.path.join(model_dir + "/training_checkpoints", "ckpt_{epoch}"),
        save_weights_only=True,
    )
    callbacks = [tensorboard_cb, checkpoints_cb]

    logging.info("Configuring model")
    with strategy.scope():
        model = model_def.transfer_learning_model(
            dropout=args.dropout,
            model_name=args.model_name,
            learning_rate=learning_rate,
        )

    logging.info("Starting training")
    history = model.fit(
        train_data_generator,
        steps_per_epoch=nb_train_samples // batch_size,
        epochs=epochs,
        validation_data=validation_data_generator,
        validation_steps=nb_validation_samples // batch_size,
        callbacks=callbacks,
        verbose=1,
    )

    loss, acc, auc = tuple(
        model.evaluate(
            test_data_generator, steps=nb_test_samples // batch_size, verbose=1
        )
    )

    print("Model {} with dropout {} had loss {} and acc {}", model_name, j, loss, acc)
    export_path = tf.saved_model.save(
        model, bucket + model_name + "/keras_export_" + curr_dt
    )
    print("Model exported to: ", export_path)


if __name__ == "__main__":
    os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
    os.environ["S3_REQUEST_TIMEOUT_MSEC"] = "86400"

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--train", type=str, required=False, default=os.environ.get("SM_CHANNEL_TRAIN")
    )
    parser.add_argument(
        "--validation",
        type=str,
        required=False,
        default=os.environ.get("SM_CHANNEL_VALIDATION"),
    )
    parser.add_argument(
        "--eval", type=str, required=False, default=os.environ.get("SM_CHANNEL_EVAL")
    )
    parser.add_argument(
        "--data-config", type=json.loads, default=os.environ.get("SM_INPUT_DATA_CONFIG")
    )
    parser.add_argument(
        "--fw-params", type=json.loads, default=os.environ.get("SM_FRAMEWORK_PARAMS")
    )
    parser.add_argument(
        "--model_dir",
        type=str,
        required=True,
        help="The directory where the model will be stored.",
    )
    parser.add_argument("--model_name", type=str, default="ResNet50")
    parser.add_argument(
        "--dropout", type=float, default=0.2, help="Weight decay for convolutions."
    )
    parser.add_argument(
        "--learning_rate", type=float, default=0.001, help="Initial learning rate."
    )
    parser.add_argument("--epochs", type=int, default=6)
    parser.add_argument("--batch-size", type=int, default=25)

    args = parser.parse_args()

    main(args)
