"""Renames the output CSV from batch inference to replace the existing output data and automatically update the connection to Tableau (via Athena)."""
import json
import boto3

s3_resource = boto3.resource('s3')


def lambda_handler(event, context):

    event = event["Payload"]

    # Copy csv.out as .csv
    s3_resource.Object(event["BucketName"], event["Path"]+"/out.csv").copy_from(
        CopySource=event["BucketName"]+"/"+event["Path"]+"/test.csv.out")
    # Delete the former .csv.out
    s3_resource.Object(event["BucketName"],
                       event["Path"]+"/test.csv.out").delete()

    return {
        'statusCode': 200,
    }
