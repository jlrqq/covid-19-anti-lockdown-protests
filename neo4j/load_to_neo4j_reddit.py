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

    def create_reddit_node(self, reddit):
        with self.driver.session(database="neo4j") as session:
            # Write transactions allow the driver to handle retries and transient errors
            result = session.execute_write(
                self.generate_query_and_run, reddit)
            # for row in result:
            #     print("Created friendship between: {p1}, {p2}".format(p1=row['p1'], p2=row['p2']))

    @staticmethod
    def generate_query_and_run(tx, reddit):
        # To learn more about the Cypher syntax, see https://neo4j.com/docs/cypher-manual/current/
        # The Reference Card is also a good resource for keywords https://neo4j.com/docs/cypher-refcard/current/
        reddit["created_at"] = datetime.strptime(reddit["timestamp"], '%Y-%m-%d %H:%M:%S') 
        query = """
                CREATE(r:Reddit_post) 
                SET r.id = $id, r.title = $title, r.score = $score, r.url = $url, 
                r.comms_num = $comms_num, r.datetime = datetime($created_at) 
                MERGE(u:RUser{username:$author}) CREATE (u)-[:Post {date:datetime($created_at)}]->(r)
                """
        
        # if reddit["comment"]:
        #     query += """
        #             MERGE(rc:Reddit_comment{comment:$comment, top_lvl:$top_lvl, sentiment_score = $sentiment_polarity, sentiment_label = $sentiment_polarity_summary}) 
        #             CREATE (rc)-[:IsComment {date:datetime($created_at)}]->(r)                      
        #             MERGE(top_e:Emotion{emotion:$top_emotion}) 
        #             CREATE (rc)-[:HasTopEmotion {score:$top_emotion_score}]->(top_e) 
        #             MERGE(sec_e:Emotion{emotion:$second_emotion}) 
        #             CREATE (rc)-[:HasSecEmotion {score:$second_emotion_score}]->(sec_e) 
        #             MERGE(thi_e:Emotion{emotion:$third_emotion}) 
        #             CREATE (rc)-[:HasThiEmotion {score:$third_emotion_score}]->(thi_e) 
        #             MERGE(topic:Topic{timeframe_topic_id:$dominant_topic, keywords:$keywords}) 
        #             CREATE (rc)-[:HasDominantTopic {score:$topic_perc_contrib}]->(topic) 
        #             """       
        #     if reddit["commenter"]:
        #         query += """
        #                 MERGE(cu:RUser{username:$commenter}) 
        #                 CREATE (cu)-[:Comment {date:datetime($created_at)}]->(rc)
        #                 """
        result = tx.run(query, reddit)   
        
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
    filename = "./reddits_upload_simple.json"

    data = loadJson(filename)
    
    c = 0
    for i in data:
        app = App(uri, user, password)
        app.create_reddit_node(i)
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