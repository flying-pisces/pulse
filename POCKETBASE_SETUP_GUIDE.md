# PocketBase Setup Guide for Pulse Trading Signals App

This guide provides comprehensive instructions for setting up and managing PocketBase as the backend for your Flutter trading signals application.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Environment Configuration](#environment-configuration)
5. [Database Schema](#database-schema)
6. [Docker Deployment](#docker-deployment)
7. [Migration from SQLite](#migration-from-sqlite)
8. [Authentication Setup](#authentication-setup)
9. [API Integration](#api-integration)
10. [Administration](#administration)
11. [Backup & Restore](#backup--restore)
12. [Monitoring & Maintenance](#monitoring--maintenance)
13. [Production Deployment](#production-deployment)
14. [Troubleshooting](#troubleshooting)

## Overview

PocketBase serves as the backend for the Pulse trading signals app, providing:

- **Authentication**: OAuth (Google/Apple) and email/password
- **Database**: Real-time collections for users, signals, and watchlists
- **API**: RESTful endpoints with real-time subscriptions
- **Admin Dashboard**: Web-based management interface
- **File Storage**: Support for user profile images and signal charts

### Architecture

```
Flutter App ←→ PocketBase API ←→ SQLite Database
     ↑              ↑                    ↑
   Mobile      REST/WebSocket        Local Storage
   Client        Real-time            + File Storage
```

## Prerequisites

Before setting up PocketBase, ensure you have:

- Docker & Docker Compose installed
- Node.js 16+ (for development tools)
- Flutter SDK 3.8+ (for mobile app)
- Git (for version control)

### System Requirements

- **Memory**: 2GB RAM minimum, 4GB recommended
- **Storage**: 10GB free space minimum
- **Network**: Stable internet connection for OAuth setup

## Quick Start

### 1. Clone and Setup

```bash
cd /path/to/pulse
cp .env.pocketbase .env
```

### 2. Configure Environment

Edit `.env` file:

```bash
# Required settings
PB_ENCRYPTION_KEY=your-32-character-encryption-key-here
POCKETBASE_URL=http://localhost:8090
POCKETBASE_ADMIN_EMAIL=admin@pulse.app
POCKETBASE_ADMIN_PASSWORD=your-secure-password

# OAuth settings (get from Google/Apple Developer Console)
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
APPLE_CLIENT_ID=your-apple-service-id
```

### 3. Start Services

```bash
# Development environment
docker-compose up -d

# Or use the deployment script
./scripts/deploy_pocketbase.sh --env development
```

### 4. Initialize Admin

Visit `http://localhost:8090/_/` and create your admin account.

### 5. Verify Setup

```bash
# Check health
curl http://localhost:8090/api/health

# Check collections
curl http://localhost:8090/api/collections
```

## Environment Configuration

### Development (.env)

```bash
# PocketBase Configuration
PB_ENCRYPTION_KEY=dev-key-change-for-production-use
POCKETBASE_URL=http://localhost:8090
POCKETBASE_ADMIN_EMAIL=admin@pulse.app
POCKETBASE_ADMIN_PASSWORD=admin123

# Database
PB_DATA_DIR=./pb_data

# OAuth (optional for development)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
APPLE_CLIENT_ID=
```

### Production (.env.production)

```bash
# PocketBase Configuration
PB_ENCRYPTION_KEY=your-32-char-production-encryption-key
POCKETBASE_URL=https://api.yourdomain.com
POCKETBASE_ADMIN_EMAIL=admin@yourdomain.com
POCKETBASE_ADMIN_PASSWORD=super-secure-password-here

# SSL Configuration
SSL_CERT_PATH=/path/to/cert.pem
SSL_KEY_PATH=/path/to/key.pem

# OAuth Configuration
GOOGLE_CLIENT_ID=your-production-google-client-id
GOOGLE_CLIENT_SECRET=your-production-google-client-secret
APPLE_CLIENT_ID=your-production-apple-service-id
APPLE_TEAM_ID=your-apple-team-id
APPLE_KEY_ID=your-apple-key-id

# Monitoring
LOG_LEVEL=info
HEALTH_CHECK_INTERVAL=30s

# Backup
BACKUP_SCHEDULE=0 2 * * *
BACKUP_RETENTION_DAYS=30
S3_BUCKET=your-backup-bucket
S3_REGION=us-east-1
```

## Database Schema

### Collections Overview

1. **users** (auth collection)
   - User authentication and profiles
   - Subscription management
   - OAuth provider data

2. **signals** (base collection)
   - Trading signals with AI analysis
   - Price targets and stop losses
   - Subscription tier access control

3. **watchlistItems** (base collection)
   - User watchlists
   - Price alerts
   - Real-time price tracking

### Field Definitions

#### Users Collection

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | email | Yes | User email (unique) |
| firstName | text | Yes | User first name |
| lastName | text | Yes | User last name |
| profileImageUrl | url | No | Profile image URL |
| isVerified | bool | No | Email verification status |
| subscriptionTier | select | Yes | free/basic/premium/pro |
| subscriptionExpiresAt | date | No | Subscription expiry |
| authProvider | select | Yes | email/google/apple |
| providerId | text | No | OAuth provider ID |
| providerData | json | No | OAuth provider data |

#### Signals Collection

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| symbol | text | Yes | Stock/crypto symbol |
| companyName | text | Yes | Company/asset name |
| type | select | Yes | stock/crypto/forex/commodity |
| action | select | Yes | buy/sell/hold |
| currentPrice | number | Yes | Current market price |
| targetPrice | number | Yes | Price target |
| stopLoss | number | Yes | Stop loss level |
| confidence | number | Yes | AI confidence (0-1) |
| reasoning | text | Yes | AI analysis text |
| expiresAt | date | No | Signal expiry date |
| status | select | Yes | active/completed/cancelled/expired |
| tags | json | No | Signal tags array |
| requiredTier | select | Yes | Required subscription tier |
| profitLossPercentage | number | No | P&L when completed |
| imageUrl | url | No | Chart image URL |

#### WatchlistItems Collection

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | relation | Yes | Reference to users |
| symbol | text | Yes | Stock/crypto symbol |
| companyName | text | Yes | Company/asset name |
| type | select | Yes | stock/crypto/forex/commodity |
| currentPrice | number | Yes | Current market price |
| priceChange | number | Yes | Price change ($) |
| priceChangePercent | number | Yes | Price change (%) |
| addedAt | date | Yes | When added to watchlist |
| isPriceAlertEnabled | bool | No | Price alert enabled |
| priceAlertTarget | number | No | Price alert target |
| notes | text | No | User notes |

## Docker Deployment

### docker-compose.yml Structure

```yaml
services:
  pocketbase:
    image: ghcr.io/muchobien/pocketbase:latest
    container_name: pulse_pocketbase
    ports:
      - "8090:8090"
    volumes:
      - pb_data:/pb/pb_data
      - ./pocketbase/migrations:/pb/pb_migrations:ro
      - ./pocketbase/hooks:/pb/pb_hooks:ro
    environment:
      - PB_ENCRYPTION_KEY=${PB_ENCRYPTION_KEY}
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:8090/api/health"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: pulse_redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  pb_data:
  redis_data:
```

### Deployment Commands

```bash
# Development
./scripts/deploy_pocketbase.sh --env development

# Staging
./scripts/deploy_pocketbase.sh --env staging --force

# Production (with backup)
./scripts/deploy_pocketbase.sh --env production

# Dry run
./scripts/deploy_pocketbase.sh --env production --dry-run
```

## Migration from SQLite

### 1. Prepare Migration

```bash
# Generate migration report
dart scripts/migrate_to_pocketbase.dart --report > migration_report.json

# Dry run migration
dart scripts/migrate_to_pocketbase.dart --dry-run --db-path /path/to/pulse.sqlite
```

### 2. Run Migration

```bash
# Full migration
dart scripts/migrate_to_pocketbase.dart --db-path /path/to/pulse.sqlite

# Selective migration
dart scripts/migrate_to_pocketbase.dart --skip-users --db-path /path/to/pulse.sqlite
```

### 3. Verify Migration

```bash
# Verify data counts
dart scripts/migrate_to_pocketbase.dart --verify

# Manual verification via API
curl "http://localhost:8090/api/collections/users/records" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## Authentication Setup

### OAuth Configuration

#### Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/select project
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs:
   - `http://localhost:8090/api/oauth2-redirect`
   - `https://yourdomain.com/api/oauth2-redirect`

#### Apple OAuth Setup

1. Go to [Apple Developer Console](https://developer.apple.com/)
2. Create App ID with Sign In with Apple
3. Create Service ID
4. Generate private key
5. Configure domains and redirect URLs

### PocketBase OAuth Configuration

```javascript
// In PocketBase admin dashboard
settings.googleAuth = {
  enabled: true,
  clientId: "your-google-client-id",
  clientSecret: "your-google-client-secret",
  allowRegistrations: true
};

settings.appleAuth = {
  enabled: true,
  clientId: "your-apple-service-id",
  teamId: "your-apple-team-id",
  keyId: "your-apple-key-id",
  privateKey: "-----BEGIN PRIVATE KEY-----...",
  allowRegistrations: true
};
```

## API Integration

### Flutter Integration

Add to `pubspec.yaml`:

```yaml
dependencies:
  pocketbase: ^0.18.2
```

### Initialize PocketBase Service

```dart
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://localhost:8090');

// Authentication
await pb.collection('users').authWithPassword(email, password);

// OAuth
await pb.collection('users').authWithOAuth2('google');

// CRUD operations
final signals = await pb.collection('signals').getList();
```

### Real-time Subscriptions

```dart
// Subscribe to signals
pb.collection('signals').subscribe('*', (e) {
  print('Signal updated: ${e.record}');
});

// Subscribe to user's watchlist
pb.collection('watchlistItems').subscribe('userId = "user123"', (e) {
  print('Watchlist updated: ${e.record}');
});
```

### API Endpoints

#### Authentication
- `POST /api/collections/users/auth-with-password`
- `POST /api/collections/users/auth-with-oauth2`
- `POST /api/collections/users/auth-refresh`

#### Signals
- `GET /api/collections/signals/records` - List signals
- `GET /api/collections/signals/records/:id` - Get signal
- Real-time: Subscribe to collection

#### Watchlist
- `GET /api/collections/watchlistItems/records` - Get watchlist
- `POST /api/collections/watchlistItems/records` - Add to watchlist
- `DELETE /api/collections/watchlistItems/records/:id` - Remove item

## Administration

### Admin Dashboard

Access: `http://localhost:8090/_/`

#### Features

1. **Collections Management**
   - View/edit records
   - Manage schema
   - Set access rules

2. **User Management**
   - User profiles
   - Subscription tiers
   - Authentication providers

3. **System Monitoring**
   - Request logs
   - Performance metrics
   - Error tracking

4. **Settings**
   - OAuth configuration
   - Email settings
   - Security settings

### Custom Admin APIs

```bash
# Analytics overview
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/analytics/overview"

# User growth
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/analytics/user-growth?days=30"

# Signal performance
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/analytics/signal-performance?days=30"

# System health
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/system/health"

# Cleanup expired data
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/system/cleanup"
```

## Backup & Restore

### Automated Backups

```bash
# Setup cron job for daily backups
0 2 * * * /path/to/pulse/scripts/pocketbase_backup.sh --s3-bucket your-backup-bucket

# Manual backup
./scripts/pocketbase_backup.sh --retention-days 30
```

### Backup Options

```bash
# Local backup only
./scripts/pocketbase_backup.sh

# Backup to S3
./scripts/pocketbase_backup.sh --s3-bucket your-backup-bucket

# No compression
./scripts/pocketbase_backup.sh --no-compress

# Skip verification
./scripts/pocketbase_backup.sh --no-verify
```

### Restore Process

```bash
# List available backups
./scripts/pocketbase_restore.sh --list-backups

# Restore from local backup
./scripts/pocketbase_restore.sh backup_20231201_120000.tar.gz

# Restore from S3
./scripts/pocketbase_restore.sh --from-s3 your-bucket backup_name

# Force restore without confirmation
./scripts/pocketbase_restore.sh --force backup.tar.gz
```

## Monitoring & Maintenance

### Health Monitoring

```bash
# Check service health
curl http://localhost:8090/api/health

# Check detailed system status
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/system/health"
```

### Log Management

```bash
# View container logs
docker-compose logs -f pocketbase

# View application logs
docker exec pulse_pocketbase tail -f /pb/pb_data/logs/data.log
```

### Performance Monitoring

1. **Database Performance**
   - Monitor query execution times
   - Check index usage
   - Review slow queries

2. **Memory Usage**
   - Container memory consumption
   - Database cache efficiency
   - File storage growth

3. **API Performance**
   - Response times
   - Error rates
   - Concurrent connections

### Maintenance Tasks

```bash
# Clean up expired signals
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/signals/expire-old"

# Update watchlist prices
curl -X POST -H "Authorization: Bearer USER_TOKEN" \
  "http://localhost:8090/api/watchlist/update-prices" \
  -d '{"updates": [...]}'

# System cleanup
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/system/cleanup"
```

## Production Deployment

### Infrastructure Requirements

#### Server Specifications
- **CPU**: 2+ cores
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 50GB SSD minimum
- **Network**: 100Mbps+ with low latency

#### Security Considerations

1. **SSL/TLS**
   - Use valid SSL certificates
   - Configure HTTPS redirects
   - Implement HSTS headers

2. **Network Security**
   - Firewall configuration
   - VPN access for admin
   - DDoS protection

3. **Data Security**
   - Encrypt database at rest
   - Secure backup storage
   - Regular security audits

### Production Deployment Steps

1. **Prepare Environment**
   ```bash
   # Clone repository
   git clone https://github.com/your-repo/pulse.git
   cd pulse
   
   # Configure production environment
   cp .env.pocketbase .env.production
   # Edit .env.production with production values
   ```

2. **Deploy Services**
   ```bash
   # Deploy to production
   ./scripts/deploy_pocketbase.sh --env production --env-file .env.production
   ```

3. **Configure SSL**
   ```bash
   # Using Traefik (included in docker-compose)
   docker-compose --profile production up -d
   ```

4. **Setup Monitoring**
   ```bash
   # Configure log aggregation
   # Setup health check monitoring
   # Configure alerting
   ```

### Domain Configuration

1. **DNS Settings**
   - A record: `api.yourdomain.com` → Server IP
   - CNAME: `pocketbase.yourdomain.com` → `api.yourdomain.com`

2. **SSL Certificate**
   ```bash
   # Using Let's Encrypt with Traefik
   # Certificates are automatically obtained and renewed
   ```

3. **Environment Variables**
   ```bash
   POCKETBASE_URL=https://api.yourdomain.com
   CORS_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
   ```

### High Availability Setup

1. **Load Balancing**
   - Multiple PocketBase instances
   - Shared file storage (S3/NFS)
   - Database replication

2. **Backup Strategy**
   - Automated daily backups
   - Cross-region backup storage
   - Regular restore testing

3. **Monitoring & Alerting**
   - Uptime monitoring
   - Performance metrics
   - Error rate alerts

## Troubleshooting

### Common Issues

#### 1. PocketBase Won't Start

**Symptoms**: Container exits immediately
**Solutions**:
```bash
# Check logs
docker-compose logs pocketbase

# Verify environment variables
cat .env

# Check permissions
ls -la pocketbase/

# Reset data volume
docker-compose down -v
docker-compose up -d
```

#### 2. Authentication Errors

**Symptoms**: OAuth login fails, JWT errors
**Solutions**:
```bash
# Check OAuth configuration
curl "http://localhost:8090/api/collections/users/auth-methods"

# Verify environment variables
echo $GOOGLE_CLIENT_ID
echo $APPLE_CLIENT_ID

# Check admin settings
# Visit http://localhost:8090/_/settings/auth-providers
```

#### 3. Database Migration Issues

**Symptoms**: Data not migrated, count mismatches
**Solutions**:
```bash
# Run verification
dart scripts/migrate_to_pocketbase.dart --verify

# Check migration logs
docker-compose logs pocketbase | grep migration

# Manual data check
curl "http://localhost:8090/api/collections/users/records?perPage=1"
```

#### 4. Performance Issues

**Symptoms**: Slow API responses, timeouts
**Solutions**:
```bash
# Check container resources
docker stats pulse_pocketbase

# Monitor database performance
# Check query execution in admin dashboard

# Optimize indexes
# Review collection access rules

# Scale resources
# Increase container memory/CPU limits
```

#### 5. Connection Issues

**Symptoms**: Can't connect to API, CORS errors
**Solutions**:
```bash
# Check service status
docker-compose ps

# Test connectivity
curl http://localhost:8090/api/health

# Check CORS settings
# Verify CORS_ORIGINS environment variable

# Check firewall/network
netstat -tlnp | grep 8090
```

### Debug Commands

```bash
# Container shell access
docker exec -it pulse_pocketbase sh

# Database direct access
sqlite3 /pb/pb_data/data.db

# View configuration
cat /pb/pb_data/settings.json

# Check disk usage
df -h

# Monitor real-time logs
docker-compose logs -f --tail=100 pocketbase
```

### Support Resources

1. **PocketBase Documentation**: https://pocketbase.io/docs/
2. **Discord Community**: https://discord.gg/pocketbase
3. **GitHub Issues**: https://github.com/pocketbase/pocketbase/issues
4. **Project Repository**: Your project repository for app-specific issues

### Emergency Procedures

#### Service Recovery

1. **Immediate Steps**
   ```bash
   # Stop services
   docker-compose down
   
   # Check system resources
   df -h
   free -h
   
   # Restart services
   docker-compose up -d
   ```

2. **Restore from Backup**
   ```bash
   # List recent backups
   ./scripts/pocketbase_restore.sh --list-backups
   
   # Restore latest backup
   ./scripts/pocketbase_restore.sh latest_backup.tar.gz
   ```

3. **Data Recovery**
   ```bash
   # Export current data
   curl -H "Authorization: Bearer ADMIN_TOKEN" \
     "http://localhost:8090/api/admin/export/users" > users_backup.json
   
   # Manual database repair if needed
   sqlite3 /pb/pb_data/data.db ".integrity_check"
   ```

---

## Quick Reference

### Essential Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f pocketbase

# Backup
./scripts/pocketbase_backup.sh

# Deploy
./scripts/deploy_pocketbase.sh --env production

# Migration
dart scripts/migrate_to_pocketbase.dart --verify
```

### Important URLs

- **Admin Dashboard**: http://localhost:8090/_/
- **API Base**: http://localhost:8090/api/
- **Health Check**: http://localhost:8090/api/health
- **Collections**: http://localhost:8090/api/collections

### Default Ports

- **PocketBase**: 8090
- **Redis**: 6379
- **Traefik Dashboard**: 8080

This guide provides everything needed to successfully deploy and manage PocketBase for your Pulse trading signals application. For additional support, refer to the troubleshooting section or contact your development team.