/*
* This module automates MLOps tasks associated with training Machine Learning models.
*
* The module leverages Step Functions and Lambda functions as needed. The state machine
* executes hyperparameter tuning, training, and deployments as needed. Deployment options
* supported are Sagemaker endpoints and/or batch inference.
*/


locals {
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
      "EndpointConfigArn.$": "$.EndpointConfigArn",
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
        "ContentType": "${var.content_type}",
        "CompressionType": "None",
        "DataSource": {
          "S3DataSource": {
            "S3DataType": "S3Prefix",
            "S3Uri": "s3://${aws_s3_bucket.data_store.id}/${var.test_key}",
            "S3DataDistributionType": "FullyReplicated",
          }
        }
      },
      "TransformOutput": {
        "S3OutputPath": "s3://${aws_s3_bucket.data_store.id}/batch-transform-output"
      },
      "TransformResources": {
        "InstanceCount": "${var.batch_transform_instance_count}",
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
      "BucketName": "${aws_s3_bucket.data_store.id}",
      "Path": "batch-transform-output"
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

module "ecr_image" {
  source               = "../../../components/aws/ecr-image"
  name_prefix          = var.name_prefix
  environment          = var.environment
  resource_tags        = var.resource_tags
  aws_credentials_file = var.aws_credentials_file

  repository_name   = var.repo_name
  source_image_path = var.source_image_path
  tag               = var.ecr_tag_name
}

module "postgres" {
  source        = "../../../catalog/aws/postgres"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  postgres_version = var.db_version
  database_name    = var.dbname

  admin_username = var.db_admin_name
  admin_password = var.db_passwd

  storage_size_in_gb = var.storage_size_in_gb
  instance_class     = var.instance_class
}

module "step-functions" {
  #source                  = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=main"
  source        = "../../../components/aws/step-functions"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  lambda_functions = module.lambda_functions.function_ids
  writeable_buckets = [
    var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id,
    aws_s3_bucket.data_store.id,
    aws_s3_bucket.model_store.id
  ]

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
          "--extra-py-files": "s3://${aws_s3_bucket.source_repository.id}/glue/python/pandasmodule-0.1-py3-none-any.whl",
          "--S3_SOURCE": "${var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id}",
          "--S3_DEST": "${aws_s3_bucket.data_store.id}",
          "--TRAIN_KEY": "${var.train_key}",
          "--VALIDATION_KEY": "${var.validate_key}",
          "--SCORE_KEY": "${var.test_key}",
          "--INFERENCE_TYPE": "${var.endpoint_or_batch_transform == "Create Model Endpoint Config" ? "endpoint" : "batch"}"
        }
      },
      "Next": "Generate Unique Job Name"
    },
    "Generate Unique Job Name": {
      "Resource": "${module.lambda_functions.function_ids["UniqueJobName"]}",
      "Parameters": {
        "JobName": "${var.job_name}"
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
            "TrainingImage": "${var.built_in_model_image != null ? var.built_in_model_image : module.ecr_image_byo_model.ecr_image_url_and_tag}",
            "TrainingInputMode": "File"
          },
          "OutputDataConfig": {
            "S3OutputPath": "s3://${aws_s3_bucket.model_store.id}/models"
          },
          "StoppingCondition": {
            "MaxRuntimeInSeconds": 86400
          },
          "ResourceConfig": {
            "InstanceCount": ${var.training_job_instance_count},
            "InstanceType": "${var.training_job_instance_type}",
            "VolumeSizeInGB": ${var.training_job_storage_in_gb}
          },
          "RoleArn": "${module.step-functions.iam_role_arn}",
          "InputDataConfig": [
            {
              "ChannelName": "train",
              "DataSource": {
                "S3DataSource": {
                  "S3DataType": "S3Prefix",
                  "S3Uri": "s3://${aws_s3_bucket.data_store.id}/${var.train_key}",
                  "S3DataDistributionType": "FullyReplicated"
                }
              }, 
              "ContentType": "${var.content_type}",
              "CompressionType": "None"
            },
            {
              "ChannelName": "validation",
              "DataSource": {
                "S3DataSource": {
                  "S3DataType": "S3Prefix",
                  "S3Uri": "s3://${aws_s3_bucket.data_store.id}/${var.validate_key}",
                  "S3DataDistributionType": "FullyReplicated"
                  }
                },
                "ContentType": "${var.content_type}",
                "CompressionType": "None"     
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
      "ResultPath": "$.BestModelResult",
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
          "Next": "Save Best Model"
        }
      ],
      "Default": "Model Accuracy Too Low"
    },
    "Model Accuracy Too Low": {
      "Comment": "Validation accuracy lower than threshold",
      "Type": "Fail"
    },
    "Save Best Model": {
      "Parameters": {
        "PrimaryContainer": {
          "Image": "${var.built_in_model_image != null ? var.built_in_model_image : module.ecr_image_byo_model.ecr_image_url_and_tag}",
          "Environment": {},
          "ModelDataUrl.$": "$.modelDataUrl"
        },
        "ExecutionRoleArn": "${module.step-functions.iam_role_arn}",
        "ModelName.$": "$.modelName"
      },
      "ResultPath": "$.modelSaveResult",
      "Resource": "arn:aws:states:::sagemaker:createModel",
      "Type": "Task",
      "Next": "Load Pred Outputs from S3 to Database"
    },
    "Load Pred Outputs from S3 to Database": {
      "Resource": "${module.lambda_functions.function_ids["LoadPredDataDB"]}",
      "Type": "Task",
      "Next": "Monitor Input Data"
    }
    "Monitor Input Data": {
      "Resource": "${module.lambda_functions.function_ids["ProblemType"]}",
      "Type": "Choice",
      "Choices": [
         {
           "Not": {
             "Variable":"$.response",
             "StringEquals": "Classification"
           },
           "Next": "Monitor Model Performance"
        },
         {
          "Variable": "$.response",
            "StringEquals": "Classification"
        }, 
        "Next": "Check Data Drift Result Status"
      ]
    },
    "Check Data Drift Result Status": {
      "Resource": "${module.lambda_functions.function_ids["DataDriftMonitor"]}",
      "Type": "Choice",
      "Choices": [
        {
           "Not": {
             "Variable":"$.latest_result_status",
             "StringEquals": "Completed"
           },
           "Next": "Stop Model Training"
        },
        {
          "Variable": "$.latest_result_status",
          "StringEquals": "Completed"
        }, 
        "Next": "Monitor Model Performance"
      ]
    },
    "Stop Model Training": {
      "Resource": "${module.lambda_functions.function_ids["StopTraining"]}",
      "Type": "Task",
      "Next": "Send a SNS Alert"
    }
    "Send a SNS Alert": {
      "Resource": "${module.lambda_functions.function_ids["SNSAlert"]}",
      "Type": "Task",
      "Next": "Monitor Model Performance"
    }
    "Monitor Model Performance": {
      "Resource": "${module.lambda_functions.function_ids["ModelPerformanceMonitor"]}",
      "Type": "Task",
      "Next": "Model Monitor Rule"
    },
    "Model Monitor Rule": {
      "Resource": "${module.lambda_functions.function_ids["CloudWatchAlarm"]}",
      "Type": "Choice",
      "Choices": [
        {
          "Not": {
            "Variable": "$.MetricName",
            "${var.comparison_operator}": ${var.threshold}
          },
          "Next": "Cloud Watch Alarm"
        },
        "Default": "${var.endpoint_or_batch_transform}"
      ]
    },
    "Cloud Watch Alarm": {
      "Resource": "${module.lambda_functions.function_ids["CloudWatchAlarm"]}",
      "Type": "Task",
      "Next": "Model Retrain Rule"
    },
    "Model Retrain Rule" :{
      "Resource": "${module.lambda_functions.function_ids["CloudWatchAlarm"]}",
      "Type": "Choice",
      "Choices": [
        {
          "And": [{
            "Variable": "$.MetricName",
            "${var.comparison_operator}": ${var.threshold}
          },
          {
            "Variable": "$.response",
            "StringEquals": "True"
          }
          ],
          "Next": "Glue Data Transformation"
        },
        "Default": "Stop Model Training"
      ]
    },
    "Stop Model Training": {
      "Resource": "${module.lambda_functions.function_ids["StopTraining"]}",
      "Type": "Task",
      "Next": "${var.endpoint_or_batch_transform}"
    },
    ${var.endpoint_or_batch_transform == "Create Model Endpoint Config" ? local.endpoint : local.batch_transform}
  }
}
EOF
}


