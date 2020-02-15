import boto3
import urllib
import aws_lambda_logging
from slalom.dataops import io


def lambda_handler(event, context):
    aws_lambda_logging.setup(level='DEBUG')
    landed_s3_file = get_changed_s3_file(event, context)
    target_adls_folder = os.environ["ADLS_TARGET_ROOT"]
    io.upload_file(landed_s3_file, target_adls_folder)


def get_secret(secret):
    secret_manager = boto3.client('secretsmanager')
    response = secret_manager.get_secret_value(SecretId=secret)
    return response['SecretString']


def get_changed_s3_file(event):
    """Return the full s3 path of the file mentioned within the lambda event"""
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    path = urllib.unquote_plus(event["Records"][0]["s3"]["object"]["key"])
    return f"s3://{bucket}/{path}"
