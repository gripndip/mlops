import pandas as pd

def process_data(input_path, output_path):
    df = pd.read_csv(input_path)
    df['Age'].fillna(df['Age'].median(), inplace=True)
    df.to_csv(output_path, index=False)