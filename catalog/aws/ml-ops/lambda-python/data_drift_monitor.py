""" This is a function for enabling data capture.

Checks these 2 things of the input data: 

    - features (aka input schema)
    - descriptive statistics about input features 
"""

from urllib.parse import urlparse
from time import gmtime, strftime, sleep
import time
from threading import Thread

import boto3
import pandas as pd
from sagemaker import session
from sagemaker import RealTimePredictor
from sagemaker.model_monitor import (
    CronExpressionGenerator,
    DefaultModelMonitor,
    DataCaptureConfig,
)
from sagemaker import get_execution_role
from sagemaker.model_monitor.dataset_format import DatasetFormat


sm_client = boto3.client("sagemaker")
sm_session = session.Session(boto3.Session())
s3_client = boto3.Session().client("s3")
role = "${module.step-functions.iam_role_arn}"

# give a name to the data drift monitor job
mon_schedule_name = "data-drift-monitor-schedule"
endpoint_name = "${var.endpoint_name}"
frequency = "${var.frequency}"

# define a url path for the captured data output
s3_capture_upload_path = (
    "s3://${aws_s3_bucket.data_store.id}/monitor_output/endpoint-data-capture"
)

# define the url path for train data which is the baseline data
baseline_data_uri = "s3://${aws_s3_bucket.data_store.id}/input_data/train"

baseline_results_uri = (
    "s3://${aws_s3_bucket.data_store.id}/monitor_output/baseline-results"
)
# define an url for the data drift monitor report
s3_report_path = (
    "s3://${aws_s3_bucket.data_store.id}/monitor_output/data-drift-monitor-results"
)

# you can also choose hourly, or daily_every_x_hours(hour_interval, starting_hour=0)
def monitor_frequency(interval=frequency, hour_interval=None, starting_hour=None):

    # this allows users to define the frequency of data drift monitoring

    if interval == "daily":
        monitoring_frequency = CronExpressionGenerator.daily()
    if interval == "hourly":
        monitoring_frequency = CronExpressionGenerator.hourly()
    if interval == "others":
        monitoring_frequency = CronExpressionGenerator.daily_every_x_hours(
            hour_interval, starting_hour
        )
    return monitoring_frequency


# Change parameters as you would like - adjust sampling percentage,
# chose to capture request or response or both.
data_capture_config = DataCaptureConfig(
    enable_capture=True,
    sampling_percentage="${var.sample_percent}",
    destination_s3_uri=s3_capture_upload_path,
    kms_key_id=None,
    capture_options=["REQUEST", "RESPONSE"],
    csv_content_types=["text/csv"],
    json_content_types=["application/json"],
)

# Now it is time to apply the new configuration and wait for it to be applied
predictor = RealTimePredictor(endpoint=endpoint_name)
predictor.update_data_capture_config(data_capture_config=data_capture_config)
sm_session.wait_for_endpoint(endpoint=endpoint_name)

my_default_monitor = DefaultModelMonitor(
    role=role,
    instance_count="${var.training_job_instance_count}",
    instance_type="${var.training_job_instance_type}",
    volume_size_in_gb="${var.training_job_instance_type}",
    max_runtime_in_seconds="${var.max_timeout_in_sec}",
)

# now ask Sagemaker to suggest baseline stats
my_default_monitor.suggest_baseline(
    baseline_dataset=baseline_data_uri + "/train.csv",
    dataset_format=DatasetFormat.csv(header=True),
    output_s3_uri=baseline_results_uri,
    wait=True,
)

my_default_monitor.create_monitoring_schedule(
    monitor_schedule_name=mon_schedule_name,
    endpoint_input=predictor.endpoint,
    output_s3_uri=s3_report_path,
    statistics=my_default_monitor.baseline_statistics(),
    constraints=my_default_monitor.suggested_constraints(),
    schedule_cron_expression=monitor_frequency,
    enable_cloudwatch_metrics=True,
)

baseline_job = my_default_monitor.latest_baselining_job
schema_df = pd.io.json.json_normalize(
    baseline_job.baseline_statistics().body_dict["features"]
)
constraints_df = pd.io.json.json_normalize(
    baseline_job.suggested_constraints().body_dict["features"]
)
desc_schedule_result = my_default_monitor.describe_schedule()
mon_executions = my_default_monitor.list_executions()


def lambda_handler(event, context):

    """
    Inspect a specific execution (latest execution).
    Here are the possible terminal states and what each of them mean:
    - Completed - This means the monitoring execution completed and no issues were found in the violations report.
    - CompletedWithViolations - This means the execution completed, but constraint violations were detected.
    - Failed - The monitoring execution failed, maybe due to client error (perhaps incorrect role premissions) or infrastructure issues. Further examination of FailureReason and ExitMessage is necessary to identify what exactly happened.
    - Stopped - job exceeded max runtime or was manually stopped.
    """

    # latest execution's index is -1, second to last is -2 and so on..
    latest_execution = mon_executions[-1]
    time.sleep(60)
    latest_execution.wait(logs=False)

    latest_job = latest_execution.describe()

    report_uri = latest_execution.output.destination

    # list the generated reports
    s3uri = urlparse(report_uri)
    report_bucket = s3uri.netloc
    report_key = s3uri.path.lstrip("/")

    result = s3_client.list_objects(Bucket=report_bucket, Prefix=report_key)
    report_files = [report_file.get("Key") for report_file in result.get("Contents")]

    # get the latest violations report
    latest_monitoring_violations = (
        my_default_monitor.latest_monitoring_constraint_violations()
    )
    pd.set_option("display.max_colwidth", -1)
    constraints_violations_df = pd.io.json.json_normalize(
        latest_monitoring_violations.body_dict["violations"]
    )
    # get the latest violation stats
    latest_monitoring_statistics = my_default_monitor.latest_monitoring_statistics()

    # get the status of the latest execution result
    latest_result_status = latest_execution.describe()["ExitMessage"]

    # Delete the resources after running the inspection to avoid incurring additional charges
    my_default_monitor.delete_monitoring_schedule()
    time.sleep(60)  # actually wait for the deletion
    predictor.delete_endpoint()
    predictor.delete_model()

    return {
        latest_result_status,
        report_uri,
        constraints_violations_df,
        latest_monitoring_statistics,
    }
