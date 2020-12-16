"""Execute the step function training and deployment pipeline triggered by new training data landing in S3."""
import boto3
import os

state_machine_arn = os.environ["state_machine_arn"]
client = boto3.client("stepfunctions")


def lambda_handler(event, context):
    """Execute ML State Machine when new training data is uploaded to S3."""

    client.start_execution(stateMachineArn=state_machine_arn, input=str(event))

    return {"statusCode": 200}
