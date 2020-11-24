"""Crawls CSV output file from batch inference to create a Glue table which can be connected to Tableau (via Athena)."""
import json
import boto3

client = boto3.client('glue')


def lambda_handler(event, context):

    event = event["Payload"]

    client.start_crawler(Name=event['CrawlerName'])

    return {
        'statusCode': 200,
    }
