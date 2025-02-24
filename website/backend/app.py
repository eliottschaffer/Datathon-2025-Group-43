from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib  # Change from pickle to joblib
import os

print("Starting Flask application...")  # Debug print

app = Flask(__name__)
# Update CORS configuration to be more permissive for local development
CORS(app, resources={r"/*": {"origins": "*"}})

print(f"Current working directory: {os.getcwd()}")  # Debug print
MODEL_PATH = os.path.join(os.path.dirname(__file__), 'model', 'random_forest_top30.pkl')
FEATURES_PATH = os.path.join(os.path.dirname(__file__), 'model', 'top_30_features.pkl')

print(f"Looking for model at: {MODEL_PATH}")  # Debug print
print(f"Looking for features at: {FEATURES_PATH}")  # Debug print

try:
    # Use joblib instead of pickle
    rf_model = joblib.load(MODEL_PATH)
    print("Successfully loaded model")  # Debug print
    
    top_30_features = joblib.load(FEATURES_PATH)
    print("Successfully loaded features")  # Debug print
    print(f"Features loaded: {top_30_features}")  # Debug print
except Exception as e:
    print(f"Error loading model files: {str(e)}")
    rf_model = None
    top_30_features = None

@app.route('/', methods=['GET'])
def home():
    print("Received request to home route")  # Debug print
    try:
        status = "OK" if rf_model is not None and top_30_features is not None else "ERROR"
        return f"""
        <html>
            <body>
                <h1>Game Owners Predictor API</h1>
                <p>Status: {status}</p>
                <p>Model loaded: {rf_model is not None}</p>
                <p>Features loaded: {top_30_features is not None}</p>
            </body>
        </html>
        """
    except Exception as e:
        print(f"Error in home route: {str(e)}")
        return f"Error: {str(e)}", 500

@app.route('/predict', methods=['POST'])
def predict():
    if rf_model is None or top_30_features is None:
        return jsonify({
            'success': False,
            'error': 'Model not loaded properly'
        }), 500

    # Define the player ranges
    PLAYER_RANGES = [
        "0 - 20,000",
        "20,000 - 200,000",
        "200,000 - 2,000,000",
        "2,000,000 - 20,000,000",
        "20,000,000 - 200,000,000"
    ]

    try:
        # Get data from request
        data = request.get_json()
        print(f"Received data: {data}")  # Debug print
        
        # Create DataFrame with only the required features
        input_data = {}
        for feature in top_30_features:
            if feature not in data:
                return jsonify({
                    'success': False,
                    'error': f'Missing required feature: {feature}'
                }), 400
            input_data[feature] = [data[feature]]
        
        # Create DataFrame with the exact same features used in training
        df = pd.DataFrame(input_data)
        X_new = df[top_30_features]  # Ensure features are in the same order
        
        # Make prediction using the random forest model
        prediction = int(rf_model.predict(X_new)[0])  # Convert to int to use as index
        player_range = PLAYER_RANGES[prediction]
        print(f"Prediction made: {prediction} ({player_range} players)")  # Debug print
        
        return jsonify({
            'success': True,
            'prediction': player_range,
            'prediction_class': prediction,
            'message': 'Prediction successful'
        })

    except Exception as e:
        print(f"Error in predict route: {str(e)}")  # Debug print
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

if __name__ == '__main__':
    print("Starting Flask server...")
    # Don't try port 5000 at all on Mac, go straight to 5001
    app.run(host='localhost', port=5001, debug=True) 