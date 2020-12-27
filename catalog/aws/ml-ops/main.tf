/*
* This module automates MLOps tasks associated with training Machine Learning models.
*
* The module leverages Step Functions and Lambda functions as needed. The state machine
* executes hyperparameter tuning, training, and deployments as needed. Deployment options
* supported are Sagemaker endpoints and/or batch inference.
*/


locals {
  writeable_buckets = var.ml_bucket_override != null ? [data.aws_s3_bucket.ml_bucket_override[0].id] : [aws_s3_bucket.ml_bucket[0].id]
}

module "endpoint_config_workflow" {
  # State machine input for creating or updating an inference endpoint
  count         = var.enable_api_endpoint ? 1 : 0
  source        = "../../../components/aws/step-functions"
  name_prefix   = "${var.name_prefix}b-endpoint_config-"
  environment   = var.environment
  resource_tags = var.resource_tags

  lambda_functions  = module.core_lambda.function_ids
  writeable_buckets = local.writeable_buckets
  state_machine_definition = jsonencode(
    {
      StartAt = "Generate_Unique_Config_Job_Name"
      States = {
        Generate_Unique_Config_Job_Name = {
          Type     = "Task"
          Resource = module.core_lambda.function_ids["UniqueJobName"]
          Parameters = {
            "JobName.$"   = "$.modelName"
            "modelName.$" = "$.modelName"
          }
          Next = "Create_Model_Endpoint_Config"
        }
        Create_Model_Endpoint_Config = {
          Type     = "Task"
          Resource = "arn:aws:states:::sagemaker:createEndpointConfig"
          Parameters = {
            "EndpointConfigName.$" = "$.JobName"
            ProductionVariants = [
              {
                InitialInstanceCount = var.endpoint_instance_count
                InstanceType         = var.endpoint_instance_type
                "ModelName.$"        = "$.modelName"
                VariantName          = "AllTraffic"
              }
            ]
          }
          Next = "Check_Endpoint_Exists"
        }
        Check_Endpoint_Exists = {
          Type     = "Task"
          Resource = module.core_lambda.function_ids["CheckEndpointExists"]
          Parameters = {
            "EndpointConfigArn.$" = "$.EndpointConfigArn"
            EndpointName          = var.endpoint_name
          }
          Next = "Choose_Create_or_Update_Endpoint"
        }
        Choose_Create_or_Update_Endpoint = {
          Type = "Choice"
          Choices = [
            {
              Variable     = "$['CreateOrUpdate']"
              StringEquals = "Update"
              Next         = "Update_Existing_Model_Endpoint"
              # Next         = "Delete_Existing_Model_Endpoint"
            }
          ]
          Default = "Create_New_Model_Endpoint"
        }
        Create_New_Model_Endpoint = {
          Type     = "Task"
          Resource = "arn:aws:states:::sagemaker:createEndpoint"
          Parameters = {
            "EndpointConfigName.$" = "$.endpointConfig"
            "EndpointName.$"       = "$.endpointName"
          }
          End = true
        }
        Update_Existing_Model_Endpoint = {
          Resource = "arn:aws:states:::sagemaker:updateEndpoint"
          Parameters = {
            "EndpointConfigName.$" = "$.endpointConfig"
            "EndpointName.$"       = "$.endpointName"
          }
          Type = "Task"
          End  = true
        }
        # Delete_Existing_Model_Endpoint = {
        #   Type     = "Task"
        #   Resource = "arn:aws:states:::sagemaker:deleteEndpoint"
        #   Parameters = {
        #     "EndpointName" = "$.endpointName"
        #   }
        #   Next = "Create_New_Model_Endpoint"
        # }
      }
    }
  )
}

module "batch_scoring_workflow" {
  count         = var.enable_batch_scoring ? 1 : 0
  source        = "../../../components/aws/step-functions"
  name_prefix   = "${var.name_prefix}c-batch_scoring-"
  environment   = var.environment
  resource_tags = var.resource_tags

  lambda_functions  = module.core_lambda.function_ids
  writeable_buckets = local.writeable_buckets
  schedules         = var.batch_scoring_schedule
  state_machine_definition = jsonencode(
    {
      StartAt = "Generate_Unique_Batch_Job_Name"
      States = {
        Generate_Unique_Batch_Job_Name = {
          Type     = "Task"
          Resource = module.core_lambda.function_ids["UniqueJobName"]
          Parameters = {
            "JobName.$"   = "$.modelName"
            "modelName.$" = "$.modelName"
          }
          Next = "Batch_Scoring"
        }
        Batch_Scoring = {
          Type     = "Task"
          Resource = "arn:aws:states:::sagemaker:createTransformJob.sync"
          Parameters = {
            "ModelName.$" = "$.modelName"
            TransformInput = {
              ContentType     = var.input_data_content_type
              CompressionType = "None"
              DataSource = {
                S3DataSource = {
                  S3DataType = "S3Prefix"
                  S3Uri      = "s3://${aws_s3_bucket.ml_bucket[0].id}/${var.score_key}"
                }
              }
            }
            TransformOutput = {
              S3OutputPath = "s3://${aws_s3_bucket.ml_bucket[0].id}/batch-transform-output"
            }
            TransformResources = {
              InstanceCount = var.batch_scoring_instance_count
              InstanceType  = var.batch_scoring_instance_type
            }
            "TransformJobName.$" = "$.JobName"
          }
          Next = "Rename_Batch_Scoring_Output"
        }
        Rename_Batch_Scoring_Output = {
          Type     = "Task"
          Resource = module.core_lambda.function_ids["RenameBatchOutput"]
          Parameters = {
            Payload = {
              BucketName = aws_s3_bucket.ml_bucket[0].id
              Path       = "batch-transform-output"
            }
          }
          Next = "Run_Glue_Crawler"
        }
        Run_Glue_Crawler = {
          Type     = "Task"
          Resource = module.core_lambda.function_ids["RunGlueCrawler"]
          Parameters = {
            Payload = {
              CrawlerName = module.glue_crawler.glue_crawler_name
            }
          }
          End = true
        }
      }
    }
  )
}

module "training_workflow" {
  source        = "../../../components/aws/step-functions"
  name_prefix   = "${var.name_prefix}a-model_training-"
  environment   = var.environment
  resource_tags = var.resource_tags

  lambda_functions  = module.core_lambda.function_ids
  writeable_buckets = local.writeable_buckets
  schedules         = var.training_job_schedule
  state_machine_definition = jsonencode({
    StartAt = "Glue_Data_Transformation"
    States = merge(
      {
        Glue_Data_Transformation = {
          Type     = "Task"
          Resource = "arn:aws:states:::glue:startJobRun.sync"
          Parameters = {
            JobName = module.glue_job.glue_job_name
            Arguments = {
              "--extra-py-files" = "s3://${aws_s3_bucket.source_repository.id}/glue/python/pandasmodule-0.1-py3-none-any.whl"
              "--S3_SOURCE"      = var.ml_bucket_override != null ? data.aws_s3_bucket.ml_bucket_override[0].id : aws_s3_bucket.ml_bucket[0].id
              "--S3_DEST"        = aws_s3_bucket.ml_bucket[0].id
              "--TRAIN_KEY"      = var.train_key
              "--VALIDATION_KEY" = var.validate_key
              "--SCORE_KEY"      = var.score_key
              "--INFERENCE_TYPE" = var.enable_batch_scoring ? "batch" : "endpoint"
            }
          }
          Next = "Generate_Unique_Job_Name"
        }
        Generate_Unique_Job_Name = {
          Type     = "Task"
          Resource = module.core_lambda.function_ids["UniqueJobName"]
          Parameters = {
            JobName = var.job_name
          }
          Next = "Hyperparameter_Tuning"
        }
        Hyperparameter_Tuning = {
          Type     = "Task"
          Resource = "arn:aws:states:::sagemaker:createHyperParameterTuningJob.sync"
          Parameters = {
            "HyperParameterTuningJobName.$" = "$.JobName"
            HyperParameterTuningJobConfig = {
              Strategy = var.tuning_strategy
              HyperParameterTuningJobObjective = {
                Type       = var.tuning_objective
                MetricName = var.tuning_metric
              }
              ResourceLimits = {
                MaxNumberOfTrainingJobs = var.max_number_training_jobs
                MaxParallelTrainingJobs = var.max_parallel_training_jobs
              }
              ParameterRanges = var.parameter_ranges
            }
            TrainingJobDefinition = {
              AlgorithmSpecification = {
                MetricDefinitions = [
                  {
                    Name  = var.tuning_metric
                    Regex = "${var.tuning_metric}: ([0-9\\.]+)"
                  }
                ]
                TrainingImage     = var.built_in_model_image != null ? var.built_in_model_image : module.ecr_image_byo_model[0].ecr_image_url_and_tag
                TrainingInputMode = "File"
              }
              OutputDataConfig = {
                S3OutputPath = "s3://${aws_s3_bucket.ml_bucket[0].id}/models"
              }
              StoppingCondition = {
                MaxRuntimeInSeconds = 86400
              }
              ResourceConfig = {
                InstanceCount  = var.training_job_instance_count
                InstanceType   = var.training_job_instance_type
                VolumeSizeInGB = var.training_job_storage_in_gb
              }
              RoleArn = module.training_workflow.iam_role_arn
              InputDataConfig = flatten(
                [
                  [
                    {
                      ChannelName     = "train"
                      ContentType     = var.input_data_content_type
                      CompressionType = "None"
                      DataSource = {
                        S3DataSource = {
                          S3DataType             = "S3Prefix"
                          S3Uri                  = "s3://${aws_s3_bucket.ml_bucket[0].id}/${var.train_key}"
                          S3DataDistributionType = "FullyReplicated"
                        }
                      }
                    }
                  ],
                  var.validate_key == null ? [] : [
                    {
                      ChannelName     = "validation"
                      ContentType     = var.input_data_content_type
                      CompressionType = "None"
                      DataSource = {
                        S3DataSource = {
                          S3DataType             = "S3Prefix"
                          S3Uri                  = "s3://${aws_s3_bucket.ml_bucket[0].id}/${var.validate_key}"
                          S3DataDistributionType = "FullyReplicated"
                        }
                      }
                    }
                  ]
                ]
              )
              StaticHyperParameters = var.static_hyperparameters
            }
          }
          Next = "Extract_Best_Model_Path"
        }
        Extract_Best_Model_Path = {
          Type       = "Task"
          Resource   = module.core_lambda.function_ids["ExtractModelPath"]
          ResultPath = "$.BestModelResult"
          Next       = "Query_Training_Results"
        }
        Query_Training_Results = {
          Type     = "Task"
          Resource = module.core_lambda.function_ids["QueryTrainingStatus"]
          Next     = "Inference_Rule"
        }
        Inference_Rule = {
          Type = "Choice"
          Choices = [
            {
              Variable                            = "$['trainingMetrics'][0]['Value']"
              (var.inference_comparison_operator) = var.inference_metric_threshold
              Next                                = "Save_Best_Model"
            },
          ]
          Default = "Model_Accuracy_Too_Low"
        }
        Model_Accuracy_Too_Low = {
          Type    = "Fail"
          Comment = "Validation accuracy lower than threshold"
        }
        Save_Best_Model = merge(
          {
            Type     = "Task"
            Resource = "arn:aws:states:::sagemaker:createModel"
            Parameters = {
              PrimaryContainer = {
                Image            = var.built_in_model_image != null ? var.built_in_model_image : module.ecr_image_byo_model[0].ecr_image_url_and_tag
                Environment      = {}
                "ModelDataUrl.$" = "$.modelDataUrl"
              }
              ExecutionRoleArn = module.training_workflow.iam_role_arn
              "ModelName.$"    = "$.modelName"
            }
            ResultPath = "$.modelSaveResult"
          }, var.enable_api_endpoint ? { Next = "Execute_API_Update_Workflow" } : { End = true }
        )
      },
      var.enable_api_endpoint == false ? {} : {
        Execute_API_Update_Workflow = {
          Type     = "Task"
          Comment  = "Start the Step Function to create or update the API endpoint."
          Resource = "arn:aws:states:::states:startExecution"
          Parameters = {
            StateMachineArn = module.endpoint_config_workflow[0].state_machine_arn
            Input = {
              "modelName.$"                                  = "$.modelName"
              "AWS_STEP_FUNCTIONS_STARTED_BY_EXECUTION_ID.$" = "$$.Execution.Id"
              NeedCallback                                   = false
            }
          }
          End = true
        }
      }
    )
  })
}

module "drift_detection_workflow" {
  count         = var.enable_predictive_db ? 1 : 0
  source        = "../../../components/aws/step-functions"
  name_prefix   = "${var.name_prefix}d-drift_detection-"
  environment   = var.environment
  resource_tags = var.resource_tags

  lambda_functions  = module.drift_detection_lambda.function_ids
  writeable_buckets = local.writeable_buckets
  schedules         = var.drift_detection_schedule
  state_machine_definition = jsonencode({
    StartAt = "Load_Pred_Outputs_from_S3_to_Database"
    States = {
      Load_Pred_Outputs_from_S3_to_Database = {
        Type     = "Task"
        Resource = module.drift_detection_lambda.function_ids["LoadPredDataDB"]
        Parameters = {
          Payload = {
            is_predictive_db_enabled = var.enable_predictive_db
            db_host                  = var.enable_predictive_db ? module.predictive_db[0].endpoint : "n/a"
            db_name                  = var.predictive_db_name
            db_user                  = var.predictive_db_admin_user
            db_password              = var.predictive_db_admin_password
            s3_csv                   = "s3://${aws_s3_bucket.ml_bucket[0].id}/${var.score_key}"
          }
        }
        Next = "Monitor_Input_Data"
      }
      Monitor_Input_Data = {
        Type = "Choice"
        Choices = [
          {
            Not = {
              Variable     = "$['ClassificationorImageRegnition']"
              StringEquals = "Classification"
            }
            Next = "Monitor_Model_Performance"
          },
          {
            Variable     = "$['ClassificationorImageRegnition']"
            StringEquals = "Classification"
            Next         = "Check_Data_Drift_Result_Status"
          },
        ]
      }
      Check_Data_Drift_Result_Status = {
        Type = "Choice"
        Choices = [
          {
            Not = {
              Variable     = "$.latest_result_status"
              StringEquals = "Completed"
            }
            Next = "Stop_Model_Training"
          },
          {
            Variable     = "$.latest_result_status"
            StringEquals = "Completed"
            Next         = "Monitor_Model_Performance"
          },
        ]
      }
      Stop_Model_Training = {
        Type     = "Task"
        Resource = module.drift_detection_lambda.function_ids["StopTraining"]
        Next     = "Send_SNS_Alert"
      }
      Send_SNS_Alert = {
        Type     = "Task"
        Resource = module.drift_detection_lambda.function_ids["SNSAlert"]
        Next     = "Monitor_Model_Performance"
      }
      Monitor_Model_Performance = {
        Type     = "Task"
        Resource = module.drift_detection_lambda.function_ids["ModelPerformanceMonitor"]
        Next     = "Model_Monitor_Rule"
      }
      Model_Monitor_Rule = {
        Type = "Choice"
        Choices = [
          {
            Not = {
              Variable                        = "$.MetricName"
              (var.alarm_comparison_operator) = var.alarm_threshold
            }
            Next = "CloudWatch_Alarm"
          },
        ]
        Default = var.enable_batch_scoring ? "TODO:" : "TODO:"
      }
      CloudWatch_Alarm = {
        Type     = "Task"
        Resource = module.drift_detection_lambda.function_ids["CloudWatchAlarm"]
        Next     = "Model_Retrain_Rule"
      }
      Model_Retrain_Rule : {
        Type = "Choice"
        Choices = [
          {
            And = [
              {
                Variable                        = "$.MetricName"
                (var.alarm_comparison_operator) = var.alarm_threshold
              },
              {
                Variable     = "$.response"
                StringEquals = "True"
              },
            ]
            Next = "Glue_Data_Transformation"
          },
        ]
        Default = "Stop_Model_Training_Final"
      }
      Stop_Model_Training_Final = {
        Type     = "Task"
        Resource = module.drift_detection_lambda.function_ids["StopTraining"]
        End      = true
      }
    }
  })
}
