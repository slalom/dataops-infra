"""
This is a simply function to return the machine learning problem type 
"""

problem = "${var.data_drift_ml_problem_type}"


def lambda_hanlder(event, context):
    response = problem
    return response

