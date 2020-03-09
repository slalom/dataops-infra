import boto3
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)
sm_client = boto3.client("sagemaker")


def lambda_handler(event, context):

    create_or_update = "Create"

    response = sm_client.list_endpoints()

    for i in response["Endpoints"]:
        if i["EndpointName"] == event["EndpointName"]:
            create_or_update = "Update"

    return {
        "statusCode": 200,
        "endpointName": event["EndpointName"],
        "endpointConfig": event["EndpointConfig"],
        "CreateOrUpdate": create_or_update,
    }
