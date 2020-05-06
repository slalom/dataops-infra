FROM python:3.6-slim-stretch


RUN apt-get -y update && apt-get install -y --no-install-recommends \
    nginx \
    ca-certificates \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set some environment variables. PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly. PYTHONDONTWRITEBYTECODE
# keeps Python from writing the .pyc files which are unnecessary in this case. We also update
# PATH so that the train and serve programs are found when the container is invoked.

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program:${PATH}"

# Here we get all python packages.
RUN pip install flask gevent gunicorn future
RUN pip install numpy==1.17.3 pandas==0.25.2 scipy==1.3.1 scikit-learn==0.22.2 xgboost==1.0.2 shap==0.35.0 && rm -rf /root/.cache
RUN apt-get -y purge --auto-remove git

# Set up the program in the image
COPY xgboost /opt/program
WORKDIR /opt/program