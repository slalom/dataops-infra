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


def lambda_handler(event: dict, context: dict) -> None:
    """
    Responds to AWS lambda trigger.

    Parameters
    ----------
    event : [type]
        The event payload that was submitted to the Lambda function.
    context : [type]
        A LambdaContext object:
         - https://docs.aws.amazon.com/lambda/latest/dg/python-context.html
    """
    msg, url = None, None
    if "MESSAGE_TEXT" in event:
        msg = str(event.pop("MESSAGE_TEXT"))
    if "WEBHOOK_URL" in event:
        url = str(event.pop("WEBHOOK_URL"))
    if url and msg:
        post_to_webhook(msg, url, payload=event)


def post_to_webhook(msg: str, url: str, payload=None) -> None:
    """Post to the webhook.

    Parameters
    ----------
    msg : [str]
        The message text to post.
    url : [str]
        The webhook URL.
    payload : [dict]
        Optional. Additional key-value pairs to attach to the message.
    """
    if payload:
        msg += "\n\n\n - "
        msg += "\n\n - ".join([f"**{k}**: {v}" for k, v in payload.items()])
    json_msg_body = {"text": msg}
    encoded_msg = json.dumps(json_msg_body).encode("utf-8")
    print({"message": msg, "url": url, "payload": payload})
    resp = http.request("POST", url, body=encoded_msg)
    print(
        {"message": msg, "url": url, "status_code": resp.status, "response": resp.data}
    )


if __name__ == "__main__":
    try:
        url = sys.argv[1]
    except Exception:
        raise ValueError("Missing required positional argument 'webhook_url'.")
    post_to_webhook(
        "This is a test.", url, {"something": "http://slalom.com", "else": "here"}
    )
