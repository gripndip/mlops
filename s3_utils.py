import boto3
from botocore.client import Config

def get_s3_client(endpoint_url, access_key, secret_key):
    return boto3.client(
        's3',
        endpoint_url=endpoint_url,
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        config=Config(signature_version='s3v4')
    )

def upload_model(client, model_path, bucket, experiment_name):
    key = f"models/{experiment_name}/{model_path.split('/')[-1]}"
    client.upload_file(model_path, bucket, key)