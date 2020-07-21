FROM tensorflow/tensorflow:2.1.0-gpu-py3

RUN pip install sagemaker-containers
RUN pip install scipy
RUN pip install pillow

# Copies the training code inside the container
#COPY model.py /opt/ml/code/model.py
#COPY s3_utils.py /opt/ml/code/s3_utils.py

# Defines model.py as script entrypoint
#ENV SAGEMAKER_PROGRAM model.py


