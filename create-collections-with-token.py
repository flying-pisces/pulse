#!/usr/bin/env python3
import requests
import json
import sys

BASE_URL = "http://localhost:8090"

def create_collections(token):
    session = requests.Session()
    session.headers.update({"Authorization": f"Bearer {token}"})
    
    # Create signals collection
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
        ]
    }
    
    print("Creating signals collection...")
    signals_response = session.post(f"{BASE_URL}/api/collections", json=signals_data)
    
    if signals_response.status_code == 200:
        print("✅ Signals collection created!")
    elif "already exists" in signals_response.text.lower():
        print("ℹ️  Signals collection already exists")
    else:
        print(f"❌ Signals failed: {signals_response.status_code} - {signals_response.text}")
        return False
        
    # Get users collection ID for watchlist relation
    collections_response = session.get(f"{BASE_URL}/api/collections")
    users_collection_id = None
    
    if collections_response.status_code == 200:
        collections = collections_response.json()["items"]
        for collection in collections:
            if collection["name"] == "users":
                users_collection_id = collection["id"]
                break
    
    if not users_collection_id:
        print("❌ Could not find users collection ID")
        return False
        
    # Create watchlistItems collection  
    watchlist_data = {
        "name": "watchlistItems",
        "type": "base",
        "schema": [
            {"name": "userId", "type": "relation", "required": True, "options": {"collectionId": users_collection_id, "cascadeDelete": True, "maxSelect": 1}},
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
        ]
    }
    
    print("Creating watchlistItems collection...")
    watchlist_response = session.post(f"{BASE_URL}/api/collections", json=watchlist_data)
    
    if watchlist_response.status_code == 200:
        print("✅ Watchlist collection created!")
        return True
    elif "already exists" in watchlist_response.text.lower():
        print("ℹ️  Watchlist collection already exists")
        return True
    else:
        print(f"❌ Watchlist failed: {watchlist_response.status_code} - {watchlist_response.text}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 create-collections-with-token.py <your-auth-token>")
        print()
        print("To get your auth token:")
        print("1. Open PocketBase admin in browser")
        print("2. Open dev tools (F12)")
        print("3. Go to Application > Local Storage > localhost:8090")
        print("4. Find 'pocketbase_auth' and copy the 'token' value")
        exit(1)
        
    token = sys.argv[1]
    print("🔧 Creating PocketBase collections with auth token...")
    
    if create_collections(token):
        print("🎉 All collections created successfully!")
        print("📱 You can now test the Flutter app!")
    else:
        print("❌ Failed to create some collections")