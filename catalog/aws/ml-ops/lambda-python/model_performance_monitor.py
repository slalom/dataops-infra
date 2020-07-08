"""  This class implements a function to send evaluation metrics to CloudWatch using Boto3 """

import boto3

model_name = "${var.job_name}"
client = boto3.client('cloudwatch')


class CWEvalMetrics():
    # initialize the region and the model name with the class instantiation
    def __init__(self, region='us-east-1', model_name=model_name):
        self.region = region
        self.model_name = model_name

    # A function to send the training evaluation metrics
    # the metric_type parameters will determine whether the data sent is for training or validation.

    def CW_eval(self, model_name, is_training,  **kwargs):
        # collecting the loss and accuracy values
        #loss = kwargs.get('Loss', 0)
        accuracy = kwargs.get('Accuracy')
        f1 = kwargs.get('f1')
        auc = kwargs.get('auc')

        # determine if the passed values are for training or validation
        if is_training:
            metric_type = 'Training'
        else:
            metric_type = 'Validation'

        # Collecting the hyperparameters to be used as the metrics dimensions
        #hyperparameter = kwargs.get('hyperparameters')
        #optimizer = str(hyperparameter.get('optimizer'))
        #epochs = str(hyperparameter.get('epochs'))
        #learning_rate = str(hyperparameter.get('learning_rate'))

        response = client.put_metric_data(
            Namespace='/aws/sagemaker/' + model_name,
            MetricData=[
                {
                    'MetricName': metric_type + ' Accuracy',
                    'Value': accuracy,
                    'Unit': "Percent",
                    'StorageResolution': 1
                },
                {
                    'MetricName': metric_type + ' f1',
                    'Value': f1,
                    'Unit': "Percent",
                    'StorageResolution': 1
                },
                {
                    'MetricName': metric_type + ' auc',
                    'Value': auc,
                    'Unit': "Percent",
                    'StorageResolution': 1
                }
            ]
        )
        return response


def performance_watch():
    measure = CWEvalMetrics()
    response = measure.CW_eval(model_name=model_name, is_training=True)
    return response


def lambda_handler(event, context):
    response = performance_watch()
    return {
        'performance evaluation results': response
    }


def main():
    """ Main function """
    return performance_watch()


if __name__ == "__main__":
    main()
