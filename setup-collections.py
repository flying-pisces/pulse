#!/usr/bin/env python3
"""
Quick setup script to create PocketBase collections via API
This creates the essential collections for testing
"""

import requests
import json

# PocketBase settings
BASE_URL = "http://localhost:8090"
ADMIN_EMAIL = "admin@pulse.com"
ADMIN_PASSWORD = "admin123456"

def create_admin_and_collections():
    session = requests.Session()
    
    print("🔧 Setting up PocketBase collections...")
    
    # Skip admin creation - should be done through UI first
    print("ℹ️  Skipping admin creation - please create admin through http://localhost:8090/_/ first")
    
    # Login as admin
    try:
        auth_response = session.post(f"{BASE_URL}/api/admins/auth-with-password", json={
            "identity": ADMIN_EMAIL,
            "password": ADMIN_PASSWORD
        })
        
        if auth_response.status_code == 200:
            auth_data = auth_response.json()
            session.headers.update({"Authorization": f"Bearer {auth_data['token']}"})
            print("✅ Admin authenticated successfully")
        else:
            print(f"❌ Admin auth failed: {auth_response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Admin auth error: {e}")
        return False
    
    # Update the existing users collection to match our schema
    users_schema = [
        {
            "name": "firstName",
            "type": "text",
            "required": True,
            "options": {"min": 1, "max": 100}
        },
        {
            "name": "lastName", 
            "type": "text",
            "required": True,
            "options": {"min": 1, "max": 100}
        },
        {
            "name": "profileImageUrl",
            "type": "url",
            "required": False
        },
        {
            "name": "isVerified",
            "type": "bool",
            "required": False
        },
        {
            "name": "subscriptionTier",
            "type": "select",
            "required": True,
            "options": {
                "maxSelect": 1,
                "values": ["free", "basic", "premium", "pro"]
            }
        },
        {
            "name": "subscriptionExpiresAt",
            "type": "date",
            "required": False
        },
        {
            "name": "authProvider",
            "type": "select",
            "required": True,
            "options": {
                "maxSelect": 1,
                "values": ["email", "google", "apple"]
            }
        },
        {
            "name": "providerId",
            "type": "text",
            "required": False,
            "options": {"max": 255}
        },
        {
            "name": "providerData",
            "type": "json",
            "required": False
        }
    ]
    
    # Get existing users collection
    try:
        collections_response = session.get(f"{BASE_URL}/api/collections")
        collections = collections_response.json()["items"]
        users_collection = next((c for c in collections if c["name"] == "users"), None)
        
        if users_collection:
            # Update users collection
            update_response = session.patch(f"{BASE_URL}/api/collections/{users_collection['id']}", json={
                "schema": users_schema,
                "options": {
                    "allowEmailAuth": True,
                    "allowOAuth2Auth": True,
                    "allowUsernameAuth": False,
                    "minPasswordLength": 8,
                    "requireEmail": True
                }
            })
            
            if update_response.status_code == 200:
                print("✅ Users collection updated successfully")
            else:
                print(f"⚠️  Users update response: {update_response.status_code}")
        
    except Exception as e:
        print(f"⚠️  Users collection update: {e}")
    
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
        ],
        "listRule": "@request.auth.id != '' && (requiredTier = 'free' || (@request.auth.subscriptionTier = 'basic' && (requiredTier = 'free' || requiredTier = 'basic')) || (@request.auth.subscriptionTier = 'premium' && requiredTier != 'pro') || @request.auth.subscriptionTier = 'pro')",
        "viewRule": "@request.auth.id != '' && (requiredTier = 'free' || (@request.auth.subscriptionTier = 'basic' && (requiredTier = 'free' || requiredTier = 'basic')) || (@request.auth.subscriptionTier = 'premium' && requiredTier != 'pro') || @request.auth.subscriptionTier = 'pro')",
        "createRule": "",
        "updateRule": "",
        "deleteRule": ""
    }
    
    try:
        signals_response = session.post(f"{BASE_URL}/api/collections", json=signals_data)
        if signals_response.status_code == 200:
            print("✅ Signals collection created successfully")
        elif signals_response.status_code == 400 and "already exists" in signals_response.text.lower():
            print("ℹ️  Signals collection already exists")
        else:
            print(f"⚠️  Signals creation response: {signals_response.status_code}")
    except Exception as e:
        print(f"⚠️  Signals collection creation: {e}")
    
    # Create watchlistItems collection
    watchlist_data = {
        "name": "watchlistItems",
        "type": "base",
        "schema": [
            {"name": "userId", "type": "relation", "required": True, "options": {"collectionId": "users", "cascadeDelete": True, "maxSelect": 1}},
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
    
    try:
        watchlist_response = session.post(f"{BASE_URL}/api/collections", json=watchlist_data)
        if watchlist_response.status_code == 200:
            print("✅ Watchlist collection created successfully")
        elif watchlist_response.status_code == 400 and "already exists" in watchlist_response.text.lower():
            print("ℹ️  Watchlist collection already exists")
        else:
            print(f"⚠️  Watchlist creation response: {watchlist_response.status_code}")
    except Exception as e:
        print(f"⚠️  Watchlist collection creation: {e}")
    
    print("\n🎉 PocketBase setup complete!")
    print("🌐 Admin UI: http://localhost:8090/_/")
    print(f"👤 Admin login: {ADMIN_EMAIL}")
    print("📱 You can now run: flutter run -d chrome")
    
    return True

if __name__ == "__main__":
    create_admin_and_collections()