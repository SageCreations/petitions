import json
import threading
import time
import uuid
from typing import Dict, Any, List, Optional

# Path to your JSON file acting as your "database"
DATABASE_FILE = "database.json"

# In-memory database cache
# It will have a structure like: {"petitions": [ ... petition objects ... ]}
database: Dict[str, List[Dict[str, Any]]] = {"petitions": []}

# A lock to ensure safe concurrent writes to the JSON file.
db_lock = threading.Lock()


def load_database() -> None:
    """
    Load the petitions from the JSON file into memory.
    If the file does not exist, initialize with an empty petitions list.
    """
    global database
    try:
        with open(DATABASE_FILE, "r") as f:
            database = json.load(f)
    except FileNotFoundError:
        # Initialize an empty database and create the file.
        database = {"petitions": []}
        save_database()
    except json.JSONDecodeError:
        # If the JSON is invalid, log the issue and start fresh.
        print("Error decoding JSON. Starting with an empty database.")
        database = {"petitions": []}


def save_database() -> None:
    """
    Save the in-memory database back to the JSON file.
    This should be called after any modification.
    """
    with db_lock:
        with open(DATABASE_FILE, "w") as f:
            json.dump(database, f, indent=4)


def get_all_petitions() -> List[Dict[str, Any]]:
    """
    Return a list of all petition objects.
    """
    return database.get("petitions", [])


def get_petition_by_id(petition_id: str) -> Optional[Dict[str, Any]]:
    """
    Return a single petition by its ID, or None if not found.
    """
    for petition in database.get("petitions", []):
        if petition.get("petition_id") == petition_id:
            return petition
    return None


def create_petition(petition_data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Create a new petition with the provided data.
    The function will automatically generate a unique petition_id and timestamps.
    """
    new_petition = petition_data.copy()

    # Generate a unique petition ID
    new_petition["petition_id"] = str(uuid.uuid4())

    # Generate current timestamp in ISO format (UTC)
    timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    new_petition["createdAt"] = timestamp
    new_petition["updatedAt"] = timestamp

    with db_lock:
        database.setdefault("petitions", []).append(new_petition)
        save_database()

    return new_petition


def update_petition(petition_id: str, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """
    Update an existing petition identified by petition_id.
    The update_data should be a dictionary with the fields to update.
    The function also updates the 'updatedAt' timestamp.
    """
    with db_lock:
        for index, petition in enumerate(database.get("petitions", [])):
            if petition.get("petition_id") == petition_id:
                # Update the petition with the new data.
                petition.update(update_data)
                # Update the 'updatedAt' timestamp.
                petition["updatedAt"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
                database["petitions"][index] = petition
                save_database()
                return petition
    return None


def delete_petition(petition_id: str) -> bool:
    """
    Delete the petition with the given petition_id.
    Returns True if deletion was successful, False otherwise.
    """
    with db_lock:
        petitions = database.get("petitions", [])
        for index, petition in enumerate(petitions):
            if petition.get("petition_id") == petition_id:
                del petitions[index]
                save_database()
                return True
    return False
