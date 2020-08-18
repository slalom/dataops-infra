import cv2
import numpy as np
from matplotlib import path
import matplotlib.pyplot as plt
import matplotlib.patches as patches

### COPIED FROM ORIGINAL FILE BC WEIRD SKIMAGE.IO BUG ###


def normalize_image_values(pixelmax, image):
    # returns a normalized image to reference the pixel max and formats it in uint8
    # usually 255 (max) is white and 0 is black
    # skimage needs uint8
    image = image.astype('float64')

    image *= pixelmax/image.max()
    imageuint8 = image.astype('uint8')

    return imageuint8


def crop_topline_bottomline(crop_percentage_top, crop_percentage_bottom, imageuint8):
    # crop_percentage is a float like .03
    # avoid the white band on top
    cropped_image_top = imageuint8[int(
        imageuint8.shape[0]*crop_percentage_top):, :]
    fullycropped_image = cropped_image_top[:int(
        cropped_image_top.shape[0]*crop_percentage_bottom), :]  # crops the bottom

    return fullycropped_image
###################################################################


def preprocess_image(image, bot_pct=.95, top_pct=.03):

    image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    image = normalize_image_values(255, image)
    image = crop_topline_bottomline(top_pct, bot_pct, image)
    return image


def build_index_image(img):

    y_dim = np.arange(0, img.shape[0], step=1)
    x_dim = np.arange(0, img.shape[1], step=1)
    index_img = np.array(np.meshgrid(x_dim, y_dim)).T.reshape(-1, 2)
    return index_img


def find_valid_bboxes(img, n_contours=10, area_threshold=1000.0, plot=False):
    # using cv2, find the bounding boxes of the text characters present in the images
    binary_img = binarize_image(img)
    index_img = build_index_image(img)

    # find image contours
    contours, _ = cv2.findContours(
        binary_img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2:]

    # calculate bbox info for each contours
    bbox_data = [(c, cv2.minAreaRect(c)) for c in contours]

    # filter based on area threshold
    bbox_data = [b for b in bbox_data if calc_bbox_area(
        b[1]) >= area_threshold]

    # sort by bbox area
    bbox_data.sort(key=lambda bbox_tup: calc_bbox_area(bbox_tup[1]))

    # filter to the top n_contours
    # last contour is associated with the tissue, so remove it
    bbox_data = bbox_data[-n_contours:-1]

    # finally, calculate the actual bbox coordinates for the valid bboxes
    bbox_coords = [get_bbox_coordinates(b[1]) for b in bbox_data]

    # instantiate polygon mask representation of image (i.e. the boolean matrix)
    polygon_mask = np.zeros((img.shape[0], img.shape[1]), dtype=bool)

    if plot:
        _, axes = plt.subplots(1, 3)
        axes[0].imshow(img)
        axes[1].imshow(img)
    for vertices in bbox_coords:
        p = path.Path(vertices)
        polygon_mask = np.logical_or(polygon_mask, p.contains_points(
            index_img).reshape(img.shape[0], img.shape[1], order='F').astype(np.uint8))

        if plot:
            # draw red rectangle around region
            rect = patches.Polygon(vertices, fill=False, edgecolor='white')
            axes[0].add_patch(rect)
            axes[0].set_xticks([])
            axes[0].set_yticks([])

            # fill in region with bg color
            fill = patches.Polygon(vertices, fill=True,
                                   facecolor='black', edgecolor='black')
            axes[1].add_patch(fill)
            axes[1].set_xticks([])
            axes[1].set_yticks([])

    if plot:
        # plot polygon mask
        axes[2].imshow(polygon_mask)
        axes[2].set_xticks([])
        axes[2].set_yticks([])
        plt.tight_layout()
        # plt.savefig('test.png')
        plt.show()

    return polygon_mask


def overwrite_pixels(img, polygon_mask, bg=0):

    img[polygon_mask] = bg

    return img


def calc_bbox_area(bbox_info):

    w, h = bbox_info[1]
    return w*h


def get_bbox_coordinates(bbox_rect):

    # get the min area rect encapsulating the contour
    box = np.int0(cv2.boxPoints(bbox_rect))

    return box


def binarize_image(img, bg=15):
    # create a boolean mask of all non-black pixels, then convert to integers
    # the binary image is the input to the findContours cv2 function
    # TODO grayscale format not rgb

    binary_img = np.where(img > bg, 1, 0).astype(np.uint8)

    return binary_img


def main():
    img_path = "c:/Users/jake.evans/Downloads/image_3.png"
    write_output = True

    img = cv2.imread(img_path)
    img = preprocess_image(img)
    mask = find_valid_bboxes(img)
    new_img = overwrite_pixels(img, mask)

    if write_output:
        prefix = '/'.join(img_path.split('/')[:-1])+'/'
        newfilename = prefix + \
            img_path.split('/')[-1].split('.')[0]+'_example_output.png'
        cv2.imwrite(newfilename, new_img)


if __name__ == '__main__':
    main()
