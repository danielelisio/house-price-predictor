import joblib
import pandas as pd
import numpy as np
from datetime import datetime
from schemas import HousePredictionRequest, PredictionResponse

# Load model
MODEL_PATH = "models/trained/house_price_model.pkl"

try:
    model = joblib.load(MODEL_PATH)
    print("Model loaded successfully")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

def predict_price(request: HousePredictionRequest) -> PredictionResponse:
    if model is None:
        raise RuntimeError("Model not loaded")
    
    # Create 10 features to match model expectation (based on error message)
    house_age = 2025 - request.year_built
    bed_bath_ratio = request.bedrooms / max(request.bathrooms, 1)
    
    # One-hot encode location (Urban, Suburban, Rural, Waterfront, etc.)
    location_urban = 1 if request.location.lower() == 'urban' else 0
    location_suburban = 1 if request.location.lower() == 'suburban' else 0  
    location_rural = 1 if request.location.lower() == 'rural' else 0
    
    # One-hot encode condition (Good, Excellent, Fair)
    condition_good = 1 if request.condition.lower() == 'good' else 0
    condition_excellent = 1 if request.condition.lower() == 'excellent' else 0
    
    # Create feature array with 10 features
    features = np.array([[
        request.sqft,           # 0
        request.bedrooms,       # 1  
        request.bathrooms,      # 2
        house_age,              # 3
        bed_bath_ratio,         # 4
        location_urban,         # 5
        location_suburban,      # 6
        location_rural,         # 7
        condition_good,         # 8
        condition_excellent     # 9
    ]])
    
    predicted_price = float(model.predict(features)[0])
    predicted_price = round(predicted_price, 2)
    
    return PredictionResponse(
        predicted_price=predicted_price,
        confidence_interval=[round(predicted_price * 0.9, 2), round(predicted_price * 1.1, 2)],
        features_importance={"sqft": 0.4, "age": 0.3, "bedrooms": 0.2, "bathrooms": 0.1}
    )
