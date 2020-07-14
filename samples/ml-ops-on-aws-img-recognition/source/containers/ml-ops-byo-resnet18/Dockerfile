FROM python

RUN pip install scipy
RUN pip install pillow
RUN pip install sklearn
RUN pip install numpy
RUN pip install opencv-python
RUN pip install pandas
RUN pip install scikit-image
RUN pip install boto3
RUN pip install awscli
RUN pip install SimpleITK

# Copies the processing code inside the container
RUN mkdir ./src/
COPY background_removal.py connectedlabels_functions.py sitk_registration_functions.py linepartitioning_functions.py main.py mbkm_clusters.npy preprocessing_images_functions.py s3_utils.py text_removal_functions.py ./src/
RUN chmod -R +x ./src/


# Defines model.py as script entrypoint
# ENTRYPOINT 'python ./src/main.py'
