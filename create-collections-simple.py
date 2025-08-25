#!/usr/bin/env python3
"""
Simple script to create PocketBase collections
Run this after you're logged into PocketBase admin interface
"""

import requests
import json

BASE_URL = "http://localhost:8090"

def create_signals_collection(session):
    """Create signals collection"""
    signals_data = {
        "name": "signals",
        "type": "base",
        "schema": [
            {"name": "symbol", "type": "text", "required": True, "options": {"min": 1, "max": 20, "pattern": "^[A-Z0-9]+$"}},
            {"name": "companyName", "type": "text", "required": True, "options": {"min": 1, "max": 255}},
            {"name": "type", "type": "select", "required": True, "options": {"maxSelect": 1, "values": ["stock", "crypto", "forex", "commodity"]}},
            {"name": "action", "type": "select", "required": True, "options": {"maxSelect": 1, "values": ["buy", "sell", "hold"]}},
            {"name": "currentPrice", "type": "number", "required": True, "options": {"min": 0}},
            {"name": "targetPrice", "type": "number", "required": True, "options": {"min": 0}},
            {"name": "stopLoss", "type": "number", "required": True, "options": {"min": 0}},
            {"name": "confidence", "type": "number", "required": True, "options": {"min": 0, "max": 1}},
            {"name": "reasoning", "type": "text", "required": True, "options": {"min": 10, "max": 2000}},
            {"name": "expiresAt", "type": "date", "required": False},
            {"name": "status", "type": "select", "required": True, "options": {"maxSelect": 1, "values": ["active", "completed", "cancelled", "expired"]}},
            {"name": "tags", "type": "json", "required": False},
            {"name": "requiredTier", "type": "select", "required": True, "options": {"maxSelect": 1, "values": ["free", "basic", "premium", "pro"]}},
            {"name": "profitLossPercentage", "type": "number", "required": False},
            {"name": "imageUrl", "type": "url", "required": False}
        ],
        "listRule": "",
        "viewRule": "",
        "createRule": "",
        "updateRule": "",
        "deleteRule": ""
    }
    
    try:
        response = session.post(f"{BASE_URL}/api/collections", json=signals_data)
        if response.status_code == 200:
            print("✅ Signals collection created successfully")
            return True
        elif response.status_code == 400 and "already exists" in response.text.lower():
            print("ℹ️  Signals collection already exists")
            return True
        else:
            print(f"❌ Signals creation failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Signals collection error: {e}")
        return False

def create_watchlist_collection(session):
    """Create watchlistItems collection"""
    watchlist_data = {
        "name": "watchlistItems", 
        "type": "base",
        "schema": [
            {"name": "userId", "type": "relation", "required": True, "options": {"collectionId": "", "cascadeDelete": True, "maxSelect": 1}},
            {"name": "symbol", "type": "text", "required": True, "options": {"min": 1, "max": 20, "pattern": "^[A-Z0-9]+$"}},
            {"name": "companyName", "type": "text", "required": True, "options": {"min": 1, "max": 255}},
            {"name": "type", "type": "select", "required": True, "options": {"maxSelect": 1, "values": ["stock", "crypto", "forex", "commodity"]}},
            {"name": "currentPrice", "type": "number", "required": True, "options": {"min": 0}},
            {"name": "priceChange", "type": "number", "required": True},
            {"name": "priceChangePercent", "type": "number", "required": True},
            {"name": "addedAt", "type": "date", "required": True},
            {"name": "isPriceAlertEnabled", "type": "bool", "required": False},
            {"name": "priceAlertTarget", "type": "number", "required": False, "options": {"min": 0}},
            {"name": "notes", "type": "text", "required": False, "options": {"max": 1000}}
        ],
        "listRule": "@request.auth.id != '' && userId = @request.auth.id",
        "viewRule": "@request.auth.id != '' && userId = @request.auth.id", 
        "createRule": "@request.auth.id != '' && userId = @request.auth.id",
        "updateRule": "@request.auth.id != '' && userId = @request.auth.id",
        "deleteRule": "@request.auth.id != '' && userId = @request.auth.id"
    }
    
    # First get the users collection ID
    try:
        collections_response = session.get(f"{BASE_URL}/api/collections")
        if collections_response.status_code == 200:
            collections = collections_response.json()["items"]
            users_collection = next((c for c in collections if c["name"] == "users"), None)
            if users_collection:
                # Update the userId relation to point to users collection
                watchlist_data["schema"][0]["options"]["collectionId"] = users_collection["id"]
            else:
                print("❌ Users collection not found")
                return False
        else:
            print(f"❌ Failed to get collections: {collections_response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error getting collections: {e}")
        return False
    
    try:
        response = session.post(f"{BASE_URL}/api/collections", json=watchlist_data)
        if response.status_code == 200:
            print("✅ Watchlist collection created successfully")
            return True
        elif response.status_code == 400 and "already exists" in response.text.lower():
            print("ℹ️  Watchlist collection already exists") 
            return True
        else:
            print(f"❌ Watchlist creation failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Watchlist collection error: {e}")
        return False

def main():
    print("🔧 Creating PocketBase collections...")
    print("📋 Make sure you're logged into PocketBase admin at http://localhost:8090/_/")
    print()
    
    # Get auth token from user
    print("To get your auth token:")
    print("1. Open browser dev tools (F12) on PocketBase admin page")
    print("2. Go to Application/Storage > Local Storage > http://localhost:8090")
    print("3. Find 'pocketbase_auth' key and copy the 'token' value")
    print()
    
    # Try without token first (sometimes works if browser session is active)
    session = requests.Session()
    print("Trying without auth token first...")
    
    # Try to create collections
    signals_success = create_signals_collection(session)
    watchlist_success = create_watchlist_collection(session)
    
    if signals_success and watchlist_success:
        print("\n🎉 All collections created successfully!")
        print("📱 You can now test the Flutter app functionality")
        return True
    else:
        print("\n❌ Some collections failed to create")
        print("Try the manual method or check your auth token")
        return False

if __name__ == "__main__":
    main()