def lambda_handler(event, context):
    print(event)
    return {
        "bestTrainingJobName": event["BestTrainingJob"]["TrainingJobName"],
        "modelDataUrl": event["TrainingJobDefinition"]["OutputDataConfig"][
            "S3OutputPath"
        ]
        + "/"
        + event["BestTrainingJob"]["TrainingJobName"]
        + "/output/model.tar.gz",
    }

