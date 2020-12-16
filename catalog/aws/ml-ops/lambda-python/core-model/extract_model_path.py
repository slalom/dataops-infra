"""Return the name and path of the best model from the hyperparameter tuning job."""


def lambda_handler(event, context):
    print(event)
    return {
        "HyperParameterTuningJobName": event["HyperParameterTuningJobName"],
        "bestTrainingJobName": event["BestTrainingJob"]["TrainingJobName"],
        "modelDataUrl": event["TrainingJobDefinition"]["OutputDataConfig"][
            "S3OutputPath"
        ]
        + "/"
        + event["BestTrainingJob"]["TrainingJobName"]
        + "/output/model.tar.gz",
    }
