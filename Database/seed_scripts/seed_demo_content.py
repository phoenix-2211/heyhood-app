import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import random

PROJECT_ID = "hey-hood-prod"
cred_path = r"D:\Vibe Coding\firebase_credentials.json"

def init_firestore():
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred, {"projectId": PROJECT_ID})
    return firestore.client()

def seed_demo_data():
    db = init_firestore()
    print("Connected to CLOUD Firestore for demo seeding...")

    now = datetime.now()

    # 1. Seed Wards (Ensure they have default profiles)
    # Wards TN-CHN-170, TN-CHN-179, TN-VRD-001, TN-VRD-002 are already seeded.

    # 2. Seed 10 Issues
    issues = [
        {
            "issue_id": "HH-TN-CHN-170-2026-10001",
            "title": "Broken Streetlight on 3rd Main Road",
            "description": "The streetlight near the corner of 3rd Main Road and 2nd Cross has been broken for over a week, making it very dark and unsafe at night.",
            "category": "Electricity",
            "severity": "Medium",
            "status": "Posted",
            "lat": 13.0067,
            "lng": 80.2578,
            "ward_id": "TN-CHN-170",
            "ward_name": "Adyar",
            "district": "Chennai",
            "state": "Tamil Nadu",
            "photo_url": "https://images.unsplash.com/photo-1518364538800-6bcb3c2af0ff?auto=format&fit=crop&w=500&q=80",
            "posted_by": "USR-ADYAR-01",
            "anonymous": False,
            "support_count": 14,
            "days_active": 3,
            "assigned_to": "TN-MLA-100",
            "assigned_role": "MLA",
            "resolution_deadline": now + timedelta(days=7),
            "content_hash": "hash_streetlight_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": None,
            "resolved_at": None,
            "verified": False,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=3)).isoformat(), "notes": "Issue reported."}
            ],
            "created_at": now - timedelta(days=3)
        },
        {
            "issue_id": "HH-TN-CHN-170-2026-10002",
            "title": "Garbage Pile near Adyar Bus Stand",
            "description": "A huge pile of garbage has accumulated near the Adyar bus stand, emitting bad odors and attracting pests. Needs immediate clearance.",
            "category": "Sanitation",
            "severity": "High",
            "status": "Posted",
            "lat": 13.0075,
            "lng": 80.2560,
            "ward_id": "TN-CHN-170",
            "ward_name": "Adyar",
            "district": "Chennai",
            "state": "Tamil Nadu",
            "photo_url": "https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?auto=format&fit=crop&w=500&q=80",
            "posted_by": "USR-ADYAR-02",
            "anonymous": True,
            "support_count": 28,
            "days_active": 2,
            "assigned_to": "GCC-ZONE-10",
            "assigned_role": "Zone Officer",
            "resolution_deadline": now + timedelta(days=5),
            "content_hash": "hash_garbage_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": None,
            "resolved_at": None,
            "verified": False,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=2)).isoformat(), "notes": "Issue reported."}
            ],
            "created_at": now - timedelta(days=2)
        },
        {
            "issue_id": "HH-TN-CHN-179-2026-10003",
            "title": "Pothole on Velachery Main Road",
            "description": "Large pothole on the main road causing traffic bottlenecks and posing danger to two-wheeler riders.",
            "category": "Roads",
            "severity": "High",
            "status": "Notified",
            "lat": 12.9796,
            "lng": 80.2196,
            "ward_id": "TN-CHN-179",
            "ward_name": "Velachery",
            "district": "Chennai",
            "state": "Tamil Nadu",
            "photo_url": "",
            "posted_by": "USR-VELA-01",
            "anonymous": False,
            "support_count": 45,
            "days_active": 5,
            "assigned_to": "TN-MLA-108",
            "assigned_role": "MLA",
            "resolution_deadline": now + timedelta(days=4),
            "content_hash": "hash_pothole_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": None,
            "resolved_at": None,
            "verified": False,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=5)).isoformat(), "notes": "Issue reported."},
                {"status": "Notified", "timestamp": (now - timedelta(days=4)).isoformat(), "notes": "Official notified and assigned."}
            ],
            "created_at": now - timedelta(days=5)
        },
        {
            "issue_id": "HH-TN-CHN-179-2026-10004",
            "title": "Water Clogging near Velachery Lake",
            "description": "Stagnant drainage water on the service lane adjacent to Velachery Lake, creating a breeding ground for mosquitoes.",
            "category": "Drainage",
            "severity": "Medium",
            "status": "Notified",
            "lat": 12.9810,
            "lng": 80.2220,
            "ward_id": "TN-CHN-179",
            "ward_name": "Velachery",
            "district": "Chennai",
            "state": "Tamil Nadu",
            "photo_url": "",
            "posted_by": "USR-VELA-02",
            "anonymous": True,
            "support_count": 19,
            "days_active": 4,
            "assigned_to": "TN-MLA-108",
            "assigned_role": "MLA",
            "resolution_deadline": now + timedelta(days=6),
            "content_hash": "hash_clogging_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": None,
            "resolved_at": None,
            "verified": False,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=4)).isoformat(), "notes": "Issue reported."},
                {"status": "Notified", "timestamp": (now - timedelta(days=3)).isoformat(), "notes": "Official notified and assigned."}
            ],
            "created_at": now - timedelta(days=4)
        },
        {
            "issue_id": "HH-TN-VRD-001-2026-10005",
            "title": "Low Hanging Water Pipes",
            "description": "Low-hanging water pipe line obstructing vehicle movement in the residential street.",
            "category": "Water Supply",
            "severity": "Low",
            "status": "Notified",
            "lat": 9.5850,
            "lng": 77.9510,
            "ward_id": "TN-VRD-001",
            "ward_name": "Virudhunagar Ward 1",
            "district": "Virudhunagar",
            "state": "Tamil Nadu",
            "photo_url": "",
            "posted_by": "USR-VNR-01",
            "anonymous": False,
            "support_count": 8,
            "days_active": 3,
            "assigned_to": "TN-BDO-VNR-VIRUDHUNAGAR",
            "assigned_role": "Block Development Officer",
            "resolution_deadline": now + timedelta(days=10),
            "content_hash": "hash_pipes_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": None,
            "resolved_at": None,
            "verified": False,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=3)).isoformat(), "notes": "Issue reported."},
                {"status": "Notified", "timestamp": (now - timedelta(days=2)).isoformat(), "notes": "BDO assigned."}
            ],
            "created_at": now - timedelta(days=3)
        },
        {
            "issue_id": "HH-TN-VRD-001-2026-10006",
            "title": "Broken Public Water Tap",
            "description": "The community public tap has a severe leak, wasting hundreds of liters of drinking water every day.",
            "category": "Water Supply",
            "severity": "Medium",
            "status": "In Progress",
            "lat": 9.5862,
            "lng": 77.9531,
            "ward_id": "TN-VRD-001",
            "ward_name": "Virudhunagar Ward 1",
            "district": "Virudhunagar",
            "state": "Tamil Nadu",
            "photo_url": "",
            "posted_by": "USR-VNR-02",
            "anonymous": False,
            "support_count": 31,
            "days_active": 6,
            "assigned_to": "TN-BDO-VNR-VIRUDHUNAGAR",
            "assigned_role": "Block Development Officer",
            "resolution_deadline": now + timedelta(days=2),
            "content_hash": "hash_tap_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": None,
            "resolved_at": None,
            "verified": False,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=6)).isoformat(), "notes": "Issue reported."},
                {"status": "Notified", "timestamp": (now - timedelta(days=5)).isoformat(), "notes": "BDO assigned."},
                {"status": "In Progress", "timestamp": (now - timedelta(days=2)).isoformat(), "notes": "Plumber dispatched to site."}
            ],
            "created_at": now - timedelta(days=6)
        },
        {
            "issue_id": "HH-TN-VRD-002-2026-10007",
            "title": "Damaged Drainage Cover",
            "description": "The slab cover of the open storm water drain is broken, posing a direct hazard to pedestrians at night.",
            "category": "Drainage",
            "severity": "High",
            "status": "In Progress",
            "lat": 9.5910,
            "lng": 77.9610,
            "ward_id": "TN-VRD-002",
            "ward_name": "Virudhunagar Ward 2",
            "district": "Virudhunagar",
            "state": "Tamil Nadu",
            "photo_url": "",
            "posted_by": "USR-VNR-03",
            "anonymous": True,
            "support_count": 52,
            "days_active": 8,
            "assigned_to": "TN-BDO-VNR-VIRUDHUNAGAR",
            "assigned_role": "Block Development Officer",
            "resolution_deadline": now + timedelta(days=1),
            "content_hash": "hash_cover_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": None,
            "resolved_at": None,
            "verified": False,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=8)).isoformat(), "notes": "Issue reported."},
                {"status": "Notified", "timestamp": (now - timedelta(days=7)).isoformat(), "notes": "Official assigned."},
                {"status": "In Progress", "timestamp": (now - timedelta(days=5)).isoformat(), "notes": "Repair request submitted."}
            ],
            "created_at": now - timedelta(days=8)
        },
        {
            "issue_id": "HH-TN-CHN-170-2026-10008",
            "title": "Tree Branch Blocking Walkway",
            "description": "A large banyan tree branch fell during the storm and blocked the footpath on 1st Avenue.",
            "category": "Environment",
            "severity": "Low",
            "status": "Resolved",
            "lat": 13.0055,
            "lng": 80.2590,
            "ward_id": "TN-CHN-170",
            "ward_name": "Adyar",
            "district": "Chennai",
            "state": "Tamil Nadu",
            "photo_url": "",
            "posted_by": "USR-ADYAR-03",
            "anonymous": False,
            "support_count": 12,
            "days_active": 4,
            "assigned_to": "GCC-ZONE-10",
            "assigned_role": "Zone Officer",
            "resolution_deadline": now - timedelta(days=3),
            "content_hash": "hash_tree_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": "https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?auto=format&fit=crop&w=500&q=80",
            "resolved_at": now - timedelta(days=2),
            "verified": True,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=6)).isoformat(), "notes": "Issue reported."},
                {"status": "Notified", "timestamp": (now - timedelta(days=5)).isoformat(), "notes": "Zone officer assigned."},
                {"status": "Resolved", "timestamp": (now - timedelta(days=2)).isoformat(), "notes": "Branch cleared and path swept."}
            ],
            "created_at": now - timedelta(days=6)
        },
        {
            "issue_id": "HH-TN-CHN-179-2026-10009",
            "title": "Stray Animal Menace near School",
            "description": "Large pack of stray dogs barking and chases school children near Velachery Public School.",
            "category": "Safety",
            "severity": "Medium",
            "status": "Resolved",
            "lat": 12.9805,
            "lng": 80.2201,
            "ward_id": "TN-CHN-179",
            "ward_name": "Velachery",
            "district": "Chennai",
            "state": "Tamil Nadu",
            "photo_url": "",
            "posted_by": "USR-VELA-03",
            "anonymous": False,
            "support_count": 36,
            "days_active": 5,
            "assigned_to": "TN-MLA-108",
            "assigned_role": "MLA",
            "resolution_deadline": now - timedelta(days=2),
            "content_hash": "hash_stray_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": "",
            "resolved_at": now - timedelta(days=1),
            "verified": True,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=5)).isoformat(), "notes": "Issue reported."},
                {"status": "Notified", "timestamp": (now - timedelta(days=4)).isoformat(), "notes": "Official assigned."},
                {"status": "Resolved", "timestamp": (now - timedelta(days=1)).isoformat(), "notes": "Animal control team cleared the area."}
            ],
            "created_at": now - timedelta(days=5)
        },
        {
            "issue_id": "HH-TN-VRD-002-2026-10010",
            "title": "Sewer Pipe Leakage on Road",
            "description": "Open sewage line burst, overflowing onto the residential road and creating high health risks.",
            "category": "Drainage",
            "severity": "High",
            "status": "In Progress",
            "lat": 9.5925,
            "lng": 77.9625,
            "ward_id": "TN-VRD-002",
            "ward_name": "Virudhunagar Ward 2",
            "district": "Virudhunagar",
            "state": "Tamil Nadu",
            "photo_url": "",
            "posted_by": "USR-VNR-04",
            "anonymous": False,
            "support_count": 88,
            "days_active": 12,
            "assigned_to": "TN-BDO-VNR-VIRUDHUNAGAR",
            "assigned_role": "Block Development Officer",
            "resolution_deadline": now - timedelta(days=3),
            "content_hash": "hash_sewer_1",
            "duplicate_of": None,
            "extension_count": 0,
            "proof_photo_url": None,
            "resolved_at": None,
            "verified": False,
            "timeline": [
                {"status": "Posted", "timestamp": (now - timedelta(days=12)).isoformat(), "notes": "Issue reported."},
                {"status": "Notified", "timestamp": (now - timedelta(days=11)).isoformat(), "notes": "Official assigned."},
                {"status": "In Progress", "timestamp": (now - timedelta(days=9)).isoformat(), "notes": "Sewer team inspected and ordered replacement parts."}
            ],
            "created_at": now - timedelta(days=12)
        }
    ]

    # 3. Seed 5 Wishes
    wishes = [
        {
            "wish_id": "WH-TN-CHN-170-1",
            "title": "Adyar Pedestrian Skywalk",
            "description": "A modern pedestrian skywalk connecting the Adyar bus stand directly to the metro station corridor to ease foot traffic congestions.",
            "imageUrl": "https://images.unsplash.com/photo-1549692520-acc6669e2f0c?auto=format&fit=crop&w=500&q=80",
            "imageType": "ai_generated",
            "category": "Infrastructure",
            "ward_id": "TN-CHN-170",
            "support_count": 142,
            "posted_by": "USR-ADYAR-01",
            "status": "Active",
            "cluster_id": None,
            "is_trending": True,
            "created_at": now - timedelta(days=10)
        },
        {
            "wish_id": "WH-TN-CHN-170-2",
            "title": "Neighborhood Micro-Library",
            "description": "Establish small community bookshelf booths in local parks where residents can swap and read books.",
            "imageUrl": "https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=500&q=80",
            "imageType": "ai_generated",
            "category": "Education",
            "ward_id": "TN-CHN-170",
            "support_count": 56,
            "posted_by": "USR-ADYAR-05",
            "status": "Active",
            "cluster_id": None,
            "is_trending": False,
            "created_at": now - timedelta(days=4)
        },
        {
            "wish_id": "WH-TN-CHN-179-1",
            "title": "Velachery Lake Park Walkway",
            "description": "Revitalize the perimeter around Velachery lake with a dedicated jogging track, solar lights, and seating benches.",
            "imageUrl": "https://images.unsplash.com/photo-1519331379826-f10be5486c6f?auto=format&fit=crop&w=500&q=80",
            "imageType": "ai_generated",
            "category": "Recreation",
            "ward_id": "TN-CHN-179",
            "support_count": 210,
            "posted_by": "USR-VELA-05",
            "status": "Active",
            "cluster_id": None,
            "is_trending": True,
            "created_at": now - timedelta(days=14)
        },
        {
            "wish_id": "WH-TN-VRD-001-1",
            "title": "Community Center Solar Grid",
            "description": "Equip the public community center with solar power panels to ensure 24/7 power during emergency load-shedding hours.",
            "imageUrl": "https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=500&q=80",
            "imageType": "ai_generated",
            "category": "Green Energy",
            "ward_id": "TN-VRD-001",
            "support_count": 89,
            "posted_by": "USR-VNR-02",
            "status": "Active",
            "cluster_id": None,
            "is_trending": False,
            "created_at": now - timedelta(days=6)
        },
        {
            "wish_id": "WH-TN-VRD-002-1",
            "title": "Rainwater Harvesting Pit Network",
            "description": "Install street-level storm-drain rainwater recharge pits across all main residential lanes in the ward to improve groundwater levels.",
            "imageUrl": "",
            "imageType": "ai_generated",
            "category": "Water Management",
            "ward_id": "TN-VRD-002",
            "support_count": 120,
            "posted_by": "USR-VNR-04",
            "status": "Active",
            "cluster_id": None,
            "is_trending": True,
            "created_at": now - timedelta(days=9)
        }
    ]

    # 4. Seed 3 Notices
    notices = [
        {
            "notice_id": "NOT-CHN-170-1",
            "title": "Scheduled Power Outage in Adyar",
            "content": "Please note that there will be a scheduled electricity maintenance shutdown in Adyar Zone sectors 1 to 4 on July 2 from 9 AM to 4 PM.",
            "type": "Notice",
            "posted_by_official_id": "TN-MLA-100",
            "ward_id": "TN-CHN-170",
            "circle": "Ward",
            "verified_official_post": True,
            "cannot_delete": True,
            "created_at": now - timedelta(days=1)
        },
        {
            "notice_id": "NOT-CHN-179-1",
            "title": "Free Health Camp at Velachery Ward Office",
            "content": "Join us for a free multi-specialty medical health checkup and consultation camp on Sunday, July 5, at the Velachery Ward 179 office.",
            "type": "Announcement",
            "posted_by_official_id": "TN-MLA-108",
            "ward_id": "TN-CHN-179",
            "circle": "Ward",
            "verified_official_post": True,
            "cannot_delete": False,
            "created_at": now - timedelta(hours=6)
        },
        {
            "notice_id": "NOT-VRD-001-1",
            "title": "Drinking Water Supply Pipe Cleaning",
            "content": "Water supply will be suspended or restricted in Virudhunagar Ward 1 on June 30 due to routine main line filter tank flush and wash.",
            "type": "Alert",
            "posted_by_official_id": "TN-BDO-VNR-VIRUDHUNAGAR",
            "ward_id": "TN-VRD-001",
            "circle": "Ward",
            "verified_official_post": True,
            "cannot_delete": True,
            "created_at": now - timedelta(hours=2)
        }
    ]

    # 5. Seed 5 Alerts (Notifications)
    alerts = [
        {
            "alert_id": "ALT-001",
            "user_id": "USR-ADYAR-01",
            "type": "Notice Published",
            "title": "New Ward Notice Published",
            "description": "An official announcement 'Scheduled Power Outage in Adyar' has been posted by the ward representative.",
            "issue_id": "",
            "read": False,
            "created_at": now - timedelta(days=1)
        },
        {
            "alert_id": "ALT-002",
            "user_id": "USR-VELA-01",
            "type": "Status Update",
            "title": "Issue Marked as Notified",
            "description": "Your issue 'Pothole on Velachery Main Road' has been assigned to MLA Office.",
            "issue_id": "HH-TN-CHN-179-2026-10003",
            "read": False,
            "created_at": now - timedelta(days=4)
        },
        {
            "alert_id": "ALT-003",
            "user_id": "USR-VNR-02",
            "type": "Status Update",
            "title": "Issue Marked In Progress",
            "description": "BDO Virudhunagar has dispatched a plumber to resolve 'Broken Public Water Tap'.",
            "issue_id": "HH-TN-VRD-001-2026-10006",
            "read": True,
            "created_at": now - timedelta(days=2)
        },
        {
            "alert_id": "ALT-004",
            "user_id": "USR-ADYAR-03",
            "type": "Issue Resolved",
            "title": "Issue Successfully Resolved",
            "description": "Great news! Your reported issue 'Tree Branch Blocking Walkway' has been marked as Resolved by the Zone Officer.",
            "issue_id": "HH-TN-CHN-170-2026-10008",
            "read": False,
            "created_at": now - timedelta(days=2)
        },
        {
            "alert_id": "ALT-005",
            "user_id": "USR-VNR-04",
            "type": "Trending Wish",
            "title": "Your Wish is Now Trending!",
            "description": "Your suggestion 'Rainwater Harvesting Pit Network' has received over 100 neighborhood supports!",
            "issue_id": "",
            "read": False,
            "created_at": now - timedelta(days=1)
        }
    ]

    print("Seeding issues...")
    for item in issues:
      db.collection("issues").document(item["issue_id"]).set(item)

    print("Seeding wishes...")
    for item in wishes:
      db.collection("wishes").document(item["wish_id"]).set(item)

    print("Seeding notices...")
    for item in notices:
      db.collection("notices").document(item["notice_id"]).set(item)

    print("Seeding alerts...")
    for item in alerts:
      db.collection("alerts").document(item["alert_id"]).set(item)

    print("Seeding completed successfully!")

if __name__ == "__main__":
    seed_demo_data()
