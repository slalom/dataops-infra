from preprocessing_images_functions import *
import linepartitioning_functions

import numpy.ma as ma
from os import listdir
from os.path import isfile, join
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import skimage.io as skio
import logging
from skimage import filters


def generate_connected_regions(binary, blob_sigmasetting):
    # filters with a gaussian filter
    # returns a matrix with designated labels for the regions that are connected vs separate
    # sigma is an int that designates how hard to blur the binary features

    im = filters.gaussian(binary, blob_sigmasetting)  # sigma= l / (3 * n))
    blobs = im > 0.9 * im.mean()

    blobs_labels = measure.label(blobs, background=0)

    return blobs_labels


def generate_connectedlabels_variables(image, otsu_cropwidth, otsu_cropheight, blob_sigmasetting):
    # takes an image and processes it to return the original image with 0 filled in where the region should be excluded
    # also returns the thresholded binary image for inflection point processing

    #normalizedimage=normalize_image_values(255, image)
    #cropped_image=crop_topline_bottomline(topcrop_percentage, bottomcrop_percentage, normalizedimage)

    binary, thresh, filteredchoice, subimage = threshold_filter_pectoral(
        image, otsu_cropwidth, otsu_cropheight)

    blobs_labels = generate_connected_regions(binary, blob_sigmasetting)

    # orignal image with filter of pectoral muscle
    mx = ma.masked_array(image, blobs_labels == 1)

    image_withmask = mx.filled(0)

    return image_withmask, binary, blobs_labels, thresh, filteredchoice, subimage


def plot_connectedlabels_partition(image, thresh, filteredchoice, binary, blobs_labels,
                                   subimage,  image_withmask,
                                   plot_filesavelocation, savefilename):
    fig, axes = plt.subplots(nrows=2, ncols=3, figsize=(16, 16))
    ax = axes.ravel()
    ax[0] = plt.subplot(2, 3, 1)
    ax[1] = plt.subplot(2, 3, 2)
    ax[2] = plt.subplot(2, 3, 3, sharex=ax[0], sharey=ax[0])
    ax[3] = plt.subplot(2, 3, 4)
    ax[4] = plt.subplot(2, 3, 5)
    ax[5] = plt.subplot(2, 3, 6)
    #ax[6] = plt.subplot(3, 3, 7)
    #ax[7] = plt.subplot(3, 3, 8)

    ax[0].imshow(image, cmap=plt.cm.gray)
    ax[0].set_title('Original')
    ax[0].axis('off')

    ax[1].hist(filteredchoice.ravel(), bins=256)
    ax[1].set_title('Histogram')
    ax[1].axvline(thresh, color='r')

    ax[2].imshow(binary, cmap=plt.cm.gray)
    ax[2].set_title('Thresholded')
    ax[2].axis('off')

    ax[3].imshow(blobs_labels, cmap='nipy_spectral')
    ax[3].axis('off')
    ax[3].set_title('Connected Labels')

    ax[4].imshow(image_withmask, cmap='nipy_spectral')
    ax[4].set_title('connected part removed')
    ax[4].axis('off')

    ax[5].imshow(subimage, cmap='nipy_spectral')
    ax[5].set_title('subimage for otsu')

    fig.savefig(plot_filesavelocation+savefilename+'.png')
    # CHANGE THIS TO BE SAVING TO THE BUCKET

    plt.close()


def plot_pectoralmuscle_segmentation(chosen_method, image, thresh, filteredchoice, binarymask,
                                     subimage, image_withmask, indexinflection_topdown_x,
                                     indexinflection_topdown_y, maxtoprowpoint, linecroppedimage):

    fig, axes = plt.subplots(nrows=2, ncols=3, figsize=(16, 16))
    ax = axes.ravel()
    ax[0] = plt.subplot(2, 3, 1)
    ax[1] = plt.subplot(2, 3, 2)
    ax[2] = plt.subplot(2, 3, 3, sharex=ax[0], sharey=ax[0])
    ax[3] = plt.subplot(2, 3, 4)
    ax[4] = plt.subplot(2, 3, 5)
    ax[5] = plt.subplot(2, 3, 6)

    ax[0].imshow(image, cmap='nipy_spectral')
    ax[0].set_title('Original')
    ax[0].axis('off')

    ax[1].hist(filteredchoice.ravel(), bins=256)
    ax[1].set_title('Histogram')
    ax[1].axvline(thresh, color='r')

    ax[2].imshow(binarymask, cmap=plt.cm.gray)
    ax[2].set_title('Blob - pectoral muscle')
    ax[2].scatter(maxtoprowpoint, 0, s=80, c='red', marker='o')
    ax[2].scatter(indexinflection_topdown_x,
                  indexinflection_topdown_y, s=80, c='red', marker='o')
    ax[2].axis('off')

    ax[3].imshow(subimage, cmap='nipy_spectral')
    ax[3].set_title('subimage for otsu')

    ax[4].imshow(image_withmask, cmap='nipy_spectral')
    ax[4].set_title('connected part removed')
    if chosen_method == 'connected':
        plt.setp(ax[4].spines.values(), color='red', linewidth=4)

    ax[5].imshow(linecroppedimage, cmap='nipy_spectral')
    ax[5].set_title('linecropped image')
    if chosen_method == 'linecrop':
        plt.setp(ax[5].spines.values(), color='red', linewidth=4)

    # plt.close() #saves memory


def remove_pectoralmuscle(image, otsu_cropwidth, otsu_cropheight, blob_sigmasetting):
    # takes a numpy black and white image that is already cropped and has letters taken out, and background normalized

    # topcrop_percentage is default set to 1 in generate_connectedlabels_variables but not the cropping function crop_topline_bottomline
    # image to draw line processing
    image_withmask, binary, blobs_labels, thresh, filteredchoice, subimage = generate_connectedlabels_variables(
        image, otsu_cropwidth, otsu_cropheight, blob_sigmasetting)
    blobs_label1 = blobs_labels == 1

    percent_outside,  linecroppedimage, indexinflection_topdown_x, indexinflection_topdown_y, maxtoprowpoint = check_breasttissue_linemethod(
        blobs_label1, image)

    if (percent_outside > .1) & (np.array(linecroppedimage).sum() != 0):
        image_nopectoralmuscle = linecroppedimage
        chosen_method = 'linecrop'
    else:
        image_nopectoralmuscle = image_withmask
        chosen_method = 'connected'

    return np.vstack(image_nopectoralmuscle)


def main():
    blob_sigmasetting = 10
    otsu_cropwidth = 2
    otsu_cropheight = 3

    # image example
    image = skio.imread(
        'background_corrected_two_kmeans_example_output.png',  as_gray=True)
    # assume this is in the preprocess step for MLO that are right sided
    image = np.flip(image, 1)
    origimage_leftindex = np.where(image > 0)[0][0]
    toppadding_removed = image[origimage_leftindex:, :]
    plt.imshow(toppadding_removed)
    image = toppadding_removed
    # end of getting image

    image_withmask, binary, blobs_labels, thresh, filteredchoice, subimage = generate_connectedlabels_variables(
        image, otsu_cropwidth, otsu_cropheight, blob_sigmasetting)
    # this mask has true where the pixel should be removed
    binarymask = blobs_labels == 1
    percent_outside,  linecroppedimage, indexinflection_topdown_x, indexinflection_topdown_y, maxtoprowpoint = check_breasttissue_linemethod(
        binarymask, image)

    # this is a current setting for having 10 percent of the pixels in my suspicious range
    # this parameter may be tuned in the future if we get more images
    if (percent_outside > .1) & (np.array(linecroppedimage).sum() != 0):
        image_nopectoralmuscle = linecroppedimage
        chosen_method = 'linecrop'
    else:
        image_nopectoralmuscle = image_withmask
        chosen_method = 'connected'

    np.save(image_muscleremoved_npyimagepath +
            savefilename, image_nopectoralmuscle)
    # change for saving in s3 bucket

    plot_pectoralmuscle_segmentation(chosen_method, image, thresh, filteredchoice, binarymask,
                                     subimage, image_withmask, indexinflection_topdown_x,
                                     indexinflection_topdown_y, maxtoprowpoint, linecroppedimage)
