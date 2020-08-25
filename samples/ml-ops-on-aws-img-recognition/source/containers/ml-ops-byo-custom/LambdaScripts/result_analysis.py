import os
import boto3  # Python library for Amazon API
import botocore
from botocore.exceptions import ClientError
import pandas as pd


# for taking CSVs of the case description and prediction
# this is after there is analysis on alarm_thresholds and that the column predicted val in the predictions csv exists
# the filenames largely depend on referencing what is available in s3 bucket


def get_bucketfilenames(bucket_name):
    s3 = boto3.resource("s3")
    s3_client = boto3.client("s3")
    bucket = s3.Bucket(bucket_name)

    bucket_datalist = []
    for my_bucket_object in bucket.objects.all():
        bucket_datalist.append(my_bucket_object.key)

    cleansed_bucket_datalist = [f for f in bucket_datalist if "full_dataset" in f]
    bucket_filesdf = pd.DataFrame(cleansed_bucket_datalist, columns=["rawfilenames"])
    return bucket_filesdf


def parse_bucketfilesdf(bucket_filesdf):
    bucket_filesdf["folder0"] = bucket_filesdf["rawfilenames"].str.split("/").str[0]
    bucket_filesdf["folder1"] = bucket_filesdf["rawfilenames"].str.split("/").str[1]
    bucket_filesdf["folder2"] = bucket_filesdf["rawfilenames"].str.split("/").str[2]
    bucket_filesdf["filename"] = bucket_filesdf["rawfilenames"].str.split("/").str[3]
    bucket_filesdf["casenum"] = bucket_filesdf.folder2.str.extract("(\d+)")

    bucket_filesdf["casenum"] = pd.to_numeric(
        bucket_filesdf["casenum"], errors="coerce"
    )
    bucket_filesdf = bucket_filesdf.dropna(subset=["casenum"])

    bucket_filesdf = bucket_filesdf[bucket_filesdf["folder1"] == "curated_dataset"]
    return bucket_filesdf


def merge_restructure_df(case_desc, preds, bucket_filesdf):

    preds["imagename"] = preds["filenames"].str.split("/").str[1]
    filesnames_preds = bucket_filesdf.merge(
        preds, how="right", left_on="filename", right_on="imagename"
    )
    allmerged = filesnames_preds.merge(case_desc, left_on="casenum", right_on="case_id")

    return allmerged


def collect_most_exemplary_images(num_examples, allmerged_select):
    # returns the paths for the highest scoring by probability for 0 and 1
    most_exemplary_0 = allmerged_select.sort_values("predictions", ascending=True)[
        "rawfilenames"
    ][:num_examples].values
    most_exemplary_1 = allmerged_select.sort_values("predictions", ascending=False)[
        "rawfilenames"
    ][:num_examples].values
    return most_exemplary_1, most_exemplary_0


def collect_least_exemplary_1(num_examples, allmerged_select):
    # takes allmerged_select to filter for those that are barely considered class1
    # returns examples that are barely class 1 but should be and also the falsely considered class ones
    # these types of functions are useful for analyzing false positives and the confusions that the model is having
    definition_1 = ["benign", "normal"]
    # those that are suppose to 1 but barely are 1
    barely_exemplary_1_truedf = allmerged_select[
        (allmerged_select["predicted_val"] == 1)
        & (allmerged_select["cancer_status"].isin(definition_1))
    ].sort_values("predictions", ascending=True)
    barely_exemplary_1_true = barely_exemplary_1_truedf["rawfilenames"][
        :num_examples
    ].values

    # the lowest pred vals right above cutoff and near false positive point that are not 1 and should be 0
    barely_exemplary_1_falsedf = allmerged_select[
        (allmerged_select["predicted_val"] == 1)
        & (~allmerged_select["cancer_status"].isin(definition_1))
    ].sort_values("predictions", ascending=True)
    barely_exemplary_1_false = barely_exemplary_1_falsedf["rawfilenames"][
        :num_examples
    ].values
    return barely_exemplary_1_true, barely_exemplary_1_false


def collect_least_exemplary_0(num_examples, allmerged_select):
    definition_0 = ["cancer"]

    barely_exemplary_0_truedf = allmerged_select[
        (allmerged_select["predicted_val"] == 0)
        & (allmerged_select["cancer_status"].isin(definition_0))
    ].sort_values("predictions", ascending=False)
    barely_exemplary_0_true = barely_exemplary_0_truedf["rawfilenames"][
        :num_examples
    ].values

    # those that are barely class 0 that should be class 1
    barely_exemplary_0_falsedf = allmerged_select[
        (allmerged_select["predicted_val"] == 0)
        & (~allmerged_select["cancer_status"].isin(definition_0))
    ].sort_values("predictions", ascending=False)
    barely_exemplary_0_false = barely_exemplary_0_falsedf["rawfilenames"][
        :num_examples
    ].values
    return barely_exemplary_0_true, barely_exemplary_0_false


def download_fileslist(dl_prefix_pathlocation, download_list, bucket_name):
    # download_list must have full file path
    s3 = boto3.resource("s3")
    s3_client = boto3.client("s3")
    bucket = s3.Bucket(bucket_name)

    for dl_file in download_fileslist:
        bucket.download_file(dl_file, dl_prefix_pathlocation + dl_file.split("/")[-1])


def main():
    case_desc = pd.read_csv("case_descriptions(2).csv")
    preds = pd.read_csv("predictions.csv")
    dl_prefix_pathlocation = "/breast_cancer_detection/"

    url = "s3://cornell-mammogram-images/"
    # => ['s3:', '', 'sagemakerbucketname', 'data', ...
    url_parts = url.split("/")
    bucket_name = url_parts[2]

    bucket_filesdf = get_bucketfilenames(bucket_name)
    bucket_filesdf = parse_bucketfilesdf(bucket_filesdf)

    allmerged = merge_restructure_df(case_desc, preds, bucket_filesdf)
    allmerged_select = allmerged[
        [
            "rawfilenames",
            "filename",
            "casenum",
            "predictions",
            "predicted_val",
            "centered_predictions",
            "label_val",
            "label",
            "case_id",
            "age",
            "density",
            "cancer_status",
            "left_abnormality",
            "right_abnormality",
        ]
    ].drop_duplicates()

    num_examples = 20
    most_exemplary_1, most_exemplary_0 = collect_most_exemplary_images(
        num_examples, allmerged
    )

    barely_exemplary_1_true, barely_exemplary_1_false = collect_least_exemplary_1(
        num_examples, allmerged_select
    )
    barely_exemplary_0_true, barely_exemplary_0_false = collect_least_exemplary_0(
        num_examples, allmerged_select
    )

    download_fileslist(dl_prefix_pathlocation, barely_exemplary_0_true, bucket_name)
