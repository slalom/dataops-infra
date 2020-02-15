import boto3
import gnupg
import aws_lambda_logging
import urllib
import os
from slalom.dataops import io


def lambda_handler(event, context):
    aws_lambda_logging.setup(level='DEBUG')
    landed_pgp_file = get_changed_s3_file(event, context)
    target_folder = os.environ["S3_DECRYPT_PATH_ROOT"]
    os.system('ls -la /tmp/')
    decrypt_pgp_file(landed_pgp_file, target_folder)
    os.system('ls -la /tmp/')


def unpack_tools(tool_name):
    # Change permission for executing tools
    os.system(f"cp -r ./tools /tmp/")
    os.system(f"unpack /tmp/tools/{tool_name}*")
    os.system(f"ls -la /tmp/")
    os.system(f"chmod -R 755 /tmp/{tool_name}/*")


def decrypt_pgp_file(pgp_file_path, target_folder):
    gpg = gnupg.GPG(gnupghome='/tmp', gpgbinary="/tmp/tools/gnupg/gnupg")
    key_data = get_secret('Public-Key') + '\n' + secret_function('Private-Key')
    import_result = gpg.import_keys(key_data)

    filename=(source_file.split('/')[-1])

    tmp_dir = "/tmp/"
    tmp_pgp_file = f{tmp_dir}/{filename}"
    tmp_decrypted_file = tmp_pgp_file.rstrip(".pgp")

    io.download_file(f"s3://{bucket}/{source_file}", tmp_pgp_file)
    with open(tmp_pgp_file, 'rb') as pgp_file:
        gpg.decrypt_file(pgp_file, output=tmp_decrypted_file)
    io.upload_file(tmp_decrypted_file, target_folder)


def get_secret(secret):
    secret_manager = boto3.client('secretsmanager')
    response = secret_manager.get_secret_value(SecretId=secret)
    return response['SecretString']


def get_changed_s3_file(event):
    """Return the full s3 path of the file mentioned within the lambda event"""
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    path = urllib.unquote_plus(event["Records"][0]["s3"]["object"]["key"])
    return f"s3://{bucket}/{path}"
