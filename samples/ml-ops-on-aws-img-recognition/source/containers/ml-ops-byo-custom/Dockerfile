FROM python:3.8

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

# Set some environment variables. PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly. PYTHONDONTWRITEBYTECODE
# keeps Python from writing the .pyc files which are unnecessary in this case. We also update
# PATH so that the train and serve programs are found when the container is invoked.

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program:${PATH}"

# Copies the processing code inside the container
COPY background_removal.py connectedlabels_functions.py sitk_registration_functions.py linepartitioning_functions.py mbkm_clusters.npy preprocessing_images_functions.py s3_utils.py text_removal_functions.py ./source/containers/ml-ops-byo-custom/
RUN chmod -R +x ./source/containers/ml-ops-byo-custom/

# Set up the program in the image
COPY DockerScripts /opt/program
WORKDIR /opt/program


