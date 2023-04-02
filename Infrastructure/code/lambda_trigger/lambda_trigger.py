import json
import boto3
import requests


# request to all 3 api endpoints based on the event bridge trigger
def invoke_lambda_twitter_api():
    # lambda function to invoke Twitter api through api gateway
    response = requests.post('https://womkny0mg9.execute-api.us-east-1.amazonaws.com/test/twitter')
    return response


def invoke_lambda_reddit_api():
    # lambda function to invoke reddit api through api gateway
    response = requests.post('https://womkny0mg9.execute-api.us-east-1.amazonaws.com/test/reddit')
    return response


def invoke_lambda_weibo_api():
    # lambda function to invoke news api through api gateway
    response = requests.post('https://womkny0mg9.execute-api.us-east-1.amazonaws.com/test/weibo')
    return response


def lambda_handler(event, context):
    # invoke reddit api if key value is reddit
    if (event['detail']['service'] == 'reddit'):
        invoke_lambda_reddit_api()
    elif (event['detail']['service'] == 'twitter'):
        return invoke_lambda_twitter_api()
    elif (event['detail']['service'] == 'weibo'):
        return invoke_lambda_weibo_api()

