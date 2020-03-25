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
          "InitialInstanceCount": 1,
          "InstanceType": "ml.m4.xlarge",
          "ModelName.$": "$.modelName",
          "VariantName": "AllTraffic"
        }
      ]
    },
    "Type": "Task",
    "Next": "Extract Endpoint Config Name"
  },
  "Extract Endpoint Config Name": {
    "Resource": "${module.lambda_functions.function_ids["ExtractModelName"]}",
    "Type": "Task",
    "Next": "Check Endpoint Exists"
  },
  "Check Endpoint Exists": {
    "Resource": "${module.lambda_functions.function_ids["CheckEndpointExists"]}",
    "Parameters": {
      "EndpointConfig.$": "$.modelName",
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
            "S3Uri": "s3://${var.s3_bucket_name}/${var.data_s3_path}/test/test.csv"
          }
        }
      },
      "TransformOutput": {
        "S3OutputPath": "s3://${var.s3_bucket_name}/batch-transform-output"
      },
      "TransformResources": {
        "InstanceCount": 1,
        "InstanceType": "ml.m4.xlarge"
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
      "BucketName": "${var.s3_bucket_name}",
      "Path": "batch-transform-output"
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
  s3_bucket_name           = var.s3_bucket_name
  environment              = var.environment
  resource_tags            = var.resource_tags
  lambda_functions         = module.lambda_functions.function_ids
  state_machine_definition = <<EOF
{
 "StartAt": "Generate Unique Job Name",
  "States": {
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
            "TrainingImage": "${var.training_image}",
            "TrainingInputMode": "File"
          },
          "OutputDataConfig": {
            "S3OutputPath": "s3://${var.s3_bucket_name}/output"
          },
          "StoppingCondition": {
            "MaxRuntimeInSeconds": 86400
          },
          "ResourceConfig": {
            "InstanceCount": 1,
            "InstanceType": "ml.m5.xlarge",
            "VolumeSizeInGB": 30
          },
          "RoleArn": "${module.step-functions.iam_role_arn}",
          "InputDataConfig": [
            {
              "DataSource": {
                "S3DataSource": {
                  "S3DataDistributionType": "FullyReplicated",
                  "S3DataType": "S3Prefix",
                  "S3Uri": "s3://${var.s3_bucket_name}/${var.data_s3_path}/train/train.csv"
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
          "Image": "${var.training_image}",
          "Environment": {},
          "ModelDataUrl.$": "$.modelDataUrl"
        },
        "ExecutionRoleArn": "${module.step-functions.iam_role_arn}",
        "ModelName.$": "$.bestTrainingJobName"
      },
      "Resource": "arn:aws:states:::sagemaker:createModel",
      "Type": "Task",
      "Next": "Extract Model Name"
    },
    "Extract Model Name": {
      "Resource": "${module.lambda_functions.function_ids["ExtractModelName"]}",
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