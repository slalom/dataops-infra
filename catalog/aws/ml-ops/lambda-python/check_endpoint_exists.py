"""Check if SageMaker endpoint already exists and update the endpoint if it does. Otherwise create a new one."""
import boto3
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)
sm_client = boto3.client("sagemaker")


def lambda_handler(event, context):
    endpointConfig = event["EndpointConfigArn"].split("/")[-1]
        
    create_or_update = "Create"
    response = sm_client.list_endpoints()
    for i in response["Endpoints"]:
        if i["EndpointName"] == event["EndpointName"]:
            create_or_update = "Update"
    return {
        "statusCode": 200,
        "endpointName": event["EndpointName"],
        "endpointConfig": endpointConfig,
        "CreateOrUpdate": create_or_update,
    }
