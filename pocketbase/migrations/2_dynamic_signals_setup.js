/// <reference path="../pb_data/types.d.ts" />

/**
 * Dynamic signals migration for Pulse trading signals app
 * Adds collections for dynamic signal upgrades and payment processing
 */
migrate((db) => {
  
  // Create signal_upgrades collection for tracking dynamic signal purchases
  const signalUpgrades = new Collection({
    "id": "signalUpgrades",
    "name": "signalUpgrades",
    "type": "base",
    "system": false,
    "schema": [
      {
        "id": "signalId",
        "name": "signalId",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "signals",
          "cascadeDelete": true,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": ["symbol", "companyName"]
        }
      },
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
        "id": "paymentIntentId",
        "name": "paymentIntentId",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 255,
          "pattern": ""
        }
      },
      {
        "id": "amount",
        "name": "amount",
        "type": "number",
        "required": true,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "currency",
        "name": "currency",
        "type": "text",
        "required": true,
        "options": {
          "min": 3,
          "max": 3,
          "pattern": "^[A-Z]{3}$"
        }
      },
      {
        "id": "status",
        "name": "status",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["pending", "confirmed", "failed", "refunded"]
        }
      },
      {
        "id": "durationHours",
        "name": "durationHours",
        "type": "number",
        "required": true,
        "options": {
          "min": 1,
          "max": 168, // Max 7 days
          "noDecimal": true
        }
      },
      {
        "id": "expiresAt",
        "name": "expiresAt",
        "type": "date",
        "required": true,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "id": "confirmedAt",
        "name": "confirmedAt",
        "type": "date",
        "required": false,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "id": "refundedAt",
        "name": "refundedAt",
        "type": "date",
        "required": false,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "id": "metadata",
        "name": "metadata",
        "type": "json",
        "required": false,
        "options": {}
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_signal_upgrades_payment ON signalUpgrades (paymentIntentId)",
      "CREATE INDEX idx_signal_upgrades_signal ON signalUpgrades (signalId)",
      "CREATE INDEX idx_signal_upgrades_user ON signalUpgrades (userId)",
      "CREATE INDEX idx_signal_upgrades_status ON signalUpgrades (status)",
      "CREATE INDEX idx_signal_upgrades_expires ON signalUpgrades (expiresAt)",
      "CREATE INDEX idx_signal_upgrades_created ON signalUpgrades (created)"
    ],
    "listRule": "@request.auth.id != '' && userId = @request.auth.id",
    "viewRule": "@request.auth.id != '' && userId = @request.auth.id",
    "createRule": null, // Only backend can create
    "updateRule": null, // Only backend can update
    "deleteRule": null  // Only admin can delete
  });

  // Create signal_updates collection for tracking dynamic signal real-time updates
  const signalUpdates = new Collection({
    "id": "signalUpdates",
    "name": "signalUpdates",
    "type": "base",
    "system": false,
    "schema": [
      {
        "id": "signalId",
        "name": "signalId",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "signals",
          "cascadeDelete": true,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": ["symbol", "companyName"]
        }
      },
      {
        "id": "upgradeId",
        "name": "upgradeId",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "signalUpgrades",
          "cascadeDelete": true,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": []
        }
      },
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
          "displayFields": ["email"]
        }
      },
      {
        "id": "updateType",
        "name": "updateType",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["price_update", "news_alert", "ai_analysis", "risk_alert", "target_approaching", "stop_loss_alert", "volume_spike", "breaking_news"]
        }
      },
      {
        "id": "title",
        "name": "title",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 200,
          "pattern": ""
        }
      },
      {
        "id": "content",
        "name": "content",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 2000,
          "pattern": ""
        }
      },
      {
        "id": "priority",
        "name": "priority",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["low", "medium", "high", "critical"]
        }
      },
      {
        "id": "data",
        "name": "data",
        "type": "json",
        "required": false,
        "options": {}
      },
      {
        "id": "isRead",
        "name": "isRead",
        "type": "bool",
        "required": false,
        "options": {}
      },
      {
        "id": "readAt",
        "name": "readAt",
        "type": "date",
        "required": false,
        "options": {
          "min": "",
          "max": ""
        }
      }
    ],
    "indexes": [
      "CREATE INDEX idx_signal_updates_signal ON signalUpdates (signalId)",
      "CREATE INDEX idx_signal_updates_upgrade ON signalUpdates (upgradeId)",
      "CREATE INDEX idx_signal_updates_user ON signalUpdates (userId)",
      "CREATE INDEX idx_signal_updates_type ON signalUpdates (updateType)",
      "CREATE INDEX idx_signal_updates_priority ON signalUpdates (priority)",
      "CREATE INDEX idx_signal_updates_read ON signalUpdates (isRead)",
      "CREATE INDEX idx_signal_updates_created ON signalUpdates (created)"
    ],
    "listRule": "@request.auth.id != '' && userId = @request.auth.id",
    "viewRule": "@request.auth.id != '' && userId = @request.auth.id",
    "createRule": null, // Only backend can create
    "updateRule": "@request.auth.id != '' && userId = @request.auth.id && @request.data.isRead:isset && @request.data.readAt:isset", // Only allow marking as read
    "deleteRule": null
  });

  // Create user_notifications collection for general app notifications
  const userNotifications = new Collection({
    "id": "userNotifications",
    "name": "userNotifications",
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
          "displayFields": ["email"]
        }
      },
      {
        "id": "type",
        "name": "type",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["welcome", "subscription_updated", "subscription_expired", "signal_created", "signal_expired", "payment_success", "payment_failed", "account_update", "system_alert"]
        }
      },
      {
        "id": "title",
        "name": "title",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 200,
          "pattern": ""
        }
      },
      {
        "id": "message",
        "name": "message",
        "type": "text",
        "required": true,
        "options": {
          "min": 1,
          "max": 1000,
          "pattern": ""
        }
      },
      {
        "id": "priority",
        "name": "priority",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": ["low", "medium", "high", "critical"]
        }
      },
      {
        "id": "actionType",
        "name": "actionType",
        "type": "select",
        "required": false,
        "options": {
          "maxSelect": 1,
          "values": ["none", "open_url", "navigate_to_screen", "upgrade_subscription", "view_signal"]
        }
      },
      {
        "id": "actionData",
        "name": "actionData",
        "type": "json",
        "required": false,
        "options": {}
      },
      {
        "id": "isRead",
        "name": "isRead",
        "type": "bool",
        "required": false,
        "options": {}
      },
      {
        "id": "readAt",
        "name": "readAt",
        "type": "date",
        "required": false,
        "options": {
          "min": "",
          "max": ""
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
      }
    ],
    "indexes": [
      "CREATE INDEX idx_user_notifications_user ON userNotifications (userId)",
      "CREATE INDEX idx_user_notifications_type ON userNotifications (type)",
      "CREATE INDEX idx_user_notifications_priority ON userNotifications (priority)",
      "CREATE INDEX idx_user_notifications_read ON userNotifications (isRead)",
      "CREATE INDEX idx_user_notifications_created ON userNotifications (created)",
      "CREATE INDEX idx_user_notifications_expires ON userNotifications (expiresAt)"
    ],
    "listRule": "@request.auth.id != '' && userId = @request.auth.id",
    "viewRule": "@request.auth.id != '' && userId = @request.auth.id",
    "createRule": null, // Only backend can create
    "updateRule": "@request.auth.id != '' && userId = @request.auth.id && @request.data.isRead:isset && @request.data.readAt:isset",
    "deleteRule": "@request.auth.id != '' && userId = @request.auth.id"
  });

  // Add dynamic signal fields to existing signals collection
  dao.updateCollection(dao.findCollectionByNameOrId("signals"), {
    "schema": [
      // ... existing fields remain the same ...
      // Add new fields for dynamic signals
      {
        "id": "isDynamic",
        "name": "isDynamic",
        "type": "bool",
        "required": false,
        "options": {}
      },
      {
        "id": "dynamicUserId",
        "name": "dynamicUserId",
        "type": "relation",
        "required": false,
        "options": {
          "collectionId": "users",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": ["email"]
        }
      },
      {
        "id": "dynamicExpiresAt",
        "name": "dynamicExpiresAt",
        "type": "date",
        "required": false,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "id": "lastPriceUpdate",
        "name": "lastPriceUpdate",
        "type": "date",
        "required": false,
        "options": {
          "min": "",
          "max": ""
        }
      },
      {
        "id": "realTimePrice",
        "name": "realTimePrice",
        "type": "number",
        "required": false,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "priceChangeToday",
        "name": "priceChangeToday",
        "type": "number",
        "required": false,
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
        "required": false,
        "options": {
          "min": null,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "id": "volumeToday",
        "name": "volumeToday",
        "type": "number",
        "required": false,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": true
        }
      },
      {
        "id": "aiAnalysis",
        "name": "aiAnalysis",
        "type": "json",
        "required": false,
        "options": {}
      },
      {
        "id": "newsUpdates",
        "name": "newsUpdates",
        "type": "json",
        "required": false,
        "options": {}
      }
    ]
  });

  // Create all new collections
  dao.createCollection(signalUpgrades);
  dao.createCollection(signalUpdates);
  dao.createCollection(userNotifications);

}, (db) => {
  // Rollback - delete new collections
  dao.deleteCollection("userNotifications");
  dao.deleteCollection("signalUpdates");
  dao.deleteCollection("signalUpgrades");
  
  // Note: We don't rollback signal collection changes to avoid data loss
  // In production, you'd want a more sophisticated migration rollback
});