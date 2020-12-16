"""
This function will load model prediction outputs from S3 bucket to a selected database platform such as PostgreSQL.
"""

# import boto3
import psycopg2


def handler(event, context):
    # Load csv to Postgres

    # first need to enable the prediction outputs loading process
    is_predictive_db_enabled = event.get("is_predictive_db_enabled", False)
    if not is_predictive_db_enabled:
        return

    # user defined database related variables
    host = event.get("db_host", None)
    db_name = event.get("db_name", None)
    db_user = event.get("db_user", None)
    db_password = event.get("db_password", None)
    s3_csv = event.get("s3_csv", None)

    connection_string = (
        f"dbname='{db_name}' user='{db_user}' host='{host}' password='{db_password}'"
    )

    pg_load(connection_string, s3_csv)


def pg_load(connection, file_path, table_name="model_stats"):
    try:
        conn = psycopg2.connect(connection)
        print("Connecting to Database")
        cur = conn.cursor()
        # Open the input file for copy
        # s3_client = boto3.client("s3")
        f = open(file_path, "r")
        # Load csv file into the table
        cur.copy_expert(
            "COPY {} FROM STDIN WITH CSV QUOTE e'\x01' DELIMITER e'\x02'".format(
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
