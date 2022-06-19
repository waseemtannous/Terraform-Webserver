from flask import Flask
from random import choice
import psycopg2

import os
import json

# database params
DB_HOST = os.environ['DB_HOST']
DB_PORT = int(os.environ['DB_PORT'])
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DATABASE = os.environ['DATABASE']

app = Flask(__name__)


@app.route('/joke')
def getRandomJoke():
    conn = None
    cur = None

    joke = None

    try:
        conn = psycopg2.connect(host=DB_HOST, database=DATABASE, user=DB_USER, password=DB_PASSWORD, port=DB_PORT)
        cur = conn.cursor()

        cur.execute(f'SELECT * FROM jokes;')


        jokes = cur.fetchall()
        index = choice(range(len(jokes)))
        joke = jokes[index][1]


    except Exception as e:
        print(e)
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

    if joke:
        data = {
            "joke": joke
        }

        response = app.response_class(
            response=json.dumps(data),
            status=200,
            mimetype='application/json'
        )
    else:
        response = app.response_class(
            status=500,
            mimetype='application/json'
        )

    return response


@app.route('/')
def index():
    data = {
        "message": "Hello. This is the server. You can get a random joke by calling /joke. Enjoy! :)"
    }

    response = app.response_class(
        response=json.dumps(data),
        status=200,
        mimetype='application/json'
    )

    return response


if __name__ == '__main__':
    app.run(port=80, host='0.0.0.0')
