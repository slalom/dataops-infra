import sys
import pandas as pd
import boto3
import io
from io import StringIO
import os
from os.path import isfile, join
import matplotlib.pyplot as plt
import numpy as np
import cv2
import background_removal
import connectedlabels_functions
import linepartitioning_functions
from preprocessing_images_functions import *
from sitk_registration_functions import *
import text_removal_functions
import botocore
from botocore.exceptions import ClientError
import s3_utils
import pickle
from io import BytesIO
import logging

# ---FUNCTIONS-------------------------------
metrics_dump = []


def symmetry_image_data_generator(images, filenames, prev_clusters, params):
    images_background_removed = []
    for j in range(len(images)):
        (
            new_images,
            labelled_images,
            mbkm,
            ll_mbkm,
        ) = background_removal.mammogram_clustering(
            [images[j]],
            params=params,
            cluster_to_remove=0,
            second_round_cluster=4,
            mbkm_centroids=prev_clusters,
            plot=False,
        )
        images_background_removed.append(new_images[0])

    masks = [
        text_removal_functions.find_valid_bboxes(j) for j in images_background_removed
    ]

    images_text_removed = []
    for i in range(len(images_background_removed)):
        images_text_removed.append(
            text_removal_functions.overwrite_pixels(
                images_background_removed[i], masks[i]
            )
        )

    images_text_removed = [
        np.flip(images_text_removed[j], 1)
        if "RIGHT_CC" in filenames[j]
        else images_text_removed[j]
        for j in range(len(filenames))
    ]
    images_text_removed = [
        np.flip(images_text_removed[j], 1)
        if "MLO" in filenames[j] and not pectoral_on_left(images_text_removed[j])
        else images_text_removed[j]
        for j in range(len(filenames))
    ]
    l_cc = images_text_removed[
        filenames.index([i for i in filenames if "LEFT_CC" in i][0])
    ]
    r_cc = images_text_removed[
        filenames.index([i for i in filenames if "RIGHT_CC" in i][0])
    ]
    l_mlo = images_text_removed[
        filenames.index([i for i in filenames if "LEFT_MLO" in i][0])
    ]
    r_mlo = images_text_removed[
        filenames.index([i for i in filenames if "RIGHT_MLO" in i][0])
    ]
    mlo_filename = "/".join(
        filenames[0].split("/")[:-1]
    ) + "/MLO_SYMMETRY_IMAGE_{}.png".format(filenames[0].split("/")[-2])
    cc_filename = "/".join(
        filenames[0].split("/")[:-1]
    ) + "/CC_SYMMETRY_IMAGE_{}.png".format(filenames[0].split("/")[-2])

    flipped_right, mlo_symmetry_image, mlo_lr_metrics = generate_registered_images(
        l_mlo, r_mlo
    )
    flipped_right, cc_symmetry_image, cc_lr_metrics = generate_registered_images(
        l_cc, r_cc
    )
    mlo_lr_metrics["file"] = mlo_filename
    cc_lr_metrics["file"] = cc_filename
    print(mlo_lr_metrics)
    print(cc_lr_metrics)

    symmetry_images = [mlo_symmetry_image, cc_symmetry_image, r_mlo, l_mlo, l_cc, r_cc]
    symmetry_images = [
        image_height_width_standardization(i, 6000, 4000, orientation="left")
        for i in symmetry_images
    ]
    symmetry_filenames = [
        mlo_filename,
        cc_filename,
        [i for i in filenames if "RIGHT_MLO" in i][0],
        [i for i in filenames if "LEFT_MLO" in i][0],
        [i for i in filenames if "LEFT_CC" in i][0],
        [i for i in filenames if "RIGHT_CC" in i][0],
    ]
    return (symmetry_images, symmetry_filenames)


def complementary_breast_data_generator(images, filenames, prev_clusters, params):
    removed_pectoral = None
    try:
        print("Removing pectoral.")
        removed_pectoral = [
            connectedlabels_functions.remove_pectoralmuscle(images[j], 2, 3, 10)
            if "MLO" in filenames[j]
            else images[j]
            for j in range(len(filenames))
        ]
        removed_pectoral = [
            removed_pectoral[j]
            if ("MLO" in filenames[j] and not is_black_image(removed_pectoral[j]))
            else images[j]
            for j in range(len(filenames))
        ]
    except Exception:
        logging.exception(
            "Got exception on remove_pectoral_muscle on case {}".format(j)
        )
        removed_pectoral = images

    images_background_removed = []
    for j in range(len(removed_pectoral)):
        (
            new_images,
            labelled_images,
            mbkm,
            ll_mbkm,
        ) = background_removal.mammogram_clustering(
            [removed_pectoral[j]],
            params=params,
            cluster_to_remove=0,
            second_round_cluster=4,
            mbkm_centroids=prev_clusters,
            plot=False,
        )
        images_background_removed.append(new_images[0])

    masks = [
        text_removal_functions.find_valid_bboxes(j) for j in images_background_removed
    ]
    images_background_removed = [
        text_removal_functions.overwrite_pixels(image, mask)
        for image, mask in zip(images_background_removed, masks)
    ]

    images_background_removed = [
        image_height_width_standardization(i, 6000, 4000, orientation="left")
        for i in images_background_removed
    ]
    return (images_background_removed, filenames)


def main(complementary_breast=False):
    bucket_name = "cornell-mammogram-images"
    s3 = boto3.resource("s3")
    s3_client = boto3.client("s3")
    bucket = s3.Bucket(bucket_name)

    cases = list(
        set(
            [
                i.key.split("/")[2]
                for i in bucket.objects.all()
                if "case" in i.key
                and "full_dataset/curated_dataset" in i.key
                and ".npy" not in i.key
                and ".pkl" not in i.key
                and ".csv" not in i.key
                and i.key.split("/")[2] != "full_dataset"
            ]
        )
    )
    print("Number of cases: ", str(len(cases)))

    vm_number = int(os.getenv("AWS_BATCH_JOB_ARRAY_INDEX", 0))
    num_vms = 25

    cases_to_process = (len(cases) // num_vms) + 1
    cases = cases[
        vm_number * cases_to_process : (vm_number * cases_to_process + cases_to_process)
    ]
    print("Cases to process", len(cases), cases)

    path = "./"

    params = {
        "k": 7,
        "batch_size": 100,
        "init_centroids": "k-means++",
        "threshold": 20.0,
        "color_bounds": [(75, 255)],
        "plot": False,
    }
    for i in cases:
        save_path = (
            "full_dataset/train_data/"
            if complementary_breast
            else "full_dataset/symmetry_images/"
        )
        if len([j for j in bucket.objects.all() if save_path + i in j.key]) != 0:
            continue

        s3_utils.download_dir(i, prefix="full_dataset/curated_dataset")
        onlyfiles = [
            "./full_dataset/curated_dataset/" + i + "/" + j
            for j in os.listdir("./full_dataset/curated_dataset/" + i)
            if ~isfile(j)
            and not is_black_image(
                cv2.imread(
                    "./full_dataset/curated_dataset/" + i + "/" + j,
                    cv2.IMREAD_GRAYSCALE,
                )
            )
        ]
        images = [cv2.imread(j, cv2.IMREAD_GRAYSCALE) for j in onlyfiles]
        s3_utils.delete_dir("./full_dataset/curated_dataset/" + i)

        images = [
            image_preprocess(images[j])
            if "MLO" in onlyfiles[j]
            else image_preprocess(images[j], left_crop=0.03, right_crop=0.97)
            for j in range(len(onlyfiles))
        ]

        mbkm_clusters = np.load(
            BytesIO(
                s3_client.get_object(
                    Bucket=bucket_name, Key="full_dataset/mbkm_clusters.npy"
                )["Body"].read()
            )
        )

        try:
            images_background_removed, onlyfiles = (
                complementary_breast_data_generator(
                    images, onlyfiles, mbkm_clusters, params
                )
                if complementary_breast
                else symmetry_image_data_generator(
                    images, onlyfiles, mbkm_clusters, params
                )
            )
            s3_utils.save_images(
                [images_background_removed[j] for j in range(len(onlyfiles))],
                filenames=onlyfiles,
            )
            s3_utils.upload_image_dir(
                onlyfiles,
                filenames=[
                    save_path + "/".join(str(j).split("/")[3:]) for j in onlyfiles
                ],
            )
            s3_utils.delete_dir("./full_dataset/curated_dataset/" + (i))
        except Exception:
            logging.exception("Got exception on symmetry case {}".format(i))


# --------------------------------------------------
