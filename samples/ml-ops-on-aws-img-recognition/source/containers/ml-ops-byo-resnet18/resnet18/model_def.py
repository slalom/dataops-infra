#!/usr/bin/env python3.6

# A sample training component that trains a simple scikit-learn decision tree model.
# This implementation works in File mode and makes no assumptions about the input file names.
# Input is specified as CSV with a data point in each row and the labels in the first column.

from __future__ import print_function

import os
import json
import pickle
import sys
import traceback
import subprocess

import pandas as pd
import sklearn.model_selection as skms
import numpy as np

import tensorflow as tf
from tensorflow.keras import optimizers
from tensorflow.keras.models import Sequential, Model
from tensorflow.keras.layers import Dropout, Flatten, Dense, GlobalAveragePooling2D
import resnet_18
import logging

logging.getLogger().setLevel(logging.INFO)

# These are the paths to where SageMaker mounts interesting things in your container.

prefix = "/opt/ml/"

input_path = prefix + "input/data"
output_path = os.path.join(prefix, "output")
model_path = os.path.join(prefix, "model")

# This algorithm has a single channel of input data called 'train'. Since we run in
# File mode, the input files are copied to the directory specified here.
channel_name = "train"
train_path = os.path.join(input_path, channel_name)

WIDTH, HEIGHT, CHANNELS = int(4000 / 5), int(6000 / 5), 3
models = {
    "ResNet50": (34, tf.keras.applications.ResNet50),
    "Xception": (26, tf.keras.applications.Xception),
    "ResNet18": (0, resnet_18.ResNet18),
}


def transfer_learning_model(
    dropout,
    model_name,
    learning_rate=0.001,
    size=1,
    mpi=False,
    hvd=False,
    binary_classification=False,
    checkpoints=None,
):
    print("Starting the training.")
    try:

        non_trainable_layers, transfer_learning_model = models[model_name]

        model = transfer_learning_model(
            weights="imagenet",
            include_top=False,
            input_shape=(HEIGHT, WIDTH, CHANNELS),
            pooling="avg",
        )

        x = model.output
        predictions = Dense(3, activation="softmax")(x)
        loss_fn = "categorical_crossentropy"

        if binary_classification:
            predictions = Dense(1, activation="sigmoid")(x)
            loss_fn = "binary_crossentropy"

        if mpi:
            size = hvd.size()

        opt = tf.keras.optimizers.Adam(learning_rate=learning_rate * size)

        if mpi:
            opt = hvd.DistributedOptimizer(opt)

        model_final = tf.keras.Model(inputs=model.input, outputs=predictions)
        model_final.compile(
            optimizer=opt,
            loss=loss_fn,
            metrics=["accuracy", tf.keras.metrics.AUC(num_thresholds=50)],
        )

        if checkpoints:
            logging.info("Loading checkpoints from: " + checkpoints)
            latest = tf.train.latest_checkpoint(checkpoints)
            model_final.load_weights(latest)

        return model_final

        # save the model
        with open(os.path.join(model_path, "resnet18-model.pkl"), "wb") as out:
            pickle.dump(model_final, out, protocol=0)
            print("Training complete.")

    except Exception as e:
        # Write out an error file. This will be returned as the failureReason in the
        # DescribeTrainingJob result.
        trc = traceback.format_exc()
        with open(os.path.join(output_path, "failure"), "w") as s:
            s.write("Exception during training: " + str(e) + "\n" + trc)
        # Printing this causes the exception to be in the training job logs, as well.
        print("Exception during training: " + str(e) + "\n" + trc, file=sys.stderr)
        # A non-zero exit code causes the training job to be marked as Failed.
        sys.exit(255)
