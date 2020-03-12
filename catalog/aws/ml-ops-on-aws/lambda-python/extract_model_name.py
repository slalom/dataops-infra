def lambda_handler(event, context):
    if "ModelArn" in event:
        model_name = event["ModelArn"].split("/")[-1]
    else:
        model_name = event["EndpointConfigArn"].split("/")[-1]
    return {"modelName": model_name}

