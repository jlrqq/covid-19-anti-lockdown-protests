from neo4j import GraphDatabase
import logging
import json
from datetime import datetime
# from dateutil.parser import parse
from neo4j.exceptions import ServiceUnavailable
import time
from dotenv import load_dotenv
import os

load_dotenv() 

class App:

    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        # Don't forget to close the driver connection when you are finished with it
        self.driver.close()

    def create_tweet_node(self, tweet):
        with self.driver.session(database="neo4j") as session:
            # Write transactions allow the driver to handle retries and transient errors
            result = session.execute_write(
                self.generate_query_and_run, tweet)
            # for row in result:
            #     print("Created friendship between: {p1}, {p2}".format(p1=row['p1'], p2=row['p2']))

    @staticmethod
    def generate_query_and_run(tx, tweet):
        # To learn more about the Cypher syntax, see https://neo4j.com/docs/cypher-manual/current/
        # The Reference Card is also a good resource for keywords https://neo4j.com/docs/cypher-refcard/current/
        tweet["created_at"] = datetime.strptime(tweet["datetime"], '%Y-%m-%d %H:%M:%S%z') 
        
        query = """
                CREATE(t:Tweet) 
                SET t.tweet_id = $tweet_id, t.text = $text, t.datetime = datetime($created_at), 
                t.sentiment_score = $sentiment_score, t.sentiment_label = $sentiment_label 
                MERGE(top_e:Emotion{emotion:$top_emotion}) 
                CREATE (t)-[:HasTopEmotion {score:$top_emotion_score}]->(top_e) 
                MERGE(sec_e:Emotion{emotion:$second_emotion}) 
                CREATE (t)-[:HasSecEmotion {score:$second_emotion_score}]->(sec_e) 
                MERGE(thi_e:Emotion{emotion:$third_emotion}) 
                CREATE (t)-[:HasThiEmotion {score:$third_emotion_score}]->(thi_e) 
                MERGE(topic:Topic{timeframe_topic_id:$dominant_topic, keywords:$keywords}) 
                CREATE (t)-[:HasDominantTopic {score:$topic_perc_contrib}]->(topic) 
                MERGE(u:User{username:$username}) CREATE (u)-[:Tweeted {date:datetime($created_at)}]->(t)
                """
        
        if tweet["rt_username"]:
            query += """
                    MERGE(rtu:User{username:$rt_username}) 
                    CREATE (u)-[:ReTweeted {date:datetime($created_at)}]->(rtu)
                    """       
        
        result = tx.run(query, tweet)   
         
        if tweet["tag_usernames"]:
            # tags = []
            for tag_username in tweet["tag_usernames"]:
                tag = {}
                tag['username'] = tweet['username']
                tag['created_at'] = tweet['created_at']
                tag['tag_username'] = tag_username
                # tags.append(tag)
                query_tag = """
                    CREATE (tagu:User{username:$tag_username}) 
                    MERGE(u:User{username:$username})
                    CREATE (u)-[:Tagged {date:datetime($created_at)}]->(tagu)
                    """
                result2 = tx.run(query_tag, tag)
        
        try:
            return [{"p1": row["p1"]["name"], "p2": row["p2"]["name"]}
                    for row in result]

        # Capture any errors along with the query and data for traceability
        except ServiceUnavailable as exception:
            logging.error("{query} raised an error: \n {exception}".format(
                query=query, exception=exception))
            raise

def loadJson(filename):
    with open(filename) as fh:
        j = fh.read()
    return json.loads(j)

if __name__ == "__main__":
    start = time.time()
    print("Starting...")
    # Aura queries use an encrypted connection using the "neo4j+s" URI scheme
    uri = os.getenv("NEO4J_HOST")
    user = '' # os.getenv("NEO4J_USER")
    password = '' # os.getenv("NEO4J_PASSWORD")
    filename = "./tweets_upload.json"

    data = loadJson(filename)
    
    c = 0
    for i in data:
        app = App(uri, user, password)
        app.create_tweet_node(i)
        app.close()
        c += 1
        if c % 100 == 0:
            print("Loaded",c,"records")
            end = time.time()
            print("Time Taken:",end - start,"s")
            # break

    end = time.time()
    print("DONE LIAO")
    print("Time Taken:",end - start,"s")