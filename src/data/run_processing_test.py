# src/data/processor_test.py
import pandas as pd
import numpy as np
from pathlib import Path
import logging
from sklearn.ensemble import IsolationForest

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('data-processor-test')

def load_data(file_path):
    """Load data from a CSV file."""
    logger.info(f"Loading data from {file_path}")
    return pd.read_csv(file_path)

def remove_outliers_isolation_forest(df, columns, contamination=0.1):
    """Remove outliers using Isolation Forest from sklearn"""
    logger.info(f"Removing outliers from {columns} using Isolation Forest")
    
    # Select only numeric columns for outlier detection
    X = df[columns]
    
    # Initialize and fit the model
    iso_forest = IsolationForest(contamination=contamination, random_state=42)
    outlier_labels = iso_forest.fit_predict(X)
    
    # Count outliers
    outliers_count = len(df[outlier_labels == -1])
    logger.info(f"Found {outliers_count} outliers using Isolation Forest")
    
    # Keep only inliers (labeled as 1, outliers are -1)
    df_filtered = df[outlier_labels == 1]
    logger.info(f"Removed outliers. New dataset shape: {df_filtered.shape}")
    
    return df_filtered

def clean_data(df):
    """Clean the dataset by handling missing values and outliers."""
    logger.info("Cleaning dataset")
    
    # Make a copy to avoid modifying the original dataframe
    df_cleaned = df.copy()
    
    # Handle missing values
    for column in df_cleaned.columns:
        missing_count = df_cleaned[column].isnull().sum()
        if missing_count > 0:
            logger.info(f"Found {missing_count} missing values in {column}")
            
            # For numeric columns, fill with median
            if pd.api.types.is_numeric_dtype(df_cleaned[column]):
                median_value = df_cleaned[column].median()
                df_cleaned[column] = df_cleaned[column].fillna(median_value)
                logger.info(f"Filled missing values in {column} with median: {median_value}")
            # For categorical columns, fill with mode
            else:
                mode_value = df_cleaned[column].mode()[0]
                df_cleaned[column] = df_cleaned[column].fillna(mode_value)
                logger.info(f"Filled missing values in {column} with mode: {mode_value}")
    
    # Handle outliers using sklearn Isolation Forest (streamlined approach)
    df_cleaned = remove_outliers_isolation_forest(df_cleaned, ['price'], contamination=0.05)
    
    return df_cleaned

def process_data(input_file, output_file):
    """Full data processing pipeline."""
    # Create output directory if it doesn't exist
    output_path = Path(output_file).parent
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Load data
    df = load_data(input_file)
    logger.info(f"Loaded data with shape: {df.shape}")
    
    # Clean data
    df_cleaned = clean_data(df)
    
    # Save processed data
    df_cleaned.to_csv(output_file, index=False)
    logger.info(f"Saved processed data to {output_file}")
    
    return df_cleaned

if __name__ == "__main__":
    # Example usage
    process_data(
        input_file="data/raw/house_data.csv", 
        output_file="data/processed/cleaned_house_data_sklearn.csv"
    )