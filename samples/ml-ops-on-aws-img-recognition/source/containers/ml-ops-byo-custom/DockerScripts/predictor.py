""" This is the file that implements a flask server to do inferences. It's the file that you will modify to
implement the scoring for your own algorithm.
"""
from __future__ import print_function

import os
import json
import logging
import pickle
from io import StringIO
import sys
import signal
import subprocess
import traceback

import argparse
import datetime
import flask

from tensorflow.keras import backend as K
from tensorflow.keras.callbacks import (
    ModelCheckpoint,
    LearningRateScheduler,
    TensorBoard,
    EarlyStopping,
    CSVLogger,
)
from sklearn.metrics import confusion_matrix, roc_curve, auc
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tensorflow as tf
import shap

import dataset
import train
import s3_utils

prefix = "/opt/ml/"
model_path = os.path.join(prefix, "model")
bucket_path = "s3://${aws_s3_bucket.data_store.id}/input_data/"
hyperparams_path = prefix + "input/config/hyperparameters.json"

with open(hyperparams_path) as _in_file:
    hyperparams_dict = json.load(_in_file)
batch_size = float(hyperparams_dict["batch-size"])
test_data_generator = dataset.read_dataset(
    bucket_path + "test",
    batch_size=batch_size,
    train_mode=False,
    dataset=False,
    shuffle=False,
    binary_classification=True,
)
class_indices = dict()
for k, v in test_data_generator.class_indices.items():
    class_indices[v] = k


class ScoringService(object):

    model = None  # Where we keep the model when it's loaded

    @classmethod
    def get_model(cls):

        """Get the model object for this instance, loading it if it's not already loaded."""

        if cls.model == None:
            with open(os.path.join(model_path, "resnet18-model.pkl"), "rb") as inp:
                cls.model = pickle.load(inp)
        return cls.model

    @classmethod
    def predict(cls, input):
        """For the input, do the predictions and return them.
        """
        clf = cls.get_model()

        predictions = clf.predict(test_data_generator)
        target_labels = np.array(test_data_generator.classes)
        # print(predictions)
        # print([int(i[0] > 0.6869423) for i in predictions])
        # print(target_labels)
        # print(
        #    confusion_matrix(
        #        target_labels[: len(predictions)],
        #        [int(i[0] > 0.6869423) for i in predictions],
        #    )
        # )
        fpr, tpr, alarm_thresholds = roc_curve(
            target_labels[: len(predictions)], [i[0] for i in predictions]
        )
        test_auc = auc(fpr, tpr)
        # print(auc)

        pred_len = len(predictions)
        pd.DataFrame(
            {
                "filenames": test_data_generator.filenames[:pred_len],
                "label": [class_indices[i] for i in target_labels[:pred_len]],
                "label_val": target_labels[:pred_len],
                "predictions": [i[0] for i in predictions],
            }
        ).to_csv("test_predictions.csv")
        pd.DataFrame(
            {"fpr": fpr, "tpr": tpr, "alarm_thresholds": alarm_thresholds}
        ).to_csv("roc.csv")

        return predictions

    @classmethod
    def shap(cls, input):
        """For the input, do the predictions and return them.

        Args:
            input (a pandas dataframe): The data on which to do the predictions. There will be
                one prediction per row in the dataframe"""
        clf = cls.get_model()
        # background = train_data_generator
        # return shap values
        explainer = shap.DeepExplainer(clf, input)

        return explainer.shap_values(input)


# The flask app for serving predictions
app = flask.Flask(__name__)


@app.route("/ping", methods=["GET"])
def ping():
    """Determine if the container is working and healthy. In this sample container, we declare
    it healthy if we can load the model successfully."""
    health = (
        ScoringService.get_model() is not None
    )  # You can insert a health check here

    status = 200 if health else 404
    return flask.Response(response="\n", status=status, mimetype="application/json")


@app.route("/invocations", methods=["POST"])
def pred():

    train_data = None
    test_data = None
    dropout = None
    batch_size = None

    # Do the prediction
    predictions = ScoringService.predict(dropout, batch_size)

    # Save viz data
    shap_values = ScoringService.shap(test_data)

    # rehspae the shap value array and test image array for visualization
    shap_numpy = [np.swapaxes(np.swapaxes(s, 1, -1), 1, 2) for s in shap_values]
    test_numpy = np.swapaxes(np.swapaxes(test_data.numpy(), 1, -1), 1, 2)

    # Convert from numpy back to CSV
    out = StringIO()
    pd.DataFrame(shap_numpy).to_csv(out, header=True, index=True)
    result = out.getvalue()

    return flask.Response(response=result, status=200, mimetype="text/csv")
