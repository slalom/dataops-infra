import boto3
import os

state_machine_arn = os.environ['state_machine_arn']
client = boto3.client('stepfunctions')

def lambda_handler(event, context):
    """Execute ML State Machine when new training data is uploaded to S3."""
    
    client.start_execution(stateMachineArn=state_machine_arn)
    
    return {
        "statusCode": 200
    }
