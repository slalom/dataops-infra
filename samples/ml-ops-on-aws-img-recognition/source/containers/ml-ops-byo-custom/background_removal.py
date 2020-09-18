# This function removes background on all x-ray images

from os import listdir
from os.path import isfile, join
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from preprocessing_images_functions import *
import cv2
from sklearn.cluster import MiniBatchKMeans
from scipy.spatial import distance
import math


def init_artifact_mask(image, bounds):
    """
    Initialize an image mask that identifies artifacts known prior to clustering using provided color boundaries.

    Args:
    image (np.array):
    bounds (tuple or list): list containing length 2 elements representing lower and upper color bounds in La*b* space

    Returns:
    artifact_map (np.array): an array identifying which pixels are artifacts
    """

    artifact_map = np.zeros((image.shape[0], image.shape[1]), dtype=np.uint8)
    for lower, upper in bounds:
        temp_map = cv2.inRange(image, lower, upper)
        artifact_map = cv2.bitwise_or(artifact_map, temp_map)

    return artifact_map.astype(np.bool)


def find_closest_centroids(src_centroids, tgt_centroids, plot=False):
    """
    Find the closest source centroids to target centroids in La*b* color space using Euclidean distance.

    Args:
      src_centroids (np.array): array of color centroids of shape (k,3) for the source image
      tgt_centroids (np.array): array of color centroids of shape (k,3) for the target image
      plot (bool): flag to plot target centroids next to source centroids

    Returns:
      matching_clusters (list): list of (target_cluster, source_cluster) pairs, indicating the closest centroid matches
    """
    # lists for holding output
    matching_clusters = []

    # find the source cluster with the closest centroid to each cluster in the target image
    for k in range(tgt_centroids.shape[0]):
        distances = []
        for j in range(len(src_centroids)):
            src_centroid_loc = src_centroids[j]
            distances.append(
                distance.euclidean(tgt_centroids[k], src_centroid_loc)
            )  # calculate distances
        matching_clusters.append(
            (k, np.argmin(distances), distances[np.argmin(distances)])
        )  # find closest centroid

    return matching_clusters


def mammogram_clustering(
    images,
    params,
    artifact_mask=True,
    cluster_to_remove=-1,
    second_round_cluster=-1,
    mbkm_centroids=None,
    plot=True,
):
    artifact_masks = [init_artifact_mask(i, params["color_bounds"]) for i in images]
    valid_img_pixels = np.concatenate(
        [
            images[i][artifact_masks[i] == False].reshape(-1, 1)
            for i in range(len(images))
        ]
    )

    mbkm = MiniBatchKMeans(
        n_clusters=params["k"],
        random_state=2316,
        init=params["init_centroids"],
        batch_size=params["batch_size"],
    )
    mbkm.fit(valid_img_pixels)
    labelled_images = [
        mbkm.predict(i.reshape(-1, 1)).reshape(i.shape[0], i.shape[1]) for i in images
    ]
    for i in range(len(labelled_images)):
        labelled_images[i][artifact_masks[i]] = params["k"] + 1

    ll_mbkm = None
    if cluster_to_remove != -1:
        cluster_pairs = find_closest_centroids(mbkm.cluster_centers_, mbkm_centroids)
        cluster_to_remove = cluster_pairs[cluster_to_remove][1]
        if second_round_cluster != -1:
            second_round_cluster = cluster_pairs[second_round_cluster][1]
            if second_round_cluster != cluster_to_remove:
                if (
                    np.where(labelled_images[0] == second_round_cluster)[1][0]
                    > np.where(labelled_images[0] == cluster_to_remove)[1][0]
                ):
                    tmp = cluster_to_remove
                    cluster_to_remove = second_round_cluster
                    second_round_cluster = tmp

                pixels = [
                    images[i][labelled_images[i] == second_round_cluster].reshape(-1, 1)
                    for i in range(len(images))
                ]

                ll_mbkm = MiniBatchKMeans(
                    n_clusters=2,
                    random_state=2316,
                    init=params["init_centroids"],
                    batch_size=params["batch_size"],
                )
                ll_mbkm.fit(np.concatenate(pixels))
                ll_labels = [ll_mbkm.predict(i) for i in pixels]

                cluster_pairs = find_closest_centroids(
                    ll_mbkm.cluster_centers_, mbkm.cluster_centers_, plot=params["plot"]
                )

                for i in range(len(labelled_images)):
                    labelled_images[i][labelled_images[i] == second_round_cluster] = [
                        cluster_to_remove
                        if j == cluster_pairs[cluster_to_remove][1]
                        else params["k"]
                        for j in ll_labels[i]
                    ]

        for i in range(len(images)):
            images[i][labelled_images[i] == cluster_to_remove] = 0

    if plot:
        fig, (ax, ax2, ax3) = plt.subplots(nrows=1, ncols=3, figsize=(15, 15))
        ax.imshow(labelled_images[0], cmap=plt.gray)
        ax2.imshow(images[0], cmap=plt.gray)
        ax3.imshow(artifact_masks[0], cmap=plt.gray)

    return (images, labelled_images, mbkm, ll_mbkm)


if __name__ == "__main__":
    params = {
        "k": 6,
        "batch_size": 100,
        "init_centroids": "k-means++",
        "threshold": 20.0,
        "color_bounds": [(75, 255)],
        "plot": False,
    }
    # update this readinpath to the folder where image files are stored
    readinpath = "../data/cases/case0001/"
    onlyfiles = [f for f in listdir(readinpath) if ~isfile(f)]
    images = [
        image_preprocess(cv2.imread(readinpath + i, cv2.IMREAD_GRAYSCALE))
        for i in onlyfiles
    ]
    # print(find_closest_centroids(np.load('./notebooks/mbkm_clusters.npy'),np.load('./notebooks/ll_mbkm_clusters.npy')))
    # mammogram_clustering(images, params=params, cluster_to_remove=2, second_round_cluster=0, mbkm_centroids=np.load('./notebooks/mbkm_clusters.npy'), plot=True)
    images, labelled_images, mbkm, ll_mbkm = mammogram_clustering(
        images,
        params=params,
        cluster_to_remove=2,
        second_round_cluster=0,
        mbkm_centroids=np.load("./notebook/mbkm_clusters.npy"),
        plot=True,
    )
