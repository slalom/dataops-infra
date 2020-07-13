""" This is to create an alarm when the model performance degrades"""

import boto3

model_name = "${var.job_name}"
client = boto3.client('cloudwatch')


def lambda_handler(event, context):
    namespace = '/aws/sagemaker/' + model_name
    client.put_metric_alarm(
        AlarmName='Overfitting Alarm',
        ComparisonOperator='LessThanOrEqualToThreshold',
        EvaluationPeriods=10,
        DatapointsToAlarm=10,
        MetricName='Training Accuracy',
        Namespace=namespace,
        Period=30,
        Statistic='Maximum',
        Threshold=90.0,
        ActionsEnabled=True,
        AlarmActions=[
            'arn:aws:sns:us-east-1::Sagemaker-Notification-Emails',
        ],
        AlarmDescription='Alarm when the model is Overfitting',
        Unit='Percent'
    )
    return
