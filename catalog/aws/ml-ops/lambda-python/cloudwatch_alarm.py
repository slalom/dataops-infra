""" This is to create an alarm when the model performance degrades"""

import boto3

model_name = "${var.job_name}"
client = boto3.client("cloudwatch")
retraining = "${var.retrain_on_alarm}"


def lambda_handler(event, context):

    response = retraining

    alarm = client.put_metric_alarm(
        AlarmName="${var.alarm_name}",
        ComparisonOperator="${var.alarm_comparison_operator}",
        EvaluationPeriods="${var.alarm_evaluation_period}",
        DatapointsToAlarm="${var.alarm_datapoints_to_evaluate}",
        MetricName="${var.alarm_metric_name}",
        Namespace=model_name,
        Period="${var.alarm_metric_evaluation_period}",
        Statistic="${var.alarm_statistic}",
        Threshold="${var.alarm_threshold}",
        ActionsEnabled="${var.alarm_actions_enabled}",
        AlarmActions=["arn:aws:sns:::Sagemaker-Notification-Emails"],
        AlarmDescription="${var.alarm_description}",
        Unit="${var.alarm_statistic_unit_name}",
    )

    return {response, alarm}
