import boto3
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)
sm_client = boto3.client("sagemaker")


def lambda_handler(event, context):
    """Retrieve transform job name from event and return transform job status."""
    model_name = event["ModelArn"].split("/")[-1]

    try:
        # Query boto3 API to check training status.
        response = sm_client.describe_training_job(TrainingJobName=model_name)
        logger.info(
            f"Training job:{model_name} has status:{response['TrainingJobStatus']}."
        )
    except Exception as e:
        response = (
            "Failed to read training status! "
            "The training job may not exist or the job name may be incorrect. "
            "Check SageMaker to confirm the job name."
        )
        print(e)
        print(f"{response} Attempted to read model name: {model_name}.")

    # We can't marshall datetime objects in JSON response. So convert
    # all datetime objects returned to unix time.
    for index, metric in enumerate(response["FinalMetricDataList"]):
        metric["Timestamp"] = metric["Timestamp"].timestamp()
    return {
        "statusCode": 200,
        "trainingMetrics": response["FinalMetricDataList"],
        "modelName": model_name,
    }
