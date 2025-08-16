# PocketBase Backend for Pulse Trading Signals

A complete, production-ready PocketBase backend setup for the Pulse Flutter trading signals application.

## 🚀 Quick Start

```bash
# 1. Setup environment
cp .env.pocketbase .env
# Edit .env with your configuration

# 2. Start services
docker-compose up -d

# 3. Initialize admin (visit http://localhost:8090/_/)

# 4. Test integration
flutter test test/
```

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Development](#development)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This PocketBase setup provides a complete backend solution for the Pulse trading signals app, featuring real-time data synchronization, OAuth authentication, subscription management, and comprehensive admin tools.

### Key Benefits

✅ **Real-time synchronization** - WebSocket connections for live data  
✅ **OAuth integration** - Google and Apple Sign-In  
✅ **Subscription management** - Multi-tier access control  
✅ **Production-ready** - Docker deployment with monitoring  
✅ **Data migration** - Seamless transition from SQLite  
✅ **Admin dashboard** - Web-based management interface  

## ⭐ Features

### Authentication & Authorization
- OAuth 2.0 (Google, Apple)
- Email/password authentication
- JWT token management
- Role-based access control
- Subscription tier validation

### Data Management
- Real-time trading signals
- User watchlists with price alerts
- Market data integration
- File storage for charts/images
- Automatic data validation

### Admin Features
- Analytics dashboard
- User management
- Signal performance tracking
- System health monitoring
- Data export/import tools

### DevOps & Operations
- Docker containerization
- Automated backups
- Health monitoring
- Migration scripts
- Production deployment tools

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │◄──►│   PocketBase     │◄──►│   SQLite DB     │
│                 │    │                  │    │                 │
│ • Authentication│    │ • REST API       │    │ • Collections   │
│ • Real-time UI  │    │ • WebSocket      │    │ • Indexes       │
│ • State Mgmt    │    │ • File Storage   │    │ • Relations     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   Admin Panel    │
                       │                  │
                       │ • User Mgmt      │
                       │ • Analytics      │
                       │ • Monitoring     │
                       └──────────────────┘
```

### Technology Stack

- **Backend**: PocketBase (Go-based BaaS)
- **Database**: SQLite with real-time sync
- **Container**: Docker & Docker Compose
- **Proxy**: Traefik (production)
- **Storage**: Local filesystem + S3 (backups)
- **Monitoring**: Built-in health checks

## 🛠️ Installation

### Prerequisites

```bash
# Required
docker --version          # Docker 20.10+
docker-compose --version  # 1.29+

# Optional (for development)
flutter --version         # Flutter 3.8+
dart --version            # Dart 3.0+
```

### Setup Steps

1. **Clone & Configure**
   ```bash
   git clone <your-repo>
   cd pulse
   cp .env.pocketbase .env
   ```

2. **Environment Variables**
   ```bash
   # Required settings
   PB_ENCRYPTION_KEY=your-32-char-encryption-key
   POCKETBASE_URL=http://localhost:8090
   POCKETBASE_ADMIN_EMAIL=admin@pulse.app
   POCKETBASE_ADMIN_PASSWORD=your-secure-password
   
   # OAuth (optional for development)
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   ```

3. **Start Services**
   ```bash
   # Development
   docker-compose up -d
   
   # Or use deployment script
   ./scripts/deploy_pocketbase.sh --env development
   ```

4. **Initialize Database**
   ```bash
   # Auto-migration runs on first start
   # Check logs: docker-compose logs pocketbase
   ```

5. **Setup Admin**
   - Visit: http://localhost:8090/_/
   - Create admin account
   - Configure OAuth providers

## ⚙️ Configuration

### Environment Files

#### Development (.env)
```bash
# Basic setup for local development
PB_ENCRYPTION_KEY=dev-key-change-for-production
POCKETBASE_URL=http://localhost:8090
POCKETBASE_ADMIN_EMAIL=admin@pulse.app
POCKETBASE_ADMIN_PASSWORD=admin123
NODE_ENV=development
```

#### Production (.env.production)
```bash
# Secure production configuration
PB_ENCRYPTION_KEY=your-32-char-production-key
POCKETBASE_URL=https://api.yourdomain.com
POCKETBASE_ADMIN_EMAIL=admin@yourdomain.com
POCKETBASE_ADMIN_PASSWORD=super-secure-password

# SSL Configuration
SSL_CERT_PATH=/certs/cert.pem
SSL_KEY_PATH=/certs/key.pem

# OAuth Production
GOOGLE_CLIENT_ID=production-google-client-id
GOOGLE_CLIENT_SECRET=production-google-secret
APPLE_CLIENT_ID=production-apple-service-id

# Monitoring & Backup
BACKUP_SCHEDULE=0 2 * * *
S3_BUCKET=pulse-backups
LOG_LEVEL=info
```

### OAuth Setup

#### Google OAuth
1. [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials
3. Add redirect URI: `{POCKETBASE_URL}/api/oauth2-redirect`

#### Apple OAuth
1. [Apple Developer Console](https://developer.apple.com/)
2. Create Service ID with Sign In with Apple
3. Configure domains and redirect URLs

### Collection Rules

Access rules are automatically configured:

```javascript
// Signals - subscription tier based access
listRule: "@request.auth.id != '' && (requiredTier = 'free' || ...tier_logic)"

// Watchlist - user-owned data only
listRule: "@request.auth.id != '' && userId = @request.auth.id"

// Users - self-access only
listRule: "id = @request.auth.id"
```

## 📖 Usage

### Flutter Integration

1. **Add Dependency**
   ```yaml
   dependencies:
     pocketbase: ^0.18.2
   ```

2. **Initialize Service**
   ```dart
   import 'package:pocketbase/pocketbase.dart';
   
   final pb = PocketBase('http://localhost:8090');
   ```

3. **Authentication**
   ```dart
   // Email/Password
   await pb.collection('users').authWithPassword(email, password);
   
   // OAuth
   await pb.collection('users').authWithOAuth2('google');
   
   // Check auth status
   bool isAuthenticated = pb.authStore.isValid;
   ```

4. **Data Operations**
   ```dart
   // Get signals
   final signals = await pb.collection('signals').getList();
   
   // Add to watchlist
   await pb.collection('watchlistItems').create(body: {
     'userId': pb.authStore.model.id,
     'symbol': 'AAPL',
     'companyName': 'Apple Inc.',
     // ... other fields
   });
   
   // Real-time subscription
   pb.collection('signals').subscribe('*', (e) {
     print('Signal updated: ${e.record}');
   });
   ```

### API Examples

#### Authentication
```bash
# Login
curl -X POST "http://localhost:8090/api/collections/users/auth-with-password" \
  -H "Content-Type: application/json" \
  -d '{"identity":"user@example.com","password":"password"}'

# OAuth
curl -X POST "http://localhost:8090/api/collections/users/auth-with-oauth2" \
  -H "Content-Type: application/json" \
  -d '{"provider":"google","code":"oauth_code"}'
```

#### Data Access
```bash
# Get signals (requires authentication)
curl "http://localhost:8090/api/collections/signals/records" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Get user watchlist
curl "http://localhost:8090/api/collections/watchlistItems/records?filter=userId='USER_ID'" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 🔗 API Reference

### Base URL
- Development: `http://localhost:8090/api/`
- Production: `https://api.yourdomain.com/api/`

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/collections/users/auth-with-password` | Email/password login |
| POST | `/collections/users/auth-with-oauth2` | OAuth login |
| POST | `/collections/users/auth-refresh` | Refresh JWT token |
| POST | `/collections/users/request-password-reset` | Request password reset |

### Data Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/collections/signals/records` | List trading signals |
| GET | `/collections/signals/records/:id` | Get specific signal |
| GET | `/collections/watchlistItems/records` | Get user watchlist |
| POST | `/collections/watchlistItems/records` | Add to watchlist |
| PATCH | `/collections/watchlistItems/records/:id` | Update watchlist item |
| DELETE | `/collections/watchlistItems/records/:id` | Remove from watchlist |

### Admin Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/analytics/overview` | System analytics |
| GET | `/admin/analytics/user-growth` | User growth metrics |
| GET | `/admin/analytics/signal-performance` | Signal performance |
| GET | `/admin/system/health` | System health status |
| POST | `/admin/system/cleanup` | Clean expired data |

### WebSocket Subscriptions

```javascript
// Subscribe to signals
pb.collection('signals').subscribe('*', callback);

// Subscribe to user's watchlist
pb.collection('watchlistItems').subscribe('userId = "USER_ID"', callback);

// Subscribe with filters
pb.collection('signals').subscribe('type = "crypto"', callback);
```

## 🛠️ Development

### Project Structure

```
pulse/
├── pocketbase/
│   ├── hooks/           # Server-side JavaScript hooks
│   │   ├── auth.pb.js
│   │   ├── signals.pb.js
│   │   ├── watchlist.pb.js
│   │   └── admin.pb.js
│   ├── migrations/      # Database migrations
│   │   └── 1_initial_setup.js
│   └── schemas/         # Collection schemas
│       └── collections.json
├── scripts/
│   ├── deploy_pocketbase.sh
│   ├── pocketbase_backup.sh
│   ├── pocketbase_restore.sh
│   └── migrate_to_pocketbase.dart
├── lib/data/
│   ├── datasources/
│   │   └── pocketbase_service.dart
│   └── repositories/
│       ├── pocketbase_signal_repository.dart
│       ├── pocketbase_watchlist_repository.dart
│       └── pocketbase_user_repository.dart
├── docker-compose.yml
├── Dockerfile.pocketbase
└── .env.pocketbase
```

### Development Workflow

1. **Local Development**
   ```bash
   # Start development environment
   docker-compose up -d
   
   # Run Flutter app
   flutter run
   
   # Watch logs
   docker-compose logs -f pocketbase
   ```

2. **Database Changes**
   ```bash
   # Create migration
   # Edit pocketbase/migrations/new_migration.js
   
   # Restart to apply
   docker-compose restart pocketbase
   ```

3. **Testing**
   ```bash
   # Unit tests
   flutter test
   
   # Integration tests
   flutter test integration_test/
   
   # API tests
   dart test/api_test.dart
   ```

4. **Code Generation**
   ```bash
   # Generate Dart code
   flutter packages pub run build_runner build
   ```

### Debugging

```bash
# Container logs
docker-compose logs -f pocketbase

# Database access
docker exec -it pulse_pocketbase sh
sqlite3 /pb/pb_data/data.db

# Health check
curl http://localhost:8090/api/health

# Admin API test
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/system/health"
```

## 🚀 Deployment

### Development Deployment

```bash
./scripts/deploy_pocketbase.sh --env development
```

### Staging Deployment

```bash
# Setup staging environment
cp .env.pocketbase .env.staging
# Configure staging values

# Deploy
./scripts/deploy_pocketbase.sh --env staging --env-file .env.staging
```

### Production Deployment

```bash
# Prepare production environment
cp .env.pocketbase .env.production
# Configure production values with secure secrets

# Deploy with backup
./scripts/deploy_pocketbase.sh --env production --env-file .env.production

# Or dry run first
./scripts/deploy_pocketbase.sh --env production --dry-run
```

### Infrastructure Requirements

#### Minimum Requirements
- **CPU**: 1 core
- **RAM**: 2GB
- **Storage**: 10GB SSD
- **Network**: Stable internet connection

#### Recommended (Production)
- **CPU**: 2+ cores
- **RAM**: 4GB+
- **Storage**: 50GB SSD
- **Network**: 100Mbps+ low latency
- **SSL**: Valid certificate
- **Backup**: Automated with S3

### Monitoring

```bash
# System health
curl https://api.yourdomain.com/api/health

# Admin health check
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "https://api.yourdomain.com/api/admin/system/health"

# Container monitoring
docker stats pulse_pocketbase

# Backup verification
./scripts/pocketbase_backup.sh --verify
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Container Won't Start
```bash
# Check logs
docker-compose logs pocketbase

# Verify environment
cat .env | grep PB_ENCRYPTION_KEY

# Reset volumes
docker-compose down -v
docker-compose up -d
```

#### 2. Authentication Fails
```bash
# Check OAuth config
curl "http://localhost:8090/api/collections/users/auth-methods"

# Verify admin settings
# Visit http://localhost:8090/_/settings/auth-providers

# Check JWT token
echo "YOUR_TOKEN" | base64 -d
```

#### 3. Migration Issues
```bash
# Verify migration
dart scripts/migrate_to_pocketbase.dart --verify

# Check data counts
curl "http://localhost:8090/api/collections/users/records?perPage=1"

# Manual migration
dart scripts/migrate_to_pocketbase.dart --dry-run
```

#### 4. Performance Issues
```bash
# Monitor resources
docker stats

# Check query performance
# Use admin dashboard -> Logs

# Optimize database
sqlite3 /pb/pb_data/data.db "ANALYZE;"
```

### Debug Commands

```bash
# Container shell
docker exec -it pulse_pocketbase sh

# Database console
sqlite3 /pb/pb_data/data.db

# Configuration check
cat /pb/pb_data/settings.json

# Real-time logs
docker-compose logs -f --tail=50 pocketbase
```

### Emergency Recovery

```bash
# Restore from backup
./scripts/pocketbase_restore.sh --list-backups
./scripts/pocketbase_restore.sh latest_backup.tar.gz

# Export current data
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/export/users" > users_backup.json
```

## 📊 Monitoring & Analytics

### Built-in Analytics

Access via admin dashboard or API:

- User registration trends
- Signal performance metrics
- Subscription conversion rates
- System health status
- API usage statistics

### Custom Metrics

```bash
# User growth (last 30 days)
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/analytics/user-growth?days=30"

# Signal performance
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/analytics/signal-performance?days=30"

# System overview
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "http://localhost:8090/api/admin/analytics/overview"
```

### Health Monitoring

Set up monitoring with your preferred service:

```bash
# Health endpoint
GET https://api.yourdomain.com/api/health

# Expected response
{
  "code": 200,
  "message": "API is healthy.",
  "data": {}
}
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Development Guidelines

- Follow existing code style
- Add tests for new features
- Update documentation
- Ensure backward compatibility
- Test migration scripts

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Documentation**: [Complete Setup Guide](POCKETBASE_SETUP_GUIDE.md)
- **Issues**: Create GitHub issue with reproduction steps
- **Discussions**: Use GitHub discussions for questions
- **Email**: Contact your development team

## 🎉 Acknowledgments

- [PocketBase](https://pocketbase.io/) - Amazing BaaS platform
- [Flutter](https://flutter.dev/) - Cross-platform framework
- [Docker](https://docker.com/) - Containerization platform

---

**Made with ❤️ for Pulse Trading Signals**

Ready to revolutionize trading with AI-powered signals and real-time data!