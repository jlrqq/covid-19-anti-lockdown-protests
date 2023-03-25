import os
import boto3
import praw
import pandas as pd
import json


# lambda_handler is the entry point for lambda function
def lambda_handler(event, context):
    reddit = praw.Reddit(client_id=os.environ['client_id'],
                         client_secret=os.environ['client_secret'],
                         user_agent=os.environ['user_agent'],
                         username=os.environ['username'],
                         password=os.environ['password'])

    subreddit = reddit.subreddit('Coronavirus')

    lockdown_subreddit = subreddit.search("anti-lockdown", limit=100)

    # Store the following attributes about lockdown_subreddit
    topics_dict = {"author": [],
                   "title": [],
                   "score": [],
                   "id": [], "url": [],
                   "comms_num": [],
                   "created": [],
                   "body": []}

    # Add data of each submission(post) in lockdown_subreddit to topics_dict

    for submission in lockdown_subreddit:
        topics_dict["author"].append(submission.author)
        topics_dict["title"].append(submission.title)
        topics_dict["score"].append(submission.score)
        topics_dict["id"].append(submission.id)
        topics_dict["url"].append(submission.url)
        topics_dict["comms_num"].append(submission.num_comments)
        topics_dict["created"].append(submission.created)
        topics_dict["body"].append(submission.selftext)

    # store topic_dict into s3 in csv format
    topics_data = pd.DataFrame(topics_dict)
    topics_data.to_csv('/tmp/reddit_data.csv', index=False)

    # upload csv file to s3
    s3 = boto3.resource('s3')
    s3.meta.client.upload_file('/tmp/reddit_data.csv', 'is434-last-sem-best-sem', 'data-lake/reddit_data.csv')

    # delete csv file from local
    os.remove('/tmp/reddit_data.csv')

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
