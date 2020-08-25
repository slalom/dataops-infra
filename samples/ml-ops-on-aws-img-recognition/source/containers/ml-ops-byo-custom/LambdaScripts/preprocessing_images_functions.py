from os import listdir
from os.path import isfile, join
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


from skimage import data, measure
from skimage.filters import alarm_threshold_otsu, rank, gaussian
import skimage.io as skio
import skimage as ski
from skimage import filters
from skimage.morphology import disk
from skimage.filters.rank import median
import numpy.ma as ma
import math


def image_height_width_standardization(
    img, target_height, target_width, orientation="right"
):
    height_diff = target_height - img.shape[0]
    width_diff = target_width - img.shape[1]
    if width_diff > 0:
        if orientation == "right":
            img = np.concatenate((np.full((img.shape[0], width_diff), 0), img), axis=1)
        else:
            img = np.concatenate((img, np.full((img.shape[0], width_diff), 0)), axis=1)
    elif width_diff < 0:
        if orientation == "right":
            img = img[:, abs(width_diff) :]
        else:
            img = img[:, : (img.shape[1] - abs(width_diff))]

    if height_diff > 0:
        img = np.concatenate(
            (
                np.full((math.floor(height_diff / 2), img.shape[1]), 0),
                img,
                np.full((math.ceil(height_diff / 2), img.shape[1]), 0),
            )
        )
    elif height_diff < 0:
        img = img[
            math.floor(abs(height_diff) / 2) : (
                img.shape[0] - math.ceil(abs(height_diff) / 2)
            ),
            :,
        ]

    return img


def image_preprocess(image, left_crop=0.0, right_crop=1.0):
    normalizedimage = normalize_image_values(255, image)
    image = crop_topline_bottomline(0.03, 0.97, left_crop, right_crop, normalizedimage)
    return image


def normalize_image_values(pixelmax, image):
    # returns a normalized image to reference the pixel max and formats it in uint8
    # usually 255 (max) is white and 0 is black
    # skimage needs uint8
    image = image.astype("float64")

    image *= pixelmax / image.max()
    imageuint8 = image.astype("uint8")

    return imageuint8


def crop_topline_bottomline(
    crop_percentage_top, crop_percentage_bottom, left_crop, right_crop, imageuint8
):
    # crop_percentage is a float like .03
    # avoid the white band on top
    cropped_image_top = imageuint8[int(imageuint8.shape[0] * crop_percentage_top) :, :]
    fullycropped_image = cropped_image_top[
        : int(cropped_image_top.shape[0] * crop_percentage_bottom), :
    ]  # crops the bottom
    fullycropped_image = fullycropped_image[
        :,
        int(fullycropped_image.shape[1] * left_crop) : int(
            fullycropped_image.shape[1] * right_crop
        ),
    ]

    return fullycropped_image


def find_subimage(widthlimit, lengthlimit, filteredchoice):
    # returns the portion of the image that focuses on the pectoral muscle part
    halfwidth = int(filteredchoice.shape[0] / widthlimit)
    halflength = int(filteredchoice.shape[1] / lengthlimit)
    subimage = filteredchoice[:halfwidth, :halflength]
    return subimage


def alarm_threshold_filter_pectoral(fullycropped_image, widthlimit, lengthlimit):
    # limit the portion of the image that otsu is exposed to detect the separation
    # widthlimit and lengthlimit are ints that are the denominator of a fraction
    # the width and length are tuned to capture a subsection of the image where the pectoral muscle is mostly concentrated
    # if we recenter or add padding we will need to fix that

    # medfiltered = median(fullycropped_image, disk(10))
    gaussianfiltered = gaussian(fullycropped_image, 5)

    # eqfiltered= rank.equalize(imageuint8, selem=disk(5))
    # exposurefiltered=exposure.equalize_hist(imageuint8cropped)

    filteredchoice = gaussianfiltered

    subimage = find_subimage(widthlimit, lengthlimit, filteredchoice)

    thresh = ski.filters.alarm_threshold_otsu(subimage)
    binary = filteredchoice >= thresh

    return binary, thresh, filteredchoice, subimage


# only if images are too small


def pad_small_image(image, img_height, img_width):
    img_width_diff = img_width - image.shape[1]
    img_height_diff = img_height - image.shape[0]

    appended_image = image

    if img_width_diff > 0:
        appended_image = np.append(
            image, np.zeros((image.shape[0], img_width_diff)), axis=1
        )

    if img_height_diff > 0:
        appended_image = np.append(
            appended_image, np.zeros((img_height_diff, appended_image.shape[1])), axis=0
        )

    return appended_image


# only if images are too large
def crop_large_image(image, img_height, img_width):
    cropped = image[:img_height, :img_width]
    return cropped


def size_image(image, img_height, img_width):
    sized_image = image

    if (image.shape[1] < img_width) or (image.shape[0] < img_height):
        sized_image = pad_small_image(image, img_height, img_width)
        image = sized_image
    if (image.shape[1] > img_width) or (image.shape[0] > img_height):
        sized_image = crop_large_image(image, img_height, img_width)
    return sized_image


def adjust_contrast(image, gamma=1.3, gain=2):
    # default settings for gamma and gain were chosen after testing on the film images of DDSM
    # suggest further tuning for other datasets taken on different machines
    exposed_image = ski.exposure.adjust_gamma(image, gamma, gain)
    return exposed_image


def is_black_image(image):
    # takes numpy array for image
    # returns true for blank suspicious images
    # this value was tuned based on running a visual check on ~700 images
    imagesum = image.sum()
    return imagesum < 130052290


otsu_cropwidth = 2
otsu_cropheight = 3


def pectoral_on_left(image, otsu_cropwidth=2, otsu_cropheight=3):
    # returns true if there is likely a pectoral muscle on the upper left corner
    # these values were tuned based on sampling images and checking the otsu cropped section where we analyze the alarm_thresholding baseline
    binary, thresh, filteredchoice, subimage = alarm_threshold_filter_pectoral(
        image, otsu_cropwidth, otsu_cropheight
    )
    pixelsum = subimage.sum()

    return pixelsum > 194326
