import json

def lambda_handler(event,context):
    print(json.dumps(event,indent=4))
    print("second lambda function change")
    return {
        "message":"Test"
    }