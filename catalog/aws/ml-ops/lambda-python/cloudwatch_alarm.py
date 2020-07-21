""" This is to create an alarm when the model performance degrades"""

import boto3

model_name = "${var.job_name}"
client = boto3.client("cloudwatch")


def lambda_handler(event, context):

    client.put_metric_alarm(
        AlarmName="${var.alarm_name}",
        ComparisonOperator="${var.comparison_operator}",
        EvaluationPeriods="${var.eval_period}",
        DatapointsToAlarm="${var.datapoints_to_alarm}",
        MetricName="${var.metric_name}",
        Namespace=model_name,
        Period="${var.period}",
        Statistic="${var.statistic}",
        Threshold="${var.threshold}",
        ActionsEnabled="${var.actions_enable}",
        AlarmActions=["arn:aws:sns:us-east-1::Sagemaker-Notification-Emails"],
        AlarmDescription="${var.alarm_des}",
        Unit="${var.unit_name}",
    )
    return
