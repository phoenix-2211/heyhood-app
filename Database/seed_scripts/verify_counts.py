import firebase_admin
from firebase_admin import firestore, credentials
import os
import sys

# Set stdout encoding to UTF-8
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

PROJECT_ID = os.environ.get("FIREBASE_PROJECT_ID", "hey-hood-prod")

def init_firestore():
    emulator_host = os.environ.get("FIRESTORE_EMULATOR_HOST")
    dummy_path = "D:\\Vibe Coding\\Database\\dummy_credentials.json"
    
    if emulator_host:
        print(f"Connecting to Firestore Emulator at {emulator_host}...")
        cred = credentials.Certificate(dummy_path)
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred, {"projectId": PROJECT_ID})
    else:
        print("Connecting to live Firestore...")
        cred_path = r"D:\Vibe Coding\firebase_credentials.json"
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred, {"projectId": PROJECT_ID})
        else:
            print("No cloud credentials found. Falling back to local emulator mode...")
            os.environ["FIRESTORE_EMULATOR_HOST"] = "127.0.0.1:8080"
            cred = credentials.Certificate(dummy_path)
            if not firebase_admin._apps:
                firebase_admin.initialize_app(cred, {"projectId": PROJECT_ID})
    return firestore.client()

def main():
    try:
        db = init_firestore()
        
        collections = ["wards", "emergency_services", "officials"]
        print("\n--- Document Counts in Firestore ---")
        for col_name in collections:
            docs = db.collection(col_name).stream()
            count = sum(1 for _ in docs)
            print(f"Collection '{col_name}': {count} documents")
            
        # Check standard config doc
        metadata_ref = db.collection("metadata").document("emergency_numbers_standard")
        doc = metadata_ref.get()
        if doc.exists:
            print("Metadata 'emergency_numbers_standard' document: Found")
            print(f"  Data: {doc.to_dict()}")
        else:
            print("Metadata 'emergency_numbers_standard' document: Not Found")
            
    except Exception as e:
        print(f"Error checking document counts: {e}")

if __name__ == "__main__":
    main()
