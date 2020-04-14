/*
* This module automates MLOps tasks associated with training Machine Learning models.
*
* The module leverages Step Functions and Lambda functions as needed. The state machine
* executes hyperparameter tuning, training, and deployments as needed. Deployment options
* supported are Sagemaker endpoints and/or batch inference.
*/


data "null_data_source" "endpoint_or_batch_transform" {
  inputs = {
    # State machine input for creating or updating an inference endpoint
    endpoint = <<EOF
"Create Model Endpoint Config": {
    "Resource": "arn:aws:states:::sagemaker:createEndpointConfig",
    "Parameters": {
      "EndpointConfigName.$": "$.modelName",
      "ProductionVariants": [
        {
          "InitialInstanceCount": ${var.endpoint_instance_count},
          "InstanceType": "${var.endpoint_instance_type}",
          "ModelName.$": "$.modelName",
          "VariantName": "AllTraffic"
        }
      ]
    },
    "Type": "Task",
    "Next": "Check Endpoint Exists"
  },
  "Check Endpoint Exists": {
    "Resource": "${module.lambda_functions.function_ids["CheckEndpointExists"]}",
    "Parameters": {
      "EndpointConfigName.$": "$.endpointConfig",
      "EndpointName": "${var.endpoint_name}"
    },
    "Type": "Task",
    "Next": "Create or Update Endpoint"
  },
  "Create or Update Endpoint": {
    "Type": "Choice",
    "Choices": [
      {
        "Variable": "$['CreateOrUpdate']",
        "StringEquals": "Update",
        "Next": "Update Existing Model Endpoint"
      }
    ],
    "Default": "Create New Model Endpoint"
  },
  "Create New Model Endpoint": {
    "Resource": "arn:aws:states:::sagemaker:createEndpoint",
    "Parameters": {
      "EndpointConfigName.$": "$.endpointConfig",
      "EndpointName.$": "$.endpointName"
    },
    "Type": "Task",
    "End": true
  },
  "Update Existing Model Endpoint": {
    "Resource": "arn:aws:states:::sagemaker:updateEndpoint",
    "Parameters": {
      "EndpointConfigName.$": "$.endpointConfig",
      "EndpointName.$": "$.endpointName"
    },
    "Type": "Task",
    "End": true
  }
EOF
    # State machine input for batch transformation
    batch_transform = <<EOF
"Batch Transform": {
    "Type": "Task",
    "Resource": "arn:aws:states:::sagemaker:createTransformJob.sync",
    "Parameters": {
      "ModelName.$": "$.modelName",
      "TransformInput": {
        "CompressionType": "None",
        "ContentType": "text/csv",
        "DataSource": {
          "S3DataSource": {
            "S3DataType": "S3Prefix",
            "S3Uri": "s3://${aws_s3_bucket.extracts_store.id}/${var.model_name}/data/score/score.csv"
          }
        }
      },
      "TransformOutput": {
        "S3OutputPath": "s3://${aws_s3_bucket.output_store.id}/${var.model_name}/batch-transform-output"
      },
      "TransformResources": {
        "InstanceCount": ${var.batch_transform_instance_count},
        "InstanceType": "${var.batch_transform_instance_type}"
      },
      "TransformJobName.$": "$.modelName"
    },
    "Next": "Rename Batch Transform Output"
    },
"Rename Batch Transform Output": {
  "Type": "Task",
  "Resource": "${module.lambda_functions.function_ids["RenameBatchOutput"]}",
  "Parameters": {
    "Payload": {
      "BucketName": "${aws_s3_bucket.output_store.id}",
      "Path": "${var.model_name}/batch-transform-output"
    }
  },
  "Next": "Run Glue Crawler"
    },
    "Run Glue Crawler": {
      "Type": "Task",
      "Resource": "${module.lambda_functions.function_ids["RunGlueCrawler"]}",
      "Parameters": {
        "Payload": {
          "CrawlerName": "${module.glue_crawler.glue_crawler_name}"
        }
      },
      "End": true
    }
EOF
  }
}

module "step-functions" {
  #source                  = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source                   = "../../../components/aws/step-functions"
  name_prefix              = var.name_prefix
  feature_store_bucket     = var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id
  extracts_store_bucket    = aws_s3_bucket.extracts_store.id
  model_store_bucket       = aws_s3_bucket.model_store.id
  output_store_bucket      = aws_s3_bucket.output_store.id
  environment              = var.environment
  resource_tags            = var.resource_tags
  lambda_functions         = module.lambda_functions.function_ids
  state_machine_definition = <<EOF
{
 "StartAt": "Glue Data Transformation",
  "States": {
    "Glue Data Transformation": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "${module.glue_job.glue_job_name}",
        "Arguments": {
          "--extra-py-files": "s3://${aws_s3_bucket.source_repository.id}/${var.model_name}/glue/python/pandasmodule-0.1-py3-none-any.whl",
          "--S3_SOURCE": "${var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id}",
          "--S3_DEST": "${aws_s3_bucket.extracts_store.id}",
          "--TRAIN_KEY": "${var.model_name}/data/train/train.csv",
          "--SCORE_KEY": "${var.model_name}/data/score/score.csv"
        }
      },
      "Next": "Generate Unique Job Name"
    },
    "Generate Unique Job Name": {
      "Resource": "${module.lambda_functions.function_ids["UniqueJobName"]}",
      "Parameters": {
        "JobName": "${var.model_name}"
      },
      "Type": "Task",
      "Next": "Hyperparameter Tuning"
    },
    "Hyperparameter Tuning": {
      "Resource": "arn:aws:states:::sagemaker:createHyperParameterTuningJob.sync",
      "Parameters": {
        "HyperParameterTuningJobName.$": "$.JobName",
        "HyperParameterTuningJobConfig": {
          "Strategy": "Bayesian",
          "HyperParameterTuningJobObjective": {
            "Type": "${var.tuning_objective}",
            "MetricName": "${var.tuning_metric}"
          },
          "ResourceLimits": {
            "MaxNumberOfTrainingJobs": ${tostring(var.max_number_training_jobs)},
            "MaxParallelTrainingJobs": ${tostring(var.max_parallel_training_jobs)}
          },
          "ParameterRanges": ${jsonencode(var.parameter_ranges)}
        },
        "TrainingJobDefinition": {
          "AlgorithmSpecification": {
            "MetricDefinitions": [
              {
                "Name": "${var.tuning_metric}",
                "Regex": "${var.tuning_metric}: ([0-9\\.]+)"
              }
            ],
            "TrainingImage": "${var.training_image_override != null ? var.training_image_override : module.ecr_image_byo_model.ecr_image_url_and_tag}",
            "TrainingInputMode": "File"
          },
          "OutputDataConfig": {
            "S3OutputPath": "s3://${aws_s3_bucket.model_store.id}/${var.model_name}/models"
          },
          "StoppingCondition": {
            "MaxRuntimeInSeconds": 86400
          },
          "ResourceConfig": {
            "InstanceCount": ${var.training_job_instance_count},
            "InstanceType": "${var.training_job_instance_type}",
            "VolumeSizeInGB": ${var.training_job_volume_size_gb}
          },
          "RoleArn": "${module.step-functions.iam_role_arn}",
          "InputDataConfig": [
            {
              "DataSource": {
                "S3DataSource": {
                  "S3DataDistributionType": "FullyReplicated",
                  "S3DataType": "S3Prefix",
                  "S3Uri": "s3://${aws_s3_bucket.extracts_store.id}/${var.model_name}/data/train/train.csv"
                }
              },
              "ChannelName": "train",
              "ContentType": "csv"
            }
          ],
          "StaticHyperParameters": ${jsonencode(var.static_hyperparameters)}
        }
      },
      "Type": "Task",
      "Next": "Extract Best Model Path"
    },
    "Extract Best Model Path": {
      "Resource": "${module.lambda_functions.function_ids["ExtractModelPath"]}",
      "Type": "Task",
      "Next": "Save Best Model"
    },
    "Save Best Model": {
      "Parameters": {
        "PrimaryContainer": {
          "Image": "${var.training_image_override != null ? var.training_image_override : module.ecr_image_byo_model.ecr_image_url_and_tag}",
          "Environment": {},
          "ModelDataUrl.$": "$.modelDataUrl"
        },
        "ExecutionRoleArn": "${module.step-functions.iam_role_arn}",
        "ModelName.$": "$.bestTrainingJobName"
      },
      "Resource": "arn:aws:states:::sagemaker:createModel",
      "Type": "Task",
      "Next": "Query Training Results"
    },
    "Query Training Results": {
      "Resource": "${module.lambda_functions.function_ids["QueryTrainingStatus"]}",
      "Type": "Task",
      "Next": "Inference Rule"
    },
    "Inference Rule": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$['trainingMetrics'][0]['Value']",
          "${var.inference_comparison_operator}": ${var.inference_metric_threshold},
          "Next": "${var.endpoint_or_batch_transform}"
        }
      ],
      "Default": "Model Accuracy Too Low"
    },
    "Model Accuracy Too Low": {
      "Comment": "Validation accuracy lower than threshold",
      "Type": "Fail"
    },
    ${var.endpoint_or_batch_transform == "Create Model Endpoint Config" ? data.null_data_source.endpoint_or_batch_transform.outputs["endpoint"] : data.null_data_source.endpoint_or_batch_transform.outputs["batch_transform"]}
  }
}
EOF
}