# Please fill in the following for enabling data capture
from urllib.parse import urlparse
from sagemaker import get_execution_role
from sagemaker.model_monitor.dataset_format import DatasetFormat
from sagemaker.model_monitor import DefaultModelMonitor
import pandas as pd
import boto3
from time import gmtime, strftime
from sagemaker.model_monitor import CronExpressionGenerator
from sagemaker import session
from sagemaker import RealTimePredictor
from sagemaker.model_monitor import DataCaptureConfig
from threading import Thread
from time import sleep
import time

sm_client = boto3.client("sagemaker")
sm_session = session.Session(boto3.Session())
s3_client = boto3.Session().client('s3')
endpoint_name = "${var.endpoint_name}"
#####
# IMPORTANT
##
# Please make sure to add the "s3:PutObject" permission to the "role' you provided in the SageMaker Model
# behind this Endpoint. Otherwise, Endpoint data capture will not work.
##
#####
# example: s3://bucket-name/path/to/endpoint-data-capture/
s3_capture_upload_path = 's3://${aws_s3_bucket.monitor_outputs_store.id}/endpoint-data-capture'
baseline_data_uri = "s3://${aws_s3_bucket.extracts_store.id}/data/train"
baseline_results_uri = "s3://${aws_s3_bucket.extracts_store.id}/data/train/baseline-results"
role = "${module.step-functions.iam_role_arn}"
mon_schedule_name = 'data-drift-monitor-schedule'
s3_report_path = 's3://${aws_s3_bucket.monitor_output_store.id}/data-drift-monitor-results'
# you can also choose hourly, or daily_every_x_hours(hour_interval, starting_hour=0)
monitor_frequency = CronExpressionGenerator.daily()

# Change parameters as you would like - adjust sampling percentage,
#  chose to capture request or response or both.


def lambda_handler(event, context):
    data_capture_config = DataCaptureConfig(
        enable_capture=True,
        sampling_percentage=50,
        destination_s3_uri=s3_capture_upload_path,
        kms_key_id=None,
        capture_options=["REQUEST", "RESPONSE"],
        csv_content_types=["text/csv"],
        json_content_types=["application/json"])

    # Now it is time to apply the new configuration and wait for it to be applied
    predictor = RealTimePredictor(endpoint=endpoint_name)
    predictor.update_data_capture_config(
        data_capture_config=data_capture_config)
    sm_session.wait_for_endpoint(endpoint=endpoint_name)

    my_default_monitor = DefaultModelMonitor(
        role=role,
        instance_count=1,
        instance_type='ml.m5.xlarge',
        volume_size_in_gb=20,
        max_runtime_in_seconds=3600,
    )

    my_default_monitor.suggest_baseline(
        baseline_dataset=baseline_data_uri+'/train.csv',
        dataset_format=DatasetFormat.csv(header=True),
        output_s3_uri=baseline_results_uri,
        wait=True
    )

    baseline_job = my_default_monitor.latest_baselining_job
    schema_df = pd.io.json.json_normalize(
        baseline_job.baseline_statistics().body_dict["features"])
    constraints_df = pd.io.json.json_normalize(
        baseline_job.suggested_constraints().body_dict["features"])

    my_default_monitor.create_monitoring_schedule(
        monitor_schedule_name=mon_schedule_name,
        endpoint_input=predictor.endpoint,
        output_s3_uri=s3_report_path,
        statistics=my_default_monitor.baseline_statistics(),
        constraints=my_default_monitor.suggested_constraints(),
        schedule_cron_expression=monitor_frequency,
        enable_cloudwatch_metrics=True,

    )

    desc_schedule_result = my_default_monitor.describe_schedule()

    # list executions
    mon_executions = my_default_monitor.list_executions()
    print("We created a hourly schedule above and it will kick off executions ON the hour (plus 0 - 20 min buffer.\nWe will have to wait till we hit the hour...")

    while len(mon_executions) == 0:
        print("Waiting for the 1st execution to happen...")
        time.sleep(60)
        mon_executions = my_default_monitor.list_executions()

    # inspect a specific execution (latest execution)
    # Here are the possible terminal states and what each of them mean:
    # Completed - This means the monitoring execution completed and no issues were found in the violations report.
    # CompletedWithViolations - This means the execution completed, but constraint violations were detected.
    # Failed - The monitoring execution failed, maybe due to client error (perhaps incorrect role premissions) or infrastructure issues. Further examination of FailureReason and ExitMessage is necessary to identify what exactly happened.
    # Stopped - job exceeded max runtime or was manually stopped.

    # latest execution's index is -1, second to last is -2 and so on..
    latest_execution = mon_executions[-1]
    time.sleep(60)
    latest_execution.wait(logs=False)
    #print("Latest execution status: {}".format(latest_execution.describe()['ProcessingJobStatus']))
    #print("Latest execution result: {}".format(latest_execution.describe()['ExitMessage']))

    latest_job = latest_execution.describe()
    if (latest_job['ProcessingJobStatus'] != 'Completed'):
        print("====STOP==== \n No completed executions to inspect further. Please wait till an execution completes or investigate previously reported failures.")

    report_uri = latest_execution.output.destination

    # list the generated reports
    s3uri = urlparse(report_uri)
    report_bucket = s3uri.netloc
    report_key = s3uri.path.lstrip('/')
    #print('Report bucket: {}'.format(report_bucket))
    #print('Report key: {}'.format(report_key))

    result = s3_client.list_objects(
        Bucket=report_bucket, Prefix=report_key)
    report_files = [report_file.get("Key")
                    for report_file in result.get('Contents')]
    #print("Found Report Files:")
    #print("\n ".join(report_files))

    # get violations report
    violations = my_default_monitor.latest_monitoring_constraint_violations()
    pd.set_option('display.max_colwidth', -1)
    constraints_violations_df = pd.io.json.json_normalize(
        violations.body_dict["violations"])

    # Delete the resources after running the inspection to avoid incurring additional charges
    my_default_monitor.delete_monitoring_schedule()
    time.sleep(60)  # actually wait for the deletion
    predictor.delete_endpoint()
    predictor.delete_model()

    return {
        print(schema_df.head(10)),
        print(constraints_df.head(10)),
        print('Schedule status: {}'.format(
            desc_schedule_result['MonitoringScheduleStatus'])),
        print("Latest execution status: {}".format(
            latest_execution.describe()['ProcessingJobStatus'])),
        print("Latest execution result: {}".format(
            latest_execution.describe()['ExitMessage'])),
        print('Report Uri: {}'.format(report_uri)),
        print('Report bucket: {}'.format(report_bucket)),
        print('Report key: {}'.format(report_key)),
        print("Found Report Files:"),
        print("\n ".join(report_files)),
        print(constraints_violations_df)
    }
