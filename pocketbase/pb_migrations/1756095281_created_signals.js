/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    "id": "4mew0xfokvw68uv",
    "created": "2025-08-25 04:14:41.125Z",
    "updated": "2025-08-25 04:14:41.125Z",
    "name": "signals",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "emtn5niq",
        "name": "symbol",
        "type": "text",
        "required": true,
        "presentable": false,
        "unique": false,
        "options": {
          "min": 1,
          "max": 20,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "vz5bblna",
        "name": "companyName",
        "type": "text",
        "required": true,
        "presentable": false,
        "unique": false,
        "options": {
          "min": 1,
          "max": 255,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "lcoqnw8m",
        "name": "action",
        "type": "select",
        "required": true,
        "presentable": false,
        "unique": false,
        "options": {
          "maxSelect": 1,
          "values": [
            "buy",
            "sell",
            "hold"
          ]
        }
      },
      {
        "system": false,
        "id": "zvyc2jbt",
        "name": "currentPrice",
        "type": "number",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "min": 0,
          "max": null,
          "noDecimal": false
        }
      },
      {
        "system": false,
        "id": "bvksz0lp",
        "name": "reasoning",
        "type": "text",
        "required": true,
        "presentable": false,
        "unique": false,
        "options": {
          "min": 10,
          "max": 2000,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "3pbk3vf7",
        "name": "status",
        "type": "select",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "maxSelect": 1,
          "values": [
            "active",
            "completed",
            "cancelled",
            "expired"
          ]
        }
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("4mew0xfokvw68uv");

  return dao.deleteCollection(collection);
})
