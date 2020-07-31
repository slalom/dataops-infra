"""
This function will load model prediction outputs from S3 bucket to PostgreSQL database. 
"""

import boto3
import psycopg2

dbname = "ml_ops_img_reg_db"
user = "pgadmin"
host = "${module.postgres.endpoint}"
password = "1234asdf"

connection_string = "dbname='{}' user='{}' host='{}' password='{}'".format(
    dbname, user, host, password
)

S3_url = "s3://${aws_s3_bucket.data_store.id}/input_data/score/"

client = boto3.client("s3")
name = "img_prediction"


def pg_load(connection, table_name, file_path):
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
    pg_load(connection_string, name, S3_url)

