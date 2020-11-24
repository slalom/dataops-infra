"""  This class implements a function to send evaluation metrics to CloudWatch using Boto3 """

import boto3

modelname = "${var.job_name}"
client = boto3.client("cloudwatch")


class CWEvalMetrics:
    # initialize the region and the model name with the class instantiation
    def __init__(self, region="${var.environment.aws_region}", model_name=modelname):
        self.region = region
        self.model_name = model_name

    # A function to send the training evaluation metrics
    # the metric_type parameters will determine whether the data sent is for training or validation.

    def CW_eval(self, is_training, **kwargs):
        # collecting the loss and accuracy values
        # loss = kwargs.get('Loss', 0)
        accuracy = kwargs.get("Accuracy")
        f1 = kwargs.get("f1")
        auc = kwargs.get("auc")

        # determine if the passed values are for training or validation
        if is_training:
            metric_type = "Training"
        else:
            metric_type = "Validation"

        # Collecting the hyperparameters to be used as the metrics dimensions
        # hyperparameter = kwargs.get('hyperparameters')
        # optimizer = str(hyperparameter.get('optimizer'))
        # epochs = str(hyperparameter.get('epochs'))
        # learning_rate = str(hyperparameter.get('learning_rate'))

        response = client.put_metric_data(
            MetricData=[
                {
                    "MetricName": f"{metric_type} Accuracy",
                    "Value": f"{accuracy}",
                    "Unit": "Percent",
                    "StorageResolution": 1,
                },
                {
                    "MetricName": f"{metric_type} f1",
                    "Value": f"{f1}",
                    "Unit": "Percent",
                    "StorageResolution": 1,
                },
                {
                    "MetricName": f"{metric_type} auc",
                    "Value": f"{auc}",
                    "Unit": "Percent",
                    "StorageResolution": 1,
                },
            ],
        )
        return response


def performance_watch():
    measure = CWEvalMetrics()
    response = measure.CW_eval(model_name=modelname, is_training=True)
    return response


def lambda_handler(event, context):
    response = performance_watch()
    return {"performance evaluation results": response}


def main():
    """ Main function """
    return performance_watch()


if __name__ == "__main__":
    main()
