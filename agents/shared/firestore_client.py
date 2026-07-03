import os
import json
import firebase_admin
from firebase_admin import credentials, firestore

INIT_ERROR = None

# Initialize firebase admin if not already initialized
if not firebase_admin._apps:
    cred_json = os.environ.get("FIREBASE_CREDENTIALS_JSON")
    cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
    
    try:
        if cred_json:
            # Strip any surrounding quotes or whitespace from paste errors
            cred_json_clean = cred_json.strip()
            if cred_json_clean.startswith("'") and cred_json_clean.endswith("'"):
                cred_json_clean = cred_json_clean[1:-1]
            if cred_json_clean.startswith('"') and cred_json_clean.endswith('"'):
                cred_json_clean = cred_json_clean[1:-1]
                
            # Try to fix literal newlines in private key if pasted as a multiline string
            try:
                cred_dict = json.loads(cred_json_clean)
            except Exception:
                # If loading fails, try to escape raw newlines in the private key section
                if "-----BEGIN PRIVATE KEY-----" in cred_json_clean:
                    parts = cred_json_clean.split("-----BEGIN PRIVATE KEY-----")
                    key_parts = parts[1].split("-----END PRIVATE KEY-----")
                    # Escape raw newlines in the key body
                    key_body = key_parts[0].replace("\n", "\\n").replace("\r", "")
                    cred_json_clean = parts[0] + "-----BEGIN PRIVATE KEY-----" + key_body + "-----END PRIVATE KEY-----" + key_parts[1]
                cred_dict = json.loads(cred_json_clean)
                
            if "private_key" in cred_dict:
                cred_dict["private_key"] = cred_dict["private_key"].replace("\\n", "\n")
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred)
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
    except Exception as e:
        import traceback
        INIT_ERROR = RuntimeError(f"Failed to initialize Firebase (length={len(cred_json or '')}): {e}\n{traceback.format_exc()}")

def get_db():
    if INIT_ERROR:
        raise INIT_ERROR
    return firestore.client()
