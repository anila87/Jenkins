from flask import Flask, request
import requests

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Service A!"

@app.route('/notify', methods=['POST'])
def notify():
    data = request.json
    return {"status": "received", "message": data}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
