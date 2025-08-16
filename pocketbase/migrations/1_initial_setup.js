/// <reference path="../pb_data/types.d.ts" />

/**
 * Initial setup migration for Pulse trading signals app
 * Creates all necessary collections and configurations
 */
migrate((db) => {
  // Create users collection (auth collection)
  const users = new Collection({
    "id": "users",
    "name": "users",
    "type": "auth",
    "system": false,
    "schema": [
      {
        "id": "firstName",
        "name": "firstName", 
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 100,
          "pattern": ""
        }
      },
      {
        "id": "lastName",
        "name": "lastName",
        "type": "text", 
        "required": true,
        "options": {
          "min": 1,
          "max": 100,
          "pattern": ""
        }
      },
      {
        "id": "profileImageUrl",
        "name": "profileImageUrl",
        "type": "url",
        "required": false,
        "options": {
          "exceptDomains": [],
          "onlyDomains": []
        }
      },
      {
        "id": "isVerified",
        "name": "isVerified",
        "type": "bool",
        "required": false,
        "options": {}
      },
      {
        "id": "subscriptionTier",
        "name": "subscriptionTier",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["free", "basic", "premium", "pro"]
        }
      },
      {
        "id": "subscriptionExpiresAt", 
        "name": "subscriptionExpiresAt",
        "type": "date",
        "required": false,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "id": "authProvider",
        "name": "authProvider",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["email", "google", "apple"]
        }
      },
      {
        "id": "providerId",
        "name": "providerId", 
        "type": "text",
        "required": false,
        "options": {
          "min": 0,
          "max": 255,
          "pattern": ""
        }
      },
      {
        "id": "providerData",
        "name": "providerData",
        "type": "json",
        "required": false,
        "options": {}
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_users_email ON users (email)",
      "CREATE INDEX idx_users_provider ON users (authProvider, providerId)",
      "CREATE INDEX idx_users_subscription ON users (subscriptionTier, subscriptionExpiresAt)"
    ],
    "listRule": "id = @request.auth.id",
    "viewRule": "id = @request.auth.id", 
    "createRule": "",
    "updateRule": "id = @request.auth.id",
    "deleteRule": "id = @request.auth.id",
    "options": {
      "allowEmailAuth": true,
      "allowOAuth2Auth": true,
      "allowUsernameAuth": false,
      "exceptEmailDomains": [],
      "manageRule": null,
      "minPasswordLength": 8,
      "onlyEmailDomains": [],
      "onlyVerified": false,
      "requireEmail": true
    }
  });

  // Create signals collection
  const signals = new Collection({
    "id": "signals",
    "name": "signals",
    "type": "base",
    "system": false,
    "schema": [
      {
        "id": "symbol",
        "name": "symbol",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 20,
          "pattern": "^[A-Z0-9]+$"
        }
      },
      {
        "id": "companyName",
        "name": "companyName",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 255,
          "pattern": ""
        }
      },
      {
        "id": "type",
        "name": "type",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["stock", "crypto", "forex", "commodity"]
        }
      },
      {
        "id": "action",
        "name": "action", 
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["buy", "sell", "hold"]
        }
      },
      {
        "id": "currentPrice",
        "name": "currentPrice",
        "type": "number",
        "required": true,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "targetPrice",
        "name": "targetPrice",
        "type": "number",
        "required": true,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "stopLoss",
        "name": "stopLoss",
        "type": "number",
        "required": true,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "confidence",
        "name": "confidence",
        "type": "number",
        "required": true,
        "options": {
          "min": 0,
          "max": 1,
          "noDecimal": false
        }
      },
      {
        "id": "reasoning",
        "name": "reasoning",
        "type": "text",
        "required": true,
        "options": {
          "min": 10,
          "max": 2000,
          "pattern": ""
        }
      },
      {
        "id": "expiresAt",
        "name": "expiresAt",
        "type": "date",
        "required": false,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "id": "status",
        "name": "status",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["active", "completed", "cancelled", "expired"]
        }
      },
      {
        "id": "tags",
        "name": "tags",
        "type": "json",
        "required": false,
        "options": {}
      },
      {
        "id": "requiredTier",
        "name": "requiredTier",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["free", "basic", "premium", "pro"]
        }
      },
      {
        "id": "profitLossPercentage",
        "name": "profitLossPercentage",
        "type": "number",
        "required": false,
        "options": {
          "min": null,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "imageUrl",
        "name": "imageUrl",
        "type": "url",
        "required": false,
        "options": {
          "exceptDomains": [],
          "onlyDomains": []
        }
      }
    ],
    "indexes": [
      "CREATE INDEX idx_signals_symbol ON signals (symbol)",
      "CREATE INDEX idx_signals_type ON signals (type)",
      "CREATE INDEX idx_signals_status ON signals (status)",
      "CREATE INDEX idx_signals_tier ON signals (requiredTier)",
      "CREATE INDEX idx_signals_created ON signals (created)",
      "CREATE INDEX idx_signals_expires ON signals (expiresAt)"
    ],
    "listRule": "@request.auth.id != '' && (requiredTier = 'free' || (@request.auth.subscriptionTier = 'basic' && (requiredTier = 'free' || requiredTier = 'basic')) || (@request.auth.subscriptionTier = 'premium' && requiredTier != 'pro') || @request.auth.subscriptionTier = 'pro')",
    "viewRule": "@request.auth.id != '' && (requiredTier = 'free' || (@request.auth.subscriptionTier = 'basic' && (requiredTier = 'free' || requiredTier = 'basic')) || (@request.auth.subscriptionTier = 'premium' && requiredTier != 'pro') || @request.auth.subscriptionTier = 'pro')",
    "createRule": null,
    "updateRule": null,
    "deleteRule": null
  });

  // Create watchlistItems collection
  const watchlistItems = new Collection({
    "id": "watchlistItems",
    "name": "watchlistItems",
    "type": "base", 
    "system": false,
    "schema": [
      {
        "id": "userId",
        "name": "userId",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "users",
          "cascadeDelete": true,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": ["email", "firstName", "lastName"]
        }
      },
      {
        "id": "symbol",
        "name": "symbol",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 20,
          "pattern": "^[A-Z0-9]+$"
        }
      },
      {
        "id": "companyName",
        "name": "companyName",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 255,
          "pattern": ""
        }
      },
      {
        "id": "type",
        "name": "type",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["stock", "crypto", "forex", "commodity"]
        }
      },
      {
        "id": "currentPrice",
        "name": "currentPrice",
        "type": "number",
        "required": true,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "priceChange",
        "name": "priceChange",
        "type": "number",
        "required": true,
        "options": {
          "min": null,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "priceChangePercent",
        "name": "priceChangePercent",
        "type": "number",
        "required": true,
        "options": {
          "min": null,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "addedAt",
        "name": "addedAt",
        "type": "date",
        "required": true,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "id": "isPriceAlertEnabled",
        "name": "isPriceAlertEnabled",
        "type": "bool",
        "required": false,
        "options": {}
      },
      {
        "id": "priceAlertTarget",
        "name": "priceAlertTarget",
        "type": "number",
        "required": false,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "notes",
        "name": "notes",
        "type": "text",
        "required": false,
        "options": {
          "min": 0,
          "max": 1000,
          "pattern": ""
        }
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_watchlist_user_symbol ON watchlistItems (userId, symbol)",
      "CREATE INDEX idx_watchlist_user ON watchlistItems (userId)",
      "CREATE INDEX idx_watchlist_symbol ON watchlistItems (symbol)",
      "CREATE INDEX idx_watchlist_type ON watchlistItems (type)",
      "CREATE INDEX idx_watchlist_added ON watchlistItems (addedAt)"
    ],
    "listRule": "@request.auth.id != '' && userId = @request.auth.id",
    "viewRule": "@request.auth.id != '' && userId = @request.auth.id",
    "createRule": "@request.auth.id != '' && userId = @request.auth.id",
    "updateRule": "@request.auth.id != '' && userId = @request.auth.id",
    "deleteRule": "@request.auth.id != '' && userId = @request.auth.id"
  });

  // Create all collections
  dao.createCollection(users);
  dao.createCollection(signals);
  dao.createCollection(watchlistItems);

  // Setup OAuth providers
  const settings = dao.findSettings();
  
  // Configure Google OAuth
  settings.googleAuth = {
    enabled: true,
    clientId: "",
    clientSecret: "",
    allowRegistrations: true
  };
  
  // Configure Apple OAuth
  settings.appleAuth = {
    enabled: true,
    clientId: "",
    teamId: "",
    keyId: "",
    privateKey: "",
    allowRegistrations: true
  };

  dao.saveSettings(settings);

}, (db) => {
  // Rollback - delete all collections
  dao.deleteCollection("watchlistItems");
  dao.deleteCollection("signals");
  dao.deleteCollection("users");
});