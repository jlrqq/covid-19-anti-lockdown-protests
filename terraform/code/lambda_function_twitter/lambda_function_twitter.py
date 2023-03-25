import os
import boto3
import tweepy
import requests
import pandas as pd
import json


def lambda_handler(event, context):
    # Paste in your own bearer token
    BEARER_TOKEN = os.environ['bearer_token']

    client = tweepy.Client(bearer_token=BEARER_TOKEN, return_type=requests.Response)

    # Replace with your own search query
    query = 'covid19 lockdown -is:retweet lang:en'
    tweets = tweepy.Paginator(client.search_recent_tweets, query=query,
                              tweet_fields=['context_annotations', 'created_at'], max_results=100).flatten(limit=1000)

    tweets1 = client.search_recent_tweets(
        query=query,
        tweet_fields=['context_annotations', 'created_at'],
        max_results=100)

    # Save data as dictionary
    tweets_dict1 = tweets1.json()

    # Extract "data" value from dictionary
    tweets_data1 = tweets_dict1['data']

    # Transform to pandas Dataframe
    df1 = pd.json_normalize(tweets_data1)
    df1.to_csv('/tmp/tweeter_data.csv', index=False)

    # upload csv file to s3
    s3 = boto3.resource('s3')
    s3.meta.client.upload_file('/tmp/tweeter_data.csv', 'is434-last-sem-best-sem', 'data-lake/tweeter_data.csv')

    # delete csv file from local
    os.remove('/tmp/tweeter_data.csv')

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'success': True
        }),
        "isBase64Encoded": False
    }

