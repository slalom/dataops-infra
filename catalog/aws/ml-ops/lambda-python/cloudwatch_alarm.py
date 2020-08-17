""" This is to create an alarm when the model performance degrades"""

import boto3

model_name = "${var.job_name}"
client = boto3.client("cloudwatch")
retraining = "${var.enable_retrain"


def lambda_handler(event, context):

    response = retraining

    alarm = client.put_metric_alarm(
        AlarmName="${var.alarm_name}",
        ComparisonOperator="${var.comparison_operator}",
        EvaluationPeriods="${var.evaluation_period}",
        DatapointsToAlarm="${var.datapoints_to_evaluate}",
        MetricName="${var.metric_name}",
        Namespace=model_name,
        Period="${var.alarm_metric_evaluation_period}",
        Statistic="${var.statistic}",
        Threshold="${var.threshold}",
        ActionsEnabled="${var.actions_enable}",
        AlarmActions=["arn:aws:sns:::Sagemaker-Notification-Emails"],
        AlarmDescription="${var.alarm_des}",
        Unit="${var.unit_name}",
    )

    return {response, alarm}
