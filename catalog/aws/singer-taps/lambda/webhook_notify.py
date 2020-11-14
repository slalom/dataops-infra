#!/usr/bin/python3.8

"""
This python file defines the lambda function for webhook notification.

Sample code from:
 - https://aws.amazon.com/premiumsupport/knowledge-center/sns-lambda-webhooks-chime-slack-teams/
"""

import json
import sys
import os

import urllib3

http = urllib3.PoolManager()


def lambda_handler(event, context):
    """[summary]

    Parameters
    ----------
    event : [type]
        [description]
    context : [type]
        [description]
    """
    msg = os.environ.get("ALERT_MESSAGE_TEXT", "(ERROR: No message found.)")
    url = os.environ.get("ALERT_WEBHOOK_URL", "(ERROR: No url found.)")
    post_to_webhook(msg, url)


def post_to_webhook(msg, url):
    """[summary]

    Parameters
    ----------
    msg : [type]
        [description]
    url : [type]
        [description]
    """
    json_msg_body = {"text": msg}
    encoded_msg = json.dumps(json_msg_body).encode("utf-8")
    resp = http.request("POST", url, body=encoded_msg)
    print(
        {"message": msg, "status_code": resp.status, "response": resp.data, "url": url}
    )


if __name__ == "__main__":
    try:
        url = sys.argv[0]
    except Exception:
        raise ValueError("Missing required 'webhook_url' argument.")
    post_to_webhook("This is a test.", url)
