import base64

def hello_pubsub(event, context):
    if 'data' in event:
        message = base64.b64decode(event['data']).decode('utf-8')
        print(f"Received message: {message}")
    else:
        print("No data in message.")
