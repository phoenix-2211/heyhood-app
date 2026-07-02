import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json
import os
import sys

# Set stdout encoding to UTF-8
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

# Constants
PROJECT_ID = os.environ.get("FIREBASE_PROJECT_ID", "hey-hood-prod")
SEED_DATA_DIR = "D:\\Vibe Coding\\Database\\seed_data"
GEO_DATA_DIR = "D:\\Vibe Coding\\Database\\geo_data"

def init_firestore():
    # If running with Firestore Emulator
    emulator_host = os.environ.get("FIRESTORE_EMULATOR_HOST")
    dummy_path = "D:\\Vibe Coding\\Database\\dummy_credentials.json"
    
    if emulator_host:
        print(f"Firestore Emulator detected at {emulator_host}. Connecting...")
        cred = credentials.Certificate(dummy_path)
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred, {"projectId": PROJECT_ID})
    else:
        print("Connecting to Firestore Cloud...")
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

def batch_write_documents(db, collection_name, doc_list, id_field="official_id"):
    """Write documents in batches of 500."""
    total = len(doc_list)
    print(f"Seeding {total} documents to '{collection_name}' collection...")
    
    batch = db.batch()
    count = 0
    success_count = 0
    
    for doc in doc_list:
        doc_id = doc.get(id_field)
        if not doc_id:
            continue
            
        doc_ref = db.collection(collection_name).document(doc_id)
        
        # Inject standard timestamps
        doc["created_at"] = firestore.SERVER_TIMESTAMP
        
        batch.set(doc_ref, doc)
        count += 1
        
        if count == 500:
            batch.commit()
            success_count += count
            print(f"  Committed batch: {success_count}/{total}")
            batch = db.batch()
            count = 0
            
    if count > 0:
        batch.commit()
        success_count += count
        print(f"  Committed final batch: {success_count}/{total}")
        
    print(f"Finished seeding '{collection_name}'. Total: {success_count} documents.")

def seed_wards(db):
    print("\n--- Seeding Wards ---")
    wards_geojson_path = os.path.join(GEO_DATA_DIR, "chennai_wards.geojson")
    mapping_path = os.path.join(GEO_DATA_DIR, "ward_official_mapping.json")
    
    if not os.path.exists(wards_geojson_path) or not os.path.exists(mapping_path):
        print("Ward boundary files or mapping not found. Skipping wards seeding.")
        return
        
    with open(wards_geojson_path, "r") as f:
        geojson = json.load(f)
    with open(mapping_path, "r") as f:
        mapping = json.load(f)
        
    ward_documents = []
    for feature in geojson.get("features", []):
        props = feature.get("properties", {})
        geom = feature.get("geometry", {})
        ward_id = props.get("ward_id")
        
        # Merge mapping details
        map_details = mapping.get(ward_id, {})
        
        ward_doc = {
            "ward_id": ward_id,
            "ward_name": props.get("ward_name"),
            "ward_number": props.get("ward_number"),
            "zone": props.get("zone"),
            "zone_number": props.get("zone_number"),
            "district": props.get("district"),
            "state": props.get("state"),
            "boundary_geojson": json.dumps(geom),
            "pulse_score": 70, # default starting score
            "councillor_id": map_details.get("councillor_id"),
            "zone_officer_id": map_details.get("zone_officer_id"),
            "mla_id": map_details.get("mla_id"),
            "mp_id": map_details.get("mp_id"),
            "collector_id": map_details.get("collector_id"),
            "police_station_id": f"TNP-{ward_id[-3:]}-01",
            "fire_station_id": f"TNF-{ward_id[-3:]}-01",
            "nearest_hospital_ids": [f"HOSP-{ward_id[-3:]}-01"]
        }
        ward_documents.append(ward_doc)
        
    batch_write_documents(db, "wards", ward_documents, id_field="ward_id")

def seed_emergency_services(db):
    print("\n--- Seeding Emergency Services ---")
    services_path = os.path.join(SEED_DATA_DIR, "emergency_services_chennai_demo.json")
    if os.path.exists(services_path):
        with open(services_path, "r") as f:
            services = json.load(f)
        batch_write_documents(db, "emergency_services", services, id_field="service_id")
        
    # Standard numbers config doc
    numbers_path = os.path.join(SEED_DATA_DIR, "emergency_numbers_standard.json")
    if os.path.exists(numbers_path):
        with open(numbers_path, "r") as f:
            numbers = json.load(f)
        db.collection("metadata").document("emergency_numbers_standard").set(numbers)
        print("Seeded emergency_numbers_standard config doc.")

def seed_officials(db):
    print("\n--- Seeding Officials ---")
    official_files = [
        "officials_collectors_tn.json",
        "officials_virudhunagar_extra_tn.json",
        "officials_virudhunagar_municipalities.json",
        "officials_virudhunagar_tahsildars.json",
        "officials_virudhunagar_bdos.json",
        "mlas.json",
        "ministers.json",
        "secretaries.json",
        "hods.json",
        "district_officers.json"
    ]
    
    all_officials = []
    # Deduplicate officials by ID
    seen_ids = set()
    
    for filename in official_files:
        filepath = os.path.join(SEED_DATA_DIR, filename)
        if not os.path.exists(filepath):
            print(f"Warning: {filename} not found. Skipping.")
            continue
            
        with open(filepath, "r") as f:
            records = json.load(f)
            
        print(f"Loaded {len(records)} records from {filename}")
        for r in records:
            oid = r.get("official_id")
            if oid and oid not in seen_ids:
                seen_ids.add(oid)
                # Apply standard fields if missing
                if "verified" not in r:
                    r["verified"] = True
                if "accountability_score" not in r:
                    r["accountability_score"] = 100
                if "issues_assigned" not in r:
                    r["issues_assigned"] = 0
                if "issues_resolved" not in r:
                    r["issues_resolved"] = 0
                if "issues_overdue" not in r:
                    r["issues_overdue"] = 0
                    
                all_officials.append(r)
                
    print(f"Total unique officials to seed: {len(all_officials)}")
    batch_write_documents(db, "officials", all_officials, id_field="official_id")

def main():
    try:
        db = init_firestore()
        seed_wards(db)
        seed_emergency_services(db)
        seed_officials(db)
        print("\n--- All seeding tasks completed successfully ---")
    except Exception as e:
        print(f"Fatal error during seeding: {e}")

if __name__ == "__main__":
    main()
