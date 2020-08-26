import SimpleITK as sitk
import numpy as np
from preprocessing_images_functions import *
import os
import cv2


def generate_fit_transform(
    fixed_image,
    moving_image,
    initial_transform,
    learningRate=0.5,
    numberOfIterations=200,
    convergenceMinimumValue=1e-6,
    convergenceWindowSize=10,
):
    registration_method = sitk.ImageRegistrationMethod()

    # Similarity metric settings.
    registration_method.SetMetricAsMattesMutualInformation(numberOfHistogramBins=50)
    registration_method.SetMetricSamplingStrategy(registration_method.RANDOM)
    registration_method.SetMetricSamplingPercentage(0.05, 1234)

    registration_method.SetInterpolator(sitk.sitkLinear)

    # Optimizer settings.
    registration_method.SetOptimizerAsGradientDescent(
        learningRate=learningRate,
        numberOfIterations=numberOfIterations,
        convergenceMinimumValue=convergenceMinimumValue,
        convergenceWindowSize=convergenceWindowSize,
    )
    registration_method.SetOptimizerScalesFromJacobian()

    # Setup for the multi-resolution framework.
    registration_method.SetShrinkFactorsPerLevel(shrinkFactors=[4, 2, 1])
    registration_method.SetSmoothingSigmasPerLevel(smoothingSigmas=[2, 1, 0])
    registration_method.SmoothingSigmasAreSpecifiedInPhysicalUnitsOn()

    # Don't optimize in-place, we would possibly like to run this cell multiple times.
    registration_method.SetInitialTransform(initial_transform, inPlace=False)

    # Connect all of the observers so that we can perform plotting during registration.
    # registration_method.AddCommand(sitk.sitkStartEvent, start_plot)
    # registration_method.AddCommand(sitk.sitkEndEvent, end_plot)
    # registration_method.AddCommand(sitk.sitkMultiResolutionIterationEvent, update_multires_iterations)
    # registration_method.AddCommand(sitk.sitkIterationEvent, lambda: plot_values(registration_method))

    final_transform = registration_method.Execute(
        sitk.Cast(fixed_image, sitk.sitkFloat32),
        sitk.Cast(moving_image, sitk.sitkFloat32),
    )

    return final_transform, registration_method


def generate_transformed_image(fixed_image, moving_image):
    # returns the array form of the moving_image transformed and also the difference between the transformed_image and fixed_image
    initial_transform = sitk.CenteredTransformInitializer(
        fixed_image,
        moving_image,
        sitk.Euler2DTransform(),
        sitk.CenteredTransformInitializerFilter.GEOMETRY,
    )

    moving_resampled = sitk.Resample(
        moving_image,
        fixed_image,
        initial_transform,
        sitk.sitkLinear,
        0.0,
        moving_image.GetPixelID(),
    )

    final_transform, registration_method = generate_fit_transform(
        fixed_image, moving_image, initial_transform
    )

    moving_resampled = sitk.Resample(
        moving_image,
        fixed_image,
        final_transform,
        sitk.sitkLinear,
        0.0,
        moving_image.GetPixelID(),
    )
    moving_resampled_arr = sitk.GetArrayFromImage(moving_resampled)
    fixed_image_arr = sitk.GetArrayFromImage(fixed_image)

    differenced_images = moving_resampled_arr - fixed_image_arr

    abs_differenced_images = np.absolute(differenced_images)
    return (
        moving_resampled_arr,
        abs_differenced_images,
        final_transform,
        registration_method,
    )


def resample(image, final_transform):
    inverse_transform = final_transform.GetInverse()
    # Output image Origin, Spacing, Size, Direction are taken from the reference
    # image in this call to Resample

    reference_image = image
    interpolator = sitk.sitkLinear
    default_value = 0.0
    return sitk.Resample(
        image,
        reference_image,
        inverse_transform,
        interpolator,
        default_value,
        reference_image.GetPixelID(),
    )


def crop_artifacts(img_arr, intensity_threshold=128.0):

    # create artifact mask
    mask = np.where(img_arr > intensity_threshold, 1.0, 0.0)

    img_arr_copy = img_arr[:, :]

    ### row/horizontal artifact removal ###
    artifact_remains = True
    relative_threshold = intensity_threshold
    while artifact_remains:
        # Step 1: Find first non-background column (starting from leftmost columns)
        colsums = np.sum(mask, 0)  # "horizontal" sum
        min_idx = np.min(np.nonzero(colsums))
        # only grab first half of values, if it's in the bottom half it will be a vertical artifact, and taken care of later
        first_nonzero_vector = img_arr_copy[: int(img_arr_copy.shape[0] / 2), min_idx]

        # Step 2: Find location of relatively intense pixels in the list
        vals, counts = np.unique(first_nonzero_vector, return_counts=True)
        freq = sorted(list(zip(vals, counts)))
        intense_vals = [val[0] for val in freq if val[0] > intensity_threshold]
        # check if intense values exist, if not, all artifacts should be removed.
        if len(intense_vals) == 0:
            artifact_remains = False
            break
        relative_threshold = intense_vals[0]
        min_crop_idx = np.min(
            np.nonzero(np.where(first_nonzero_vector >= intense_vals[0], 1, 0))
        )
        max_crop_idx = np.max(
            np.nonzero(np.where(first_nonzero_vector >= intense_vals[0], 1, 0))
        )

        # Step 3: Remove all pixels below the maximum crop index & minimum original indexes found, bc they're artifacts
        img_arr_copy = img_arr_copy[max_crop_idx + 1 :, min_idx:]

    # Step 4: Check if too much was removed (column-oriented artifact versus row-oriented)
    original_area = img_arr.shape[0] * img_arr.shape[1]
    new_area = img_arr_copy.shape[0] * img_arr_copy.shape[1]
    if new_area <= original_area * 0.5:
        print("Inverse orientation required.")
        img_arr_copy = img_arr[:, :]
        artifact_remains = True
        relative_threshold = intensity_threshold
        while artifact_remains:
            # Step 1: Find first intense-pixel row (starting from topmost row)
            rowsums = np.sum(mask, 1)
            min_y_idx = np.min(np.nonzero(rowsums))
            first_nonzero_row = img_arr_copy[min_y_idx, :]

            # Step 2: Find location of relatively intense pixels in the column
            vals, counts = np.unique(first_nonzero_row, return_counts=True)
            freq = sorted(list(zip(vals, counts)))
            # print(freq[-10:])
            intense_vals = [val[0] for val in freq if val[0] > intensity_threshold]
            # print(intense_vals)
            # check if intense values exist, if not, all artifacts should be removed.
            if len(intense_vals) == 0:
                artifact_remains = False
                break
            relative_threshold = intense_vals[0]
            min_x_idx = np.min(
                np.nonzero(np.where(first_nonzero_row >= intense_vals[0], 1, 0))
            )
            max_x_idx = np.max(
                np.nonzero(np.where(first_nonzero_row >= intense_vals[0], 1, 0))
            )

            # Step 3: Remove all pixels below the maximum y & minimum x indexes found, bc they're artifacts
            img_arr_copy = img_arr_copy[
                min_y_idx:, max_x_idx + 1 :,
            ]

    #     #  clean up errant pixels
    #     img_arr_copy = np.where(img_arr_copy.astype(int) > relative_threshold, 0.0, img_arr)

    return img_arr_copy


def remove_artifacts(differenced_image, final_transform):
    # differenced image is the numpy array version

    # conver to SITK Image object
    differenced_image = sitk.GetImageFromArray(differenced_image)
    # apply the inverse transformation
    inverse_transformed_difference_img = resample(differenced_image, final_transform)
    # convert to array
    inverse_transformed_difference_img = sitk.GetArrayFromImage(
        inverse_transformed_difference_img
    )
    # crop artifact pixels
    cropped_differenced_img = crop_artifacts(inverse_transformed_difference_img)

    return cropped_differenced_img


def generate_registered_images(fixed_image_arr, moving_image_arr):
    # takes in a fixed_image_arr and moving_image_arr for now let's designate left to fixed and right to be moving in array form
    # the fixed_image and moving_image_arr
    # returns moving_resammpled_arr which is the right breast after translation in array form
    # returns diff_image_noartifacts which is the overlayed and subtracted image in array form to be fed into the model
    # returns metrics which is a dictionary of metrics to show the severity of the registration
    # severity of registration is quantified by the difference in arrays before and after the registration process

    fixedImageFile = "./fixed_image_arr.png"
    movingImageFile = "./moving_image_arr.png"

    cv2.imwrite(fixedImageFile, fixed_image_arr)
    cv2.imwrite(movingImageFile, moving_image_arr)
    fixed_image = sitk.ReadImage((fixedImageFile), sitk.sitkFloat32)
    moving_image = sitk.ReadImage((movingImageFile), sitk.sitkFloat32)
    os.remove(fixedImageFile)
    os.remove(movingImageFile)
    # fixed_image =  sitk.GetImageFromArray(fixed_image_arr)
    # moving_image= sitk.GetImageFromArray(moving_image_arr)

    (
        moving_resampled_arr,
        differenced_images,
        final_transform,
        registration_method,
    ) = generate_transformed_image(fixed_image, moving_image)

    # metrics
    # after processing the fixed and moving image should be the same size so subtracting it should work
    fixed_arr = sitk.GetArrayFromImage(fixed_image)
    moving_arr = sitk.GetArrayFromImage(moving_image)
    moving_arr_sized = size_image(moving_arr, fixed_arr.shape[0], fixed_arr.shape[1])

    # euclidean distance between moving resampled and orig moving image
    moving_dist = np.linalg.norm(moving_resampled_arr - moving_arr_sized)
    breast_diff_dist = np.linalg.norm(fixed_arr - moving_arr_sized)

    final_metricval = registration_method.GetMetricValue()
    rotation_angle = final_transform.GetParameters()[0]
    trans_x = final_transform.GetParameters()[1]
    trans_y = final_transform.GetParameters()[2]

    # put this into CSV?
    metrics = {
        "final_metric": final_metricval,
        "rotation_angle": rotation_angle,
        "trans_x": trans_x,
        "trans_y": trans_y,
        "moving_dist": moving_dist,
        "init_breast_diff_dist": breast_diff_dist,
    }

    diff_image_noartifacts = remove_artifacts(differenced_images, final_transform)

    return moving_resampled_arr, diff_image_noartifacts, metrics
