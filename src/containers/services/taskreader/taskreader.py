from flask import (
    Flask,
    jsonify,
)
import os
import redis


HOSTNAME = "0.0.0.0"
PORT = int(os.environ.get("PORT", 5000))
print("Listening on port", PORT)

KEYS_DIR = "./keys"
CERT_PATH = f"{KEYS_DIR}/fullchain.pem"
KEY_PATH = f"{KEYS_DIR}/privkey.pem"

app = Flask(__name__)

# Connect to the Redis database
DB_NAMESPACE = os.environ.get("DB_NAMESPACE", "default")
REDIS_HOST = f"redis-leader.{DB_NAMESPACE}.svc.cluster.local"
print("Connecting to Redis database at", REDIS_HOST)

redis_db = redis.StrictRedis(host=REDIS_HOST, port=6379, db=0, charset="utf-8", decode_responses=True)


class Task(dict):
    def __init__(self, name, text):
        super().__init__(self, name=name, text=text)
        # little cheat to access dict values as attributes.
        # You can't use attributes with names that are already used by dict, for example 'keys'
        self.__dict__ = self

    def __str__(self):
        return f"<Task '{self.name}': '{self.text}'>"
    
    def __eq__(self, other: object) -> bool:
        if type(other) is str:
            return self.name == other
        elif type(other) is Task:
            return self.name == other.name

        return super().__eq__(other)


@app.route("/", methods=["GET"])
def success_message():
    return "Connected Sucessfully!"


@app.route("/api/tasks", methods=["GET"])
def getTasks():
    try:
        tasks = list([Task(name=key, text=redis_db.get(key)) for key in redis_db.keys("*")])

        return jsonify({"success": True, "message": "Tasks retrieved successfully", "tasks": tasks})
    except Exception as e:
        return jsonify({"success": False, "message": "Error retrieving tasks", "error": str(e)})
    

if __name__ == "__main__":
    from gevent import monkey
    monkey.patch_all()

    from gevent import ssl

    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ssl_context.load_cert_chain(CERT_PATH, KEY_PATH)

    from gevent.pywsgi import WSGIServer

    http_server = WSGIServer((HOSTNAME, PORT), app, ssl_context=ssl_context)
    http_server.serve_forever()