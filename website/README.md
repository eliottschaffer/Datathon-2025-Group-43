# Game Owners Predictor

A web application that predicts the number of game owners based on various game features.

## Project Structure

- `backend/`: Flask backend hosted on Render
- `frontend/`: Frontend hosted on GitHub Pages

## Setup Instructions

### Backend
1. Navigate to the backend directory
2. Create a virtual environment: `python -m venv venv`
3. Activate the virtual environment:
   - Windows: `venv\Scripts\activate`
   - Unix/MacOS: `source venv/bin/activate`
4. Install dependencies: `pip install -r requirements.txt`
5. Run the development server: `python app.py`

### Frontend
1. Navigate to the frontend directory
2. Open index.html in a web browser for local testing
3. Deploy to GitHub Pages for production

## Deployment

### Backend (Render.com)
1. Log in to your Render account
2. Click "New +" button in the top right
3. Select "Web Service"
4. Connect your GitHub repository if you haven't already
5. Select the repository containing your game-owners-predictor project
6. Configure the web service:
   - Name: `game-owners-predictor-api` (or any name you prefer)
   - Environment: `Python 3`
   - Region: Choose the closest to your users
   - Branch: `main` (or your default branch)
   - Root Directory: `backend` (important!)
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `gunicorn app:app`
   - Plan: Free

7. Click "Create Web Service"

### Frontend (GitHub Pages)
1. Enable GitHub Pages in your repository settings
2. Set the source to the frontend directory

## API Documentation

### POST /predict
Predicts the number of game owners based on input features.

Request body: JSON object with game features (TBD)
Response: JSON object with prediction result 
