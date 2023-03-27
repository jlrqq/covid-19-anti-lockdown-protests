from neo4j import GraphDatabase
import logging
import json
from datetime import datetime
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
        query = """
                CREATE(t:Tweet)
                SET t.id = $id, t.text = $text, t.created_at = datetime($created_at)
                MERGE(u:User{username:$author_name}) CREATE (u)-[:Tweeted {date:datetime($created_at)}]->(t)
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
                tag['author_name'] = tweet['author_name']
                tag['created_at'] = tweet['created_at']
                tag['tag_username'] = tag_username
                # tags.append(tag)
                query_tag = """
                    CREATE (tagu:User{username:$tag_username}) 
                    MERGE(u:User{username:$author_name})
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
    user = os.getenv("NEO4J_USER")
    password = os.getenv("NEO4J_PASSWORD")
    filename = "../Twitter_Data/Twitter_Covid-19_Lockdown_5000.json"

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