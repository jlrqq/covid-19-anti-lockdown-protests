import os
import re
import boto3
from jsonpath import jsonpath
import requests
import pandas as pd
import datetime
import json


def trans_time(v_str):
    """Convert GMT time to standard format"""
    GMT_FORMAT = '%a %b %d %H:%M:%S +0800 %Y'
    timeArray = datetime.datetime.strptime(v_str, GMT_FORMAT)
    ret_time = timeArray.strftime("%Y-%m-%d %H:%M:%S")
    return ret_time


def get_weibo_list(v_keyword, v_max_page):
    # Request Header
    headers = {
        "User-Agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) "
                      "Chrome/99.0.4844.51 Mobile Safari/537.36",
        "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,"
                  "application/signed-exchange;v=b3;q=0.9",
        "accept-encoding": "gzip, deflate, br",
    }

    # Request URL
    url = 'https://m.weibo.cn/api/container/getIndex'
    df = pd.DataFrame(
        columns=['id', 'bid', 'text', 'time', 'author', 'repost_count', 'comment_count', 'attitudes_count']
    )
    for page in range(1, v_max_page + 1):
        # Request Parameter
        params = {
            "containerid": "100103type=1&q={}".format(v_keyword),
            "page_type": "searchall",
            "page": page
        }
        # Send Request
        r = requests.get(url, headers=headers, params=params)
        cards = r.json()["data"]["cards"]
        text_list = jsonpath(cards, '$..mblog.text')
        dr = re.compile(r'<[^>]+>', re.S)
        text2_list = []
        if not text_list:
            break
        if type(text_list) == list and len(text_list) > 0:
            for text in text_list:
                text2_list.append(translate_text(dr.sub('', text), 'zh', 'en'))

        temp_df = pd.DataFrame(
            {
                'id': jsonpath(cards, '$..mblog.id'),
                'bid': jsonpath(cards, '$..mblog.bid'),
                'text': text2_list,
                'time': [trans_time(v_str=i) for i in jsonpath(cards, '$..mblog.created_at')],
                'author': jsonpath(cards, '$..mblog.user.screen_name'),
                'repost_count': jsonpath(cards, '$..mblog.reposts_count'),
                'comment_count': jsonpath(cards, '$..mblog.comments_count'),
                'attitudes_count': jsonpath(cards, '$..mblog.attitudes_count')
            }
        )
        df = pd.concat([df, temp_df], axis=0)
        print('Data for page {} has been saved'.format(page))
    df.to_csv('weibo_{}.csv'.format(v_keyword.replace(" ", "+")), index=False, encoding='utf-8-sig')
    # upload csv file to s3
    s3 = boto3.resource('s3')
    s3.meta.client.upload_file('/tmp/translated_weibo_data.csv', 'is434-last-sem-best-sem', 'data-lake'
                                                                                            '/translated_weibo_data.csv')

    # delete csv file from local
    os.remove('/tmp/translated_weibo_data.csv')


# Write a python function to connect to aws Translate to translate chinese to english
def translate_text(text, source_language_code, target_language_code):
    translate = boto3.client(service_name='translate', region_name='us-east-1', use_ssl=True)
    result = translate.translate_text(Text=text, SourceLanguageCode=source_language_code,
                                      TargetLanguageCode=target_language_code)
    return result.get('TranslatedText')


def lambda_handler(event, context):
    # write a lambda function
    max_search_page = 200
    keyword = '封城'
    get_weibo_list(v_keyword=keyword, v_max_page=max_search_page)
    
    response = {
        'statusCode': 200,
        'headers':
            {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
        'body': json.dumps({
            'success': True
        }),
        }
    return response
