import os
import json
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize firebase admin if not already initialized
if not firebase_admin._apps:
    cred_json = os.environ.get("FIREBASE_CREDENTIALS_JSON")
    cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
    
    if cred_json:
        try:
            cred_dict = json.loads(cred_json)
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred)
        except Exception as e:
            print(f"Error initializing Firebase from JSON env: {e}")
            firebase_admin.initialize_app()
    elif cred_path and os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    elif os.path.exists(r"D:\Vibe Coding\firebase_credentials.json"):
        cred = credentials.Certificate(r"D:\Vibe Coding\firebase_credentials.json")
        firebase_admin.initialize_app(cred)
    else:
        try:
            firebase_admin.initialize_app()
        except Exception:
            # Try relative path
            rel_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "firebase_credentials.json"))
            if os.path.exists(rel_path):
                cred = credentials.Certificate(rel_path)
                firebase_admin.initialize_app(cred)
            else:
                raise RuntimeError("Firebase credentials could not be loaded!")

def get_db():
    return firestore.client()
