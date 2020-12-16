import sys
import pandas as pd
import boto3
import io
from io import StringIO
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(
    sys.argv, ["S3_SOURCE", "S3_DEST", "TRAIN_KEY", "SCORE_KEY", "INFERENCE_TYPE"]
)

s3_source = args["S3_SOURCE"]
s3_dest = args["S3_DEST"]
train_key = args["TRAIN_KEY"]
score_key = args["SCORE_KEY"]
inference_type = args["INFERENCE_TYPE"]

# ---FUNCTIONS-------------------------------


def data_transform(obj, train=True):
    # Perform data transformation on training and scoring sets
    df = pd.read_csv(io.BytesIO(obj["Body"].read()), encoding="utf8")

    df = df.set_index("EmployeeNumber")

    df["BusinessTravel"].replace(
        to_replace=["Non-Travel", "Travel_Rarely", "Travel_Frequently"],
        value=[0, 1, 2],
        inplace=True,
    )
    df["Gender"].replace(to_replace=["Male", "Female"], value=[0, 1], inplace=True)
    df.replace(to_replace=["No", "Yes"], value=[0, 1], inplace=True)
    df["RatioYearsPerCompany"] = df["TotalWorkingYears"] / (
        df["NumCompaniesWorked"] + 1
    )

    cont_vars = [
        "Age",
        "DistanceFromHome",
        "MonthlyIncome",
        "PercentSalaryHike",
        "TrainingTimesLastYear",
        "RatioYearsPerCompany",
        "YearsAtCompany",
        "YearsInCurrentRole",
        "YearsSinceLastPromotion",
        "YearsWithCurrManager",
    ]

    ord_vars = [
        "BusinessTravel",
        "Education",
        "EnvironmentSatisfaction",
        "JobInvolvement",
        "JobLevel",
        "JobSatisfaction",
        "PerformanceRating",
        "RelationshipSatisfaction",
        "StockOptionLevel",
        "WorkLifeBalance",
    ]

    cat_vars = ["Department", "EducationField", "JobRole", "MaritalStatus"]

    bool_vars = ["Gender", "OverTime"]

    df_dummy = pd.get_dummies(df[cat_vars])
    cat_onehot_vars = df_dummy.columns.tolist()
    df = df.merge(df_dummy, how="left", left_index=True, right_index=True)

    if train:
        cols = ["Attrition"] + cont_vars + ord_vars + cat_onehot_vars + bool_vars
        return df[cols]
    else:
        cols = cont_vars + ord_vars + cat_onehot_vars + bool_vars
        return df[cols]


def write_dataframe_to_csv_on_s3(dataframe, bucket, filename):
    """ Write a dataframe to a CSV on S3 """
    # Create buffer
    csv_buffer = StringIO()
    # Write dataframe to buffer
    dataframe.to_csv(csv_buffer, sep=",")
    # Create S3 object
    s3_resource = boto3.resource("s3")
    # Write buffer to S3 object
    s3_resource.Object(bucket, filename).put(Body=csv_buffer.getvalue())
    print("Writing {} records to {}".format(len(dataframe), filename))


# --------------------------------------------------

s3c = boto3.client("s3")

train_obj = s3c.get_object(Bucket=s3_source, Key=train_key)
train = data_transform(train_obj, train=True)
write_dataframe_to_csv_on_s3(train, s3_dest, train_key)

# Transform scoring set if using batch inference
if inference_type == "batch":
    score_obj = s3c.get_object(Bucket=s3_source, Key=score_key)
    score = data_transform(score_obj, train=False)
    write_dataframe_to_csv_on_s3(score, s3_dest, score_key)
