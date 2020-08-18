import os
import boto3  # Python library for Amazon API
import botocore
from botocore.exceptions import ClientError
import shutil
from os import listdir
from os.path import isfile, join
import matplotlib.pyplot as plt
from copy import deepcopy
import cv2
from preprocessing_images_functions import *
import logging

bucket_name = 'cornell-mammogram-images'
s3 = boto3.resource('s3')
s3_client = boto3.client('s3')
bucket = s3.Bucket(bucket_name)


def download_dir(dirname, prefix='curated_dataset'):
    url = 's3://cornell-mammogram-images/' + prefix + '/' + dirname + '/'
    # => ['s3:', '', 'sagemakerbucketname', 'data', ...
    url_parts = url.split("/")
    remote_directory_name = prefix + '/' + url_parts[-2]
    if dirname == '':
        url = 's3://cornell-mammogram-images/' + prefix + '/'
        remote_directory_name = prefix

    print(url)
    try:
        # Create an S3 client
        for obj in bucket.objects.filter(Prefix=remote_directory_name):
            print(obj.key)
            if not os.path.exists(os.path.dirname(obj.key)):
                os.makedirs(os.path.dirname(obj.key))
            s3_client.download_file(bucket_name, obj.key, obj.key)
            #print('Downloading {} to {}'.format(url, obj.key))
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            print('The object {} does not exist in bucket {}'.format(
                obj.key, bucket_name))
        else:
            raise


def delete_dir(dirname):
    shutil.rmtree(dirname)
    os.mkdir(dirname)


def plot_and_return_binary_imageset(images, title):
    binaries = []
    #fig, ax = plt.subplots(nrows=len(images), ncols=1, figsize=(20,20))
    for i in range(len(images)):
        a = deepcopy(images[i])
        a[a > 0] = 255
        binaries.append(a)

    return binaries


def upload_image_dir(files, filenames):
    for i in range(len(files)):
        try:
            response = s3_client.upload_file(
                files[i], bucket_name, filenames[i])
        except ClientError as e:
            logging.error(e)


def save_images(images, filenames):
    for i in range(len(images)):
        cv2.imwrite(filenames[i], images[i])
