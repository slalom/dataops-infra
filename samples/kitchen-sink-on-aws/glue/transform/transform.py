# PySpark Script for AWS Glue ETL

# setup environment
import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType
from pyspark.sql import SQLContext

args = getResolvedOptions(sys.argv, ["S3_DATA_BUCKET"])

bucket = args["S3_DATA_BUCKET"]

sc = SparkContext()
sqlContext = SQLContext(sc)
spark = sqlContext.sparkSession

# create dynamic frame from raw data stored on s3
inputPop = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={
        "path": "s3a://covid19-lake/static-datasets/csv/CountyPopulation/County_Population.csv"
    },
    format="csv",
    format_options={},
    transformation_ctx="",
)

# create dataframe for each table
inputPop_df = inputPop.toDF()

# create table to query from each dataframe
inputPop_df.createOrReplaceTempView("inputPop_table")

# write SQL statements to clean the data
inputPop_clean = spark.sql(
    """
    SELECT
        id2 as fips,
        County as county_name,
        State as state_name,
        Population Estimate 2018 as est_population
    FROM inputPop_table
    WHERE upper(state) = 'COLORADO'
    """
)

# write out the files to curated folder
inputPop_clean.write.mode("overwrite").parquet(
    "s3://{}/CURATED/County_Population_CURATED.csv".format(bucket)
)
