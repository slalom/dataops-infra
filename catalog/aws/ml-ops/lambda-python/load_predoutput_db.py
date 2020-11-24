"""
This function will load model prediction outputs from S3 bucket to a selected database platform such as PostgreSQL.
"""

import boto3
import psycopg2

# first need to enable the prediction outputs loading process
enable_predictive_db = "${var.enable_predictive_db}"

# user defined database related variables
dbname = "${var.predictive_db_name}"
user = "${var.predictive_db_admin_user}"
host = "${module.postgres.endpoint}"
password = "${var.predictive_db_admin_password}"

connection_string = (
    f"dbname='{predictive_db_name}' user='{user}' host='{host}' password='{password}'"
)

S3_url = "s3://${aws_s3_bucket.ml_bucket[0].id}/" + "${var.test_key}"

client = boto3.client("s3")


def pg_load(connection, table_name, file_path):

    if enable_predictive_db == "true":
        try:
            conn = psycopg2.connect(connection)
            print("Connecting to Database")
            cur = conn.cursor()
            # Open the input file for copy
            f = open(file_path, "r")
            # Load csv file into the table
            cur.copy_expert(
                "copy {} FROM STDIN WITH CSV quote e'\x01' delimiter e'\x02'".format(
                    table_name
                ),
                f,
            )
            cur.execute("commit;")
            print("Loaded data into {}".format(table_name))
            conn.close()
            print("DB connection closed.")

        except Exception as e:
            print("Error {}".format(str(e)))


def handler(event, context):
    # Load csv to Postgres
    pg_load(connection_string, predictive_db_name, S3_url)
