#!/usr/bin/env python3
import requests
import json
import sys

BASE_URL = "http://localhost:8090"

def test_minimal_collection(token):
    session = requests.Session()
    session.headers.update({"Authorization": f"Bearer {token}"})
    
    # Test 1: Minimal collection
    print("Testing minimal collection...")
    minimal_data = {
        "name": "test_signals",
        "type": "base",
        "schema": []
    }
    
    response = session.post(f"{BASE_URL}/api/collections", json=minimal_data)
    print(f"Minimal collection: {response.status_code}")
    if response.status_code != 200:
        print(f"Error: {response.text}")
        return False
    else:
        print("✅ Minimal collection works")
        # Delete it
        collection_id = response.json()["id"]
        session.delete(f"{BASE_URL}/api/collections/{collection_id}")
    
    # Test 2: Just text fields
    print("\nTesting with basic text fields...")
    text_only = {
        "name": "test_signals2",
        "type": "base", 
        "schema": [
            {"name": "symbol", "type": "text", "required": True, "options": {"min": 1, "max": 20}},
            {"name": "companyName", "type": "text", "required": True, "options": {"min": 1, "max": 255}}
        ]
    }
    
    response = session.post(f"{BASE_URL}/api/collections", json=text_only)
    print(f"Text fields: {response.status_code}")
    if response.status_code != 200:
        print(f"Error: {response.text}")
        return False
    else:
        print("✅ Text fields work")
        collection_id = response.json()["id"]
        session.delete(f"{BASE_URL}/api/collections/{collection_id}")
    
    # Test 3: Add JSON field
    print("\nTesting JSON field...")
    with_json = {
        "name": "test_signals3",
        "type": "base",
        "schema": [
            {"name": "symbol", "type": "text", "required": True, "options": {"min": 1, "max": 20}},
            {"name": "tags", "type": "json", "required": False}
        ]
    }
    
    response = session.post(f"{BASE_URL}/api/collections", json=with_json)
    print(f"With JSON field: {response.status_code}")
    if response.status_code != 200:
        print(f"Error: {response.text}")
        # Try with maxSize
        print("Trying JSON with maxSize...")
        with_json["schema"][1]["options"] = {"maxSize": 2048}
        response = session.post(f"{BASE_URL}/api/collections", json=with_json)
        with_json["name"] = "test_signals3b"
        response = session.post(f"{BASE_URL}/api/collections", json=with_json)
        print(f"JSON with maxSize: {response.status_code}")
        if response.status_code != 200:
            print(f"Error: {response.text}")
            return False
        else:
            collection_id = response.json()["id"]
            session.delete(f"{BASE_URL}/api/collections/{collection_id}")
    else:
        print("✅ JSON field works")
        collection_id = response.json()["id"]
        session.delete(f"{BASE_URL}/api/collections/{collection_id}")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 debug-schema.py <your-auth-token>")
        exit(1)
    
    token = sys.argv[1]
    print("🔧 Testing PocketBase schema requirements...")
    
    if test_minimal_collection(token):
        print("🎉 Schema tests passed! Now we know what works.")
    else:
        print("❌ Schema tests failed")