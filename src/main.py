import pathlib as pl
import json
import logging
import sys

logging.basicConfig(level=logging.INFO, force=True)
handler = logging.StreamHandler(sys.stdout)
logger = logging.getLogger()
logger.addHandler(handler)
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event, indent=2)}")
    
    try:
        body = parse_request_body(event)
        content = pl.Path('test').read_text()
        response_data = {
            "message": f"Hello again from the resume-lambda Lambda! Here even more {content=}",
            "event": body,
            "statusCode": 200
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_data)
        }
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({"error": str(e)})
        }


def parse_request_body(event):
    if event.get('body'):
        if event.get('isBase64Encoded', False):
            import base64
            body = base64.b64decode(event['body']).decode('utf-8')
        else:
            body = event['body']
        
        try:
            return json.loads(body)
        except json.JSONDecodeError:
            return {"raw_body": body}
    else:
        return event