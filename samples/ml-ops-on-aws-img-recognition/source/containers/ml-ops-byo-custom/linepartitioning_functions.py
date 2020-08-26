import preprocessing_images_functions
import connectedlabels_functions

from os import listdir
from os.path import isfile, join
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


from skimage import data, measure
from skimage.filters import threshold_otsu, rank, gaussian
import skimage.io as skio
import skimage as ski
from skimage import filters
from skimage.morphology import disk
from skimage.filters.rank import median
import numpy.ma as ma


def find_maxcolumnvalues(blobs_labels):
    # find the max position for column values for each row that is still part of blob_labels1 values
    maxcolvals = []
    for row in np.arange(0, blobs_labels.shape[0]):
        # assuming the first blob labeled as 1 is the encompassing blob of pectoral muscle
        matchingarray = np.where(blobs_labels[row, :] == 1)[0]

        if len(matchingarray) > 1:
            maxcol = matchingarray.max()
            maxcolvals.append(maxcol)
        else:
            maxcolvals.append(0)
    return maxcolvals


def generate_inflectionpoints(binarymask):
    # returns where the inflection points should be to fit the line
    # top down is a lot more reliable
    # bottom up was tested but there is extreme variation in the shapes for bottom up
    # for now the bottom up is returned for consideration and plotting
    # if it fails to find a good inflection point it will put the inflection point at 0,0

    maxcolvals = find_maxcolumnvalues(binarymask)
    diffmask = abs(np.diff(maxcolvals)) > 1

    if len(np.where(diffmask == 1)[0] > 0):
        indexinflection_topdown_y = np.where(diffmask == 1)[0][0]
        indexinflection_topdown_x = maxcolvals[indexinflection_topdown_y]
    else:
        indexinflection_topdown_y = 0
        indexinflection_topdown_x = 0

    # bottom up portion where it didn't work and was inconsistent

    # maxcolvals.reverse()

    # diffmask_reverse=np.diff(maxcolvals)>1

    # if len(np.where(diffmask==1)[0]>0):

    #     indexinflection_bottomup=np.where(diffmask_reverse==1)[0][0]
    #     indexinflection_bottomup_y=len(maxcolvals)-indexinflection_bottomup
    #     indexinflection_bottomup_x=maxcolvals[indexinflection_bottomup_y]
    # else:
    #     indexinflection_bottomup_y=0
    #     indexinflection_bottomup_x=0
    # plt.scatter(indexinflection_bottomup_x, indexinflection_bottomup_y, s=200, c='red', marker='o')

    return indexinflection_topdown_x, indexinflection_topdown_y


def leaveout_underlineportion(cropped_image, intercept, slope):
    # removes the portion of the image on the other side of the cropping line
    # cropping line is fit based on inflection points

    linecropped_image = []
    for row in np.arange(1, cropped_image.shape[0]):
        collimit = (row - intercept) / slope

        if collimit > 0:
            leaveout_portion = np.zeros(int(round(collimit)))
            kept_portion = cropped_image[row, int(round(collimit)) :]
            imageline = np.concatenate([leaveout_portion, kept_portion])
            linecropped_image.append(imageline)
        else:
            linecropped_image.append(cropped_image[row, :])
    return linecropped_image


def find_topinflectionpoint(blobs_labels):
    toprow = blobs_labels[0, :]
    # coords=np.where(blobs_labels==1)
    # maxbottomrowpoint=coords[0].max() #this proved to be varying too much between images
    maxtoprowpoint = np.where(toprow == 1)[0].max()
    return maxtoprowpoint


def generate_linefit(
    maxtoprowpoint, indexinflection_topdown_x, indexinflection_topdown_y
):
    # given points of interest generate and return the line coefficients
    x = [maxtoprowpoint, indexinflection_topdown_x]
    y = [0, indexinflection_topdown_y]

    fit = np.polyfit(x, y, 1)
    slope = fit[0]
    intercept = fit[1]

    return intercept, slope


def plot_muscleremoval_inflectionpoints(
    outputimage_filesavelocation,
    savefilename,
    indexinflection_topdown_x,
    indexinflection_topdown_y,
    maxtoprowpoint,
    blobs_labels,
    cropped_image,
):
    # these are plots to study the inflection points and line drawing
    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(16, 16))
    ax = axes.ravel()
    ax[0] = plt.subplot(1, 3, 1)
    ax[1] = plt.subplot(1, 3, 2)
    ax[2] = plt.subplot(1, 3, 3)

    ax[0].imshow(blobs_labels, cmap="nipy_spectral")
    ax[0].scatter(maxtoprowpoint, 0, s=200, c="red", marker="o")
    # ax[0].scatter(0, maxbottomrowpoint, s=200, c='red', marker='o')
    ax[0].scatter(
        indexinflection_topdown_x, indexinflection_topdown_y, s=200, c="red", marker="o"
    )
    # ax[0].scatter(indexinflection_bottomup_x, indexinflection_bottomup_y, s=200, c='red', marker='o')
    ax[0].set_title("inflection points")
    ax[0].axis("off")

    # linefitting
    intercept, slope = generate_linefit(
        maxtoprowpoint, indexinflection_topdown_x, indexinflection_topdown_y
    )

    line_x = np.linspace(0, maxtoprowpoint, 10)
    line_y = slope * line_x + intercept

    ax[1].plot(line_x, line_y, linewidth=2, color="r")
    ax[1].imshow(cropped_image, cmap="nipy_spectral")
    ax[1].scatter(maxtoprowpoint, 0, s=200, c="red", marker="o")
    # ax[1].scatter(0, maxbottomrowpoint, s=200, c='red', marker='o')
    ax[1].scatter(
        indexinflection_topdown_x, indexinflection_topdown_y, s=200, c="red", marker="o"
    )
    # ax[2].scatter(indexinflection_bottomup_x, indexinflection_bottomup_y, s=200, c='red', marker='o')
    ax[1].set_title("line drawn with inflection points")
    ax[1].axis("off")

    linecroppedimage = leaveout_underlineportion(cropped_image, intercept, slope)
    ax[2].imshow(linecroppedimage, cmap="nipy_spectral")
    ax[2].set_title("removed under the inflection point lines")
    ax[2].axis("off")

    fig.savefig(outputimage_filesavelocation + savefilename + ".png")
    plt.close()


# SPECIFIC TO SAVE FILE STRUCTURE
def find_files(path):
    onlyfiles = [f for f in listdir(path) if ~isfile(f)]
    # for now only focus on LEFTMLO VIEWS
    return onlyfiles


def check_breasttissue_linemethod(binarymask, image):
    # takes the binarymask that has the suspected pectoral muscle portion and checks if the image should be processed with line method
    # binarymask is the array with region 1 suspected as muscle and marked with True
    # returns the linecropped image version if the percentout
    # if the line method didn't work sometimes it doesnt it will return a blank image

    maxtoprowpoint = find_topinflectionpoint(binarymask)
    indexinflection_topdown_x, indexinflection_topdown_y = generate_inflectionpoints(
        binarymask
    )
    intercept, slope = generate_linefit(
        maxtoprowpoint, indexinflection_topdown_x, indexinflection_topdown_y
    )

    beyondinflectionpoint = binarymask[
        indexinflection_topdown_y:, indexinflection_topdown_x:
    ]
    percent_outside = beyondinflectionpoint.sum() / binarymask.sum()

    if slope != 0:  # sometimes it has a lot of issues
        linecroppedimage = leaveout_underlineportion(image, intercept, slope)
    else:
        linecroppedimage = np.zeros((image.shape[0], image.shape[1]))

    return (
        percent_outside,
        linecroppedimage,
        indexinflection_topdown_x,
        indexinflection_topdown_y,
        maxtoprowpoint,
    )

