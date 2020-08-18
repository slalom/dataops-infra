FROM tensorflow/tensorflow:2.1.0-gpu-py3

RUN pip install sagemaker-containers
RUN pip install scipy
RUN pip install pillow

# Copies the training code inside the container
#COPY model.py /opt/ml/code/model.py
#COPY s3_utils.py /opt/ml/code/s3_utils.py

# Defines model.py as script entrypoint
#ENV SAGEMAKER_PROGRAM model.py

#RUN mkdir -p /opt/ml/code
#WORKDIR /opt/ml/code
WORKDIR /source/containers/ml-ops-byo-custom/DockerScripts/
COPY ./* /

ENTRYPOINT [ "python3" ]
# CMD [ "" ]

# Example: entrypoint=["python3.8"], cmd=["module_def.py"] => "python3.8 module_def.py"
# docker run myorg/myimage              => "python3.8 module_def.py"
# docker run myorg/myimage predictor.py => "python3.8 predictor.py"
# docker run --entrypoint bash myorg/myimage  => "bash module_def.py"

# docker run --entrypoint bash mytestimage
# docker run mytestimage predictor.py
