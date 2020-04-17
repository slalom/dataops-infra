import json
import boto3

client = boto3.client('glue')


def lambda_handler(event, context):

    event = event["Payload"]

    client.start_crawler(Name=event['CrawlerName'])

    return {
        'statusCode': 200,
    }
