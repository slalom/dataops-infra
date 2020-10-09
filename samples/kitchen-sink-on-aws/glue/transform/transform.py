"""Sample Glue Tranform"""

import sys
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import SQLContext

args = getResolvedOptions(sys.argv, ["S3_DATA_BUCKET"])

bucket = args["S3_DATA_BUCKET"]

sc = SparkContext()
sqlContext = SQLContext(sc)
glueContext = GlueContext(SparkContext.getOrCreate())
spark = sqlContext.sparkSession

df = spark.read.csv("s3a://noaa-ghcn-pds/csv/2020.csv", inferSchema=True)
df.createOrReplaceTempView("temp_table")
df_clean = spark.sql(
    """
    SELECT *
    FROM temp_table
    """
)
df_clean.write.mode("overwrite").csv("s3://{}/out/test_outfile.csv".format(bucket))
