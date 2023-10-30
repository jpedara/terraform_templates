import json

def lambda_handler(event,context):
    print(json.dumps(event,indent=4))
    print("first lambda function")
    return {
        "message":"Test"
    }