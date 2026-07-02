from google.adk.workflow import node
from google.adk.events.event import Event
from google.adk.events.event_actions import EventActions
from google.adk.agents.context import Context
import re
import json
from typing import Any
import firestore_client
from firebase_admin import firestore

INJECTION_PATTERNS = [
    r"ignore previous instructions",
    r"bypass",
    r"auto.?approve",
    r"override rules",
    r"forget your instructions",
    r"you are now",
]

def parse_node_input(node_input: Any) -> dict:
    if not node_input:
        return {}
    if isinstance(node_input, dict):
        return node_input
    
    # Handle types.Content from ADK runner
    if hasattr(node_input, "parts") and node_input.parts:
        text = ""
        for p in node_input.parts:
            if hasattr(p, "text") and p.text:
                text += p.text
        text = text.strip()
        try:
            return json.loads(text)
        except Exception:
            return {"description": text, "title": ""}
            
    # Handle string input
    if isinstance(node_input, str):
        try:
            return json.loads(node_input)
        except Exception:
            return {"description": node_input, "title": ""}
            
    return {}

@node
def security_checkpoint(ctx: Context, node_input: Any):
    data = parse_node_input(node_input)
    
    text = data.get("description", "") + " " + data.get("title", "")
    
    # PII Redaction
    text = re.sub(r'\b\d{12}\b', '[REDACTED-AADHAAR]', text)
    text = re.sub(r'(\+91)?[6-9]\d{9}', '[REDACTED-PHONE]', text)
    text = re.sub(r'\S+@\S+\.\S+', '[REDACTED-EMAIL]', text)
    
    # Injection Detection
    for pattern in INJECTION_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            # Log as security event in Firestore
            try:
                db = firestore_client.get_db()
                db.collection("security_events").add({
                    "event_type": "prompt_injection",
                    "input_data": data,
                    "flagged_text": text,
                    "timestamp": firestore.SERVER_TIMESTAMP
                })
            except Exception as e:
                print(f"Error logging security event to Firestore: {e}")

            yield Event(
                output=data,
                actions=EventActions(
                    state_delta={"security_flag": "injection_detected"},
                    route="human_review"
                )
            )
            return
    
    data["description"] = text
    yield Event(
        output=data,
        actions=EventActions(route="clean")
    )
