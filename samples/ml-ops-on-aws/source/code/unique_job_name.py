from datetime import datetime

def lambda_handler(event, context):

    return {
        'statusCode': 200,
        'JobName': event['JobName'] + '-' + datetime.today().strftime('%Y%m%d%H%M%S')
    }
