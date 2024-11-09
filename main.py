import argparse
from s3_operations import download_from_s3, upload_to_s3
from data_processing import process_data

def main(bucket, input_key, output_key):
    local_input_path = 'local_dataset.csv'
    local_output_path = 'processed_dataset.csv'

    download_from_s3(bucket, input_key, local_input_path)
    process_data(local_input_path, local_output_path)
    upload_to_s3(local_output_path, bucket, output_key)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--bucket', required=True)
    parser.add_argument('--input_key', required=True)
    parser.add_argument('--output_key', required=True)
    args = parser.parse_args()

    main(args.bucket, args.input_key, args.output_key)