##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input."
  type        = string
}
variable "environment" {
  description = "Standard `environment` module input."
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  description = "Standard `resource_tags` module input."
  type        = map(string)
}

########################################
### Custom variables for this module ###
########################################

# Local paths:

variable "glue_transform_script" { // glue_transform_script
  description = <<EOF
Local path for Glue Python script.
For example: "./source/scripts/transform.py"
EOF
  type        = string
}

variable "whl_path" { #TODO: glue_dependency_package
  description = "Local path for Glue Python .whl file."
  type        = string
  default     = "source/scripts/python/pandasmodule-0.1-py3-none-any.whl"
}

variable "train_local_path" {
  description = "Local path for training data."
  type        = string
  default     = "source/data/train/train.csv"
}

variable "score_local_path" {
  description = "Local path for scoring data. Set to null for endpoint inference"
  type        = string
  default     = "source/data/score/score.csv"
}

# S3 Storage Buckets and Paths

variable "ml_bucket_override" {
  description = "Optionally, you can override the default ML bucket with a bucket that already exists."
  type        = string
  default     = null
}

variable "train_key" {
  description = "URL path postfix for training data. Provide a folder only if an image recognition problem, a csv file if a classification problem."
  type        = string
  default     = "input_data/train/train.csv"
}

variable "test_key" {
  description = "URL path postfix for testing data. Provide a folder only if an image recognition problem, a csv file if a classification problem."
  type        = string
  default     = "input_data/test/test.csv"
}

variable "validate_key" {
  description = "URL path postfix for validation data. Provide a folder only if an image recognition problem, a csv file if a classification problem."
  type        = string
  default     = "input_data/validate/validate.csv"
}

# Input data config:

variable "input_data_content_type" { 
  description = <<EOF
Define the content type for the HPO job. If it is regular classification problem, content type is 'csv'; if image recognition, content type is
'application/x-recordio'
EOF
  type        = string
  default     = "csv"
}

# State Machine input variables

variable "job_name" {
  description = "Name prefix given to SageMaker model and training/tuning jobs (18 characters or less)."
  type        = string
}

# Endpoint and Batch Config # TODO: move lower

variable "endpoint_name" {
  description = <<EOF
SageMaker inference endpoint to be created/updated. Endpoint will be created if
it does not already exist.
EOF
  type        = string
  default     = "training-endpoint"
}

variable "endpoint_or_batch_transform" {
  description = "Choose whether to create/update an inference API endpoint or do batch inference on test data."
  type        = string
  default     = "Batch Transform" # Batch Transform or Create Model Endpoint Config
}

variable "endpoint_instance_count" {
  description = "Number of initial endpoint instances."
  type        = number
  default     = 1
}

variable "endpoint_instance_type" {
  description = "Instance type for inference endpoint."
  type        = string
  default     = "ml.m4.xlarge"
}

variable "batch_transform_instance_count" {
  description = "Number of batch transformation instances."
  type        = number
  default     = 1
}

variable "batch_transform_instance_type" {
  description = "Instance type for batch inference."
  type        = string
  default     = "ml.m4.xlarge"
}

# Hyperparameter tuning variables

variable "static_hyperparameters" {
  description = <<EOF
Map of hyperparameter names to static values, which should not be altered during hyperparameter tuning.
E.g. `{ "kfold_splits" = "5" }`
EOF
  type        = map
  default = {
  }
}

variable "tuning_strategy" { 
  description = "Hyperparameter tuning strategy, can be Bayesian or Random."
  type        = string
  default     = "Bayesian"
}

variable "parameter_ranges" {
  description = <<EOF
Tuning ranges for hyperparameters.
Expects a map of one or all "ContinuousParameterRanges", "IntegerParameterRanges", and "CategoricalParameterRanges".
Each item in the map should point to a list of object with the following keys:
 - Name        - name of the variable to be tuned
 - MinValue    - min value of the range
 - MaxValue    - max value of the range
 - ScalingType - 'Auto', 'Linear', 'Logarithmic', or 'ReverseLogarithmic'
 - Values      - a list of strings that apply to the categorical paramters
EOF
}

variable "tuning_objective" {
  description = "Hyperparameter tuning objective ('Minimize' or 'Maximize')."
  type        = string
  default     = "Maximize"

  validation {
    condition     = substr(var.tuning_objective, 0, 1) == "M"
    error_message = "The tuning_objective value must be a valid value of either \"Minimize\" or \"Maximize\", starting with capatalized \"M\"."
  }
}

variable "tuning_metric" {
  description = "Hyperparameter tuning metric, e.g. 'error', 'auc', 'f1', 'accuracy'."
  type        = string
  default     = "accuracy"
}

# Inference threshold config # TODO: Reorder

variable "inference_comparison_operator" {
  description = <<EOF
Comparison operator for deploying the trained SageMaker model.
Used in combination with `inference_metric_threshold`.
Examples: 'NumericGreaterThan', 'NumericLessThan', etc.
EOF
  type        = string
  default     = "NumericGreaterThan"
}

variable "inference_metric_threshold" {
  description = <<EOF
threshold for deploying the trained SageMaker model.
Used in combination with `inference_comparison_operator`.
EOF
  type        = number
  default     = 0.7
}

# Training config

variable "built_in_model_image" {
  description = <<EOF
One of the ECR image URIs from Amazon-stock SageMaker image definitions.
If specified, 'bring-your-own' model support is not required and the ECR image will not
be created.
EOF
  type        = string
  default     = null
}

variable "max_number_training_jobs" {
  description = "Maximum number of total training jobs for hyperparameter tuning."
  type        = number
  default     = 3
}

variable "max_parallel_training_jobs" {
  description = "Maximimum number of training jobs running in parallel for hyperparameter tuning."
  type        = number
  default     = 1
}

# Training resource allocation

variable "training_job_instance_count" {
  description = "Number of instances for training jobs."
  type        = number
  default     = 1
}

variable "training_job_instance_type" {
  description = "Instance type for training jobs."
  type        = string
  default     = "ml.m4.xlarge"
}

variable "training_job_storage_in_gb" {
  description = "Instance volume size in GB for training jobs."
  type        = number
  default     = 30
}

# ECR input variables (BYO)

variable "byo_model_image_name" {
  description = "Image and repo name for bring your own model."
  type        = string
  default     = "byo-custom"
}

variable "byo_model_image_tag" {
  description = "Tag for bring your own model image."
  type        = string
  default     = "latest"
}

variable "byo_model_repo_name" { 
  description = "Name for your BYO model image repository."
  type        = string
}

variable "byo_model_source_image_path" { 
  description = "Local source path for bring your own model docker image."
  type        = string
  default     = "source/containers/ml-ops-byo-custom"
}

variable "byo_model_ecr_tag_name" { 
  description = "Tag name for the BYO ecr image."
  type        = string
  default     = "latest"
}

variable "aws_credentials_file" {
  description = "Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image."
  type        = string
}

# Glue transform config

variable "glue_job_name" {
  description = "Name of the Glue data transformation job name."
  type        = string
  default     = "data-transformation"
}

variable "glue_job_spark_flag" {
  description = "(Default=True). True to use the default (Spark) Glue job type. False to use Python Shell."
  type        = bool
  default     = false
}

# Cloudwatch alarm variables

variable "alarm_name" {
  description = "Name of the cloudwatch alarm"
  type        = string
  default     = "Model is Overfitting and Retraining Alarm"
}

variable "alarm_comparison_operator" { 
  description = <<EOF
  The arithmetic operation to use when comparing the specified alarm_statistic and alarm_threshold. The specified alarm_statistic 
  value is used as the first operand.Possible values include StringEquals, IsBoolean, StringLessThan, IsNumeric, 
  BooleanEquals,
  StringLessThanEqualsPath, NumericLessThan, NumericGreaterThan,
  NumericLessThanPath, StringMatches, TimestampLessThanEqualsPath, NumericEquals,
  TimestampGreaterThan, StringGreaterThanEqualsPath, TimestampGreaterThanEqualsPath,
  TimestampLessThanEquals, NumericLessThanEqualsPath, TimestampEquals, BooleanEqualsPath,
  IsTimestamp, StringLessThanEquals, NumericLessThanEquals, StringLessThanPath,
  TimestampGreaterThanPath, StringGreaterThan, StringGreaterThanPath, IsString, StringEqualsPath,
  TimestampEqualsPath, TimestampLessThan, StringGreaterThanEquals, NumericGreaterThanPath,
  NumericGreaterThanEquals, NumericEqualsPath, TimestampLessThanPath,
  IsNull, IsPresent, TimestampGreaterThanEquals, NumericGreaterThanEqualsPath
  EOF
  type        = string
  default     = "NumericLessThan"
}

variable "alarm_evaluation_period" { 
  description = <<EOF
  The number of periods over which data is compared to the specified alarm_threshold. If you are setting an alarm that 
  requires that a number of consecutive data points be breaching to trigger the alarm, this value specifies that number. 
  If you are setting an "M out of N" alarm, this value is the N.An alarm's total current evaluation period can be no longer 
  than one day, so this number multiplied by Period cannot be more than 86,400 seconds.This parameter works in combination 
  with alarm_datapoints_to_evaluate for specifying how frequently the model performance will be monitored.
  EOF
  type        = number
  default     = 10
}

variable "alarm_datapoints_to_evaluate" { 
  description = <<EOF
  The number of data points that must be breaching to trigger the alarm. This is used only if you are setting an "M out of N" 
  alarm. In that case, this value is the M.This parameter works in combination with alarm_evaluation_period for specifying how 
  frequently the model performance will be monitored.
  EOF
  type        = number
  default     = 10
}

variable "alarm_metric_name" { 
  description = <<EOF
  The name for the metric associated with the alarm. For each PutMetricAlarm operation, you must specify either MetricName or
  a Metrics array.If you are creating an alarm based on a math expression, you cannot specify this parameter, or any of the 
  Dimensions , Period , Namespace , alarm_statistic ,or Extendedalarm_statistic parameters. Instead, you specify all this information in 
  the Metrics array. Values include Training Accuray, Training Loss, Validation Accuracy, and Validation Loss.
  EOF
  type        = string
  default     = "Training Accuracy"
}

variable "alarm_metric_evaluation_period" {
  description = "The granularity, in seconds, of the returned data points"
  type        = number
  default     = 30
}

variable "alarm_statistic" { 
  description = "The alarm_statistic to return. It can include any CloudWatch stats or extended stats"
  type        = string
  default     = "Maximum"
}

variable "alarm_statistic_unit_name" { 
  description = <<EOF
  The unit of measure for the alarm_statistic.You can also specify a unit when you create a custom metric. Units help provide conceptual 
  meaning to your data. Metric data points that specify a unit of measure, such as Percent, are aggregated separately.
  If you don't specify Unit , CloudWatch retrieves all unit types that have been published for the metric and attempts to evaluate the alarm. 
  Usually metrics are published with only one unit, so the alarm will work as intended.
  However, if the metric is published with multiple types of units and you don't specify a unit, the alarm's behavior is not defined and will 
  behave un-predictably. We recommend omitting Unit so that you don't inadvertently specify an incorrect unit that is not published for this 
  metric. Doing so causes the alarm to be stuck in the INSUFFICIENT DATA state.

  Possible values:
  Seconds, Microseconds, Milliseconds, Bytes, Kilobytes, Megabits, Gigabits, Terabits, Percent, Count, Bytes/Second, Kilobytes/Second, Megabytes/Second,
  Gigabytes/Second, Terabytes/Second, Bits/Second, Kilobits/Second, Megabits/Second, Gigabits/Second, Terabits/Second, Count/Second, and None.
  EOF
  type        = string
  default     = "Percent"
}

variable "alarm_threshold" { 
  description = "The baseline alarm_threshold value that cloudwatch will compare against"
  type        = number
  default     = 90.0
}

variable "alarm_actions_enabled" { 
  description = "Indicates whether actions should be executed during any changes to the alarm state. "
  type        = bool
  default     = true
}

variable "alarm_description" { 
  description = "The description for the alarm."
  type        = string
  default     = "Model is overfitting. Model retraining will be activated."
}

variable "retrain_on_alarm" { 
  description = "Whether or not to retrain the model if detected overfitting."
  type        = bool
  default     = false
}

# Data drift monitoring variables

variable "data_drift_monitor_name" { 
  description = "The name for the scheduled data drift monitoring job"
  type        = string
  default     = "data-drift-monitor-schedule"
}

variable "data_drift_monitoring_frequency" { 
  description = "The data_drift_monitoring_frequency at which data drift monitoring is performed. Values include: hourly, daily, and daily_every_x_hours (hour_interval, starting_hour)"
  type        = string
  default     = "daily"
}

variable "data_drift_ml_problem_type" { 
  description = "The type of machine learning problem, including Classification, Image Recognition, and Regression"
  type        = string
  default     = "Classification"
}

variable "data_drift_sampling_percent" { 
  description = "The percentage used to sample the input data to perform a data drift detection"
  type        = number
  default     = 50
}

variable "data_drift_job_timeout_in_sec" { 
  description = "Timeout in seconds. After this amount of time, Amazon SageMaker terminates the job regardless of its current status."
  type        = number
  default     = 3600
}

# Load pred outputs to selected database variables

variable "enable_predictive_db" { 
  description = "Enable loading prediction outputs from S3 to the selected database."
  type        = bool
  default     = false
}

variable "predictive_db_name" { 
  description = "The name for the database in PostgreSQL"
  type        = string
  default     = "model_outputs"
}

variable "predictive_db_admin_user" { 
  description = "Define admin user name for PostgreSQL."
  type        = string
  default     = "pgadmin"
}

variable "predictive_db_admin_password" { 
  description = "Define admin user password for PostgreSQL."
  type        = string
  default     = "Db1234asdf"
}

variable "predictive_db_storage_size_in_gb" { 
  description = "The allocated storage value is denoted in GB"
  type        = string
  default     = "10"
}

variable "predictive_db_instance_class" { 
  description = "Enter the desired node type. The default and cheapest option is 'db.t3.micro' @ ~$0.018/hr, or ~$13/mo (https://aws.amazon.com/rds/mysql/pricing/ )"
  type        = string
  default     = "db.t3.micro"
}
