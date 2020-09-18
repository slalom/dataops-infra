"""
This function will send an email notification to users when the data drift monitor function return a non-complete execution status
"""

import boto3

sns = boto3.client("sns")


def lambda_handle(event, context):

    sns.publish(
        TopicArn="arn:aws:sns:${var.environment.aws_region}:Data drift detected",
        Subject="Data Drift Detected",
        Message=f"The latest data drift monitor status is {event['latest_result_status']}, model training is stopped. Please provide update datasets and restart the process. For more details, please follow this link to the latest report {event['report_uri']}",
    )
