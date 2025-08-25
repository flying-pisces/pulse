#!/usr/bin/env python3
import requests
import json
import sys

BASE_URL = "http://localhost:8090"
ADMIN_EMAIL = "test@pulse.com"  # Change if different
ADMIN_PASSWORD = "admin123456"   # Change if different

def authenticate_and_create():
    session = requests.Session()
    
    print("🔑 Authenticating as admin...")
    
    # First, authenticate to get a fresh token
    auth_response = session.post(f"{BASE_URL}/api/admins/auth-with-password", json={
        "identity": ADMIN_EMAIL,
        "password": ADMIN_PASSWORD
    })
    
    if auth_response.status_code != 200:
        print(f"❌ Authentication failed: {auth_response.status_code}")
        print(f"Response: {auth_response.text}")
        print("\n🔧 Possible fixes:")
        print("1. Check admin email/password in the script")
        print("2. Create admin user through PocketBase UI first")
        return False
    
    auth_data = auth_response.json()
    token = auth_data['token']
    print(f"✅ Got fresh auth token: {token[:20]}...")
    
    # Set authorization header
    session.headers.update({"Authorization": f"Bearer {token}"})
    
    # Now create collections immediately while token is fresh
    print("\n🔧 Creating signals collection...")
    
    signals_data = {
        "name": "signals",
        "type": "base",
        "schema": [
            {"name": "symbol", "type": "text", "required": True, "options": {"min": 1, "max": 20}},
            {"name": "companyName", "type": "text", "required": True, "options": {"min": 1, "max": 255}},
            {"name": "action", "type": "select", "required": True, "options": {"maxSelect": 1, "values": ["buy", "sell", "hold"]}},
            {"name": "currentPrice", "type": "number", "required": True, "options": {"min": 0}},
            {"name": "targetPrice", "type": "number", "required": True, "options": {"min": 0}},
            {"name": "reasoning", "type": "text", "required": True, "options": {"min": 10, "max": 2000}},
            {"name": "status", "type": "select", "required": True, "options": {"maxSelect": 1, "values": ["active", "completed", "cancelled", "expired"]}}
        ]
    }
    
    signals_response = session.post(f"{BASE_URL}/api/collections", json=signals_data)
    
    if signals_response.status_code == 200:
        print("✅ Signals collection created successfully!")
    elif "already exists" in signals_response.text.lower():
        print("ℹ️  Signals collection already exists")
    else:
        print(f"❌ Signals creation failed: {signals_response.status_code}")
        print(f"Response: {signals_response.text}")
        return False
    
    print("\n🔧 Creating watchlistItems collection...")
    
    # Get users collection ID first
    collections_response = session.get(f"{BASE_URL}/api/collections")
    users_collection_id = None
    
    if collections_response.status_code == 200:
        collections = collections_response.json()["items"]
        for collection in collections:
            if collection["name"] == "users":
                users_collection_id = collection["id"]
                break
    
    if not users_collection_id:
        print("⚠️  Warning: Could not find users collection ID, will create without relation")
        users_collection_id = ""
    
    watchlist_data = {
        "name": "watchlistItems",
        "type": "base",
        "schema": [
            {"name": "symbol", "type": "text", "required": True, "options": {"min": 1, "max": 20}},
            {"name": "companyName", "type": "text", "required": True, "options": {"min": 1, "max": 255}},
            {"name": "currentPrice", "type": "number", "required": True, "options": {"min": 0}},
            {"name": "addedAt", "type": "date", "required": True}
        ]
    }
    
    # Add userId relation if we found users collection
    if users_collection_id:
        watchlist_data["schema"].insert(0, {
            "name": "userId", 
            "type": "relation", 
            "required": True, 
            "options": {"collectionId": users_collection_id, "cascadeDelete": True, "maxSelect": 1}
        })
    
    watchlist_response = session.post(f"{BASE_URL}/api/collections", json=watchlist_data)
    
    if watchlist_response.status_code == 200:
        print("✅ WatchlistItems collection created successfully!")
    elif "already exists" in watchlist_response.text.lower():
        print("ℹ️  WatchlistItems collection already exists")
    else:
        print(f"❌ WatchlistItems creation failed: {watchlist_response.status_code}")
        print(f"Response: {watchlist_response.text}")
        return False
    
    print("\n🎉 All collections created successfully!")
    return True

if __name__ == "__main__":
    print("🔧 Creating PocketBase collections with fresh authentication...")
    print(f"📡 Using admin credentials: {ADMIN_EMAIL}")
    print("💡 If authentication fails, update the credentials at the top of this script")
    print()
    
    if authenticate_and_create():
        print("✅ Setup complete! You can now test the Flutter app.")
    else:
        print("❌ Setup failed. Check the error messages above.")
