"""
This function will stop the model training
"""
import json
import boto3

Job = "${var.job_name}"


def lambda_handler(event, context):

    # stop the training job if overfitting is detected
    client = boto3.client("sagemaker")
    response = client.stop_training_job(TrainingJobName=Job)

    return response
