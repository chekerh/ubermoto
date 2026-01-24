# 🚀 UberMoto Deployment Guide

Complete guide for deploying UberMoto to production environments.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Backend Deployment](#backend-deployment)
4. [Frontend Deployment](#frontend-deployment)
5. [Database Setup](#database-setup)
6. [Monitoring Setup](#monitoring-setup)
7. [Security Configuration](#security-configuration)
8. [Performance Optimization](#performance-optimization)
9. [Backup and Recovery](#backup-and-recovery)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- **Node.js**: 18.0 or higher
- **MongoDB**: 5.0 or higher
- **Flutter**: 3.19.0 or higher (for mobile builds)
- **Docker**: 20.10 or higher (optional)

### Cloud Platforms
- **Backend**: Heroku, AWS EC2/EB, Google Cloud Run, DigitalOcean
- **Frontend**: Firebase Hosting, Vercel, Netlify
- **Database**: MongoDB Atlas, AWS DocumentDB
- **File Storage**: AWS S3, Cloudinary, Firebase Storage

### Domain and SSL
- Custom domain name
- SSL certificate (Let's Encrypt or purchased)
- DNS configuration

## Environment Setup

### Backend Environment Variables

Create `.env` file in backend directory:

```bash
# Database
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ubermoto_prod?retryWrites=true&w=majority

# Authentication
JWT_SECRET=your_super_secure_jwt_secret_here_minimum_32_characters
JWT_EXPIRES_IN=24h
BCRYPT_ROUNDS=12

# Server
PORT=3001
NODE_ENV=production

# External APIs
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id

# Email (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# File Upload (optional)
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# Redis (optional, for WebSocket scaling)
REDIS_URL=redis://username:password@host:port
```

### Frontend Environment Variables

For web deployment:
```javascript
// web/index.html or Firebase functions config
window.UBERMOTO_CONFIG = {
  API_BASE_URL: 'https://api.ubermoto.com',
  GOOGLE_MAPS_API_KEY: 'your-maps-api-key',
  SENTRY_DSN: 'your-sentry-dsn',
  ANALYTICS_ID: 'GA-XXXXXXXXXX',
  FIREBASE_CONFIG: {
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef123456"
  }
};
```

For mobile builds:
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.ubermoto.com \
  --dart-define=GOOGLE_MAPS_API_KEY=your-maps-api-key \
  --dart-define=SENTRY_DSN=your-sentry-dsn \
  --dart-define=ANALYTICS_MEASUREMENT_ID=GA-XXXXXXXXXX
```

## Backend Deployment

### Option 1: Heroku Deployment

1. **Create Heroku App**
```bash
heroku create your-ubermoto-api
```

2. **Set Environment Variables**
```bash
heroku config:set MONGODB_URI="your_mongodb_uri"
heroku config:set JWT_SECRET="your_jwt_secret"
heroku config:set GOOGLE_MAPS_API_KEY="your_maps_key"
heroku config:set SENTRY_DSN="your_sentry_dsn"
```

3. **Deploy**
```bash
git push heroku main
```

4. **Scale Dynos** (if needed)
```bash
heroku ps:scale web=1
```

### Option 2: AWS EC2 Deployment

1. **Launch EC2 Instance**
```bash
# t3.medium or larger recommended
# Ubuntu 22.04 LTS
# Configure security groups (ports: 22, 80, 443, 3001)
```

2. **Install Dependencies**
```bash
sudo apt update
sudo apt install -y nodejs npm nginx certbot
sudo npm install -g pm2 @nestjs/cli
```

3. **Clone and Setup**
```bash
git clone https://github.com/yourusername/ubermoto.git
cd ubermoto/backend
npm install
cp .env.example .env
# Edit .env with production values
```

4. **Build and Start**
```bash
npm run build
pm2 start dist/main.js --name ubermoto-api
pm2 startup
pm2 save
```

5. **Configure Nginx**
```nginx
# /etc/nginx/sites-available/ubermoto
server {
    listen 80;
    server_name api.ubermoto.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

6. **SSL Certificate**
```bash
sudo certbot --nginx -d api.ubermoto.com
```

### Option 3: Docker Deployment

1. **Create Dockerfile**
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

RUN npm run build

EXPOSE 3001

CMD ["npm", "run", "start:prod"]
```

2. **Build and Run**
```bash
docker build -t ubermoto-api .
docker run -d \
  --name ubermoto-api \
  -p 3001:3001 \
  -e MONGODB_URI="your_uri" \
  -e JWT_SECRET="your_secret" \
  --restart unless-stopped \
  ubermoto-api
```

## Frontend Deployment

### Web Deployment (Firebase)

1. **Install Firebase CLI**
```bash
npm install -g firebase-tools
firebase login
```

2. **Initialize Firebase**
```bash
cd frontend
firebase init hosting
# Select existing project or create new
# Public directory: build/web
# Single-page app: Yes
```

3. **Build and Deploy**
```bash
flutter build web --release
firebase deploy --only hosting
```

4. **Custom Domain** (Optional)
```bash
firebase hosting:channel:deploy preview
# Or configure custom domain in Firebase Console
```

### Mobile Deployment

#### Android (Google Play Store)

1. **Build Signed APK/AAB**
```bash
# Create keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build AAB (recommended)
flutter build appbundle --release

# Or build APK
flutter build apk --release
```

2. **Google Play Console Setup**
   - Create app in Play Console
   - Upload AAB file
   - Fill store listing (description, screenshots, etc.)
   - Set pricing and distribution
   - Submit for review

#### iOS (App Store)

1. **Xcode Setup**
```bash
# Open iOS project
open ios/Runner.xcworkspace

# Configure signing certificates
# Product > Destination > Generic iOS Device
```

2. **Build for App Store**
```bash
flutter build ios --release --no-codesign
```

3. **Archive and Upload**
   - In Xcode: Product > Archive
   - Upload to App Store Connect
   - Fill app information and screenshots
   - Submit for review

## Database Setup

### MongoDB Atlas (Recommended)

1. **Create Cluster**
   - Go to MongoDB Atlas
   - Create new cluster (M0 for free tier)
   - Configure network access (IP whitelist)

2. **Create Database User**
   - Database Access > Add New User
   - Set username/password
   - Grant read/write access

3. **Get Connection String**
   ```
   mongodb+srv://username:password@cluster.mongodb.net/ubermoto_prod?retryWrites=true&w=majority
   ```

4. **Database Indexes** (Important for performance)
```javascript
// Create indexes in MongoDB shell or application
db.deliveries.createIndex({ userId: 1, status: 1 });
db.deliveries.createIndex({ driverId: 1, status: 1 });
db.deliveries.createIndex({ createdAt: -1 });
db.drivers.createIndex({ isAvailable: 1, userId: 1 });
db.users.createIndex({ email: 1 }, { unique: true });
```

### Local MongoDB Setup

```bash
# Install MongoDB
sudo apt install mongodb

# Start service
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Create database and user
mongosh
use ubermoto_prod
db.createUser({
  user: "ubermoto",
  pwd: "secure_password",
  roles: ["readWrite"]
})
```

## Monitoring Setup

### Sentry (Error Tracking)

1. **Create Projects**
   - Backend: Node.js project
   - Frontend: Flutter project

2. **Install SDKs**
```bash
# Backend
npm install @sentry/node @sentry/profiling-node

# Frontend
flutter pub add sentry_flutter
```

3. **Configure**
```typescript
// backend/src/main.ts
import * as Sentry from '@sentry/node';
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 1.0,
});
```

### Google Analytics

1. **Create GA4 Property**
2. **Add to Frontend**
```dart
// lib/services/monitoring_service.dart
await FirebaseAnalytics.instance.logEvent(
  name: 'delivery_created',
  parameters: {'cost': cost, 'distance': distance}
);
```

### Health Checks

1. **Application Health**
   - Endpoint: `GET /health`
   - Returns: `{"status": "ok", "timestamp": "..."}`

2. **Database Health**
   - Check MongoDB connection
   - Monitor query performance

3. **WebSocket Health**
   - Monitor active connections
   - Track message throughput

## Security Configuration

### HTTPS Everywhere
```nginx
# Force HTTPS
server {
    listen 80;
    server_name ubermoto.com www.ubermoto.com;
    return 301 https://$server_name$request_uri;
}
```

### CORS Configuration
```typescript
// backend/src/main.ts
app.enableCors({
  origin: process.env.NODE_ENV === 'production'
    ? ['https://ubermoto.com', 'https://www.ubermoto.com']
    : true,
  credentials: true,
});
```

### Rate Limiting
```typescript
// Install express-rate-limit
npm install express-rate-limit

// Configure
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});
app.use(limiter);
```

### Input Validation
- All endpoints use class-validator decorators
- Sanitize user inputs
- Validate file uploads (type, size, content)

## Performance Optimization

### Backend Optimizations
```typescript
// Enable gzip compression
import * as compression from 'compression';
app.use(compression());

// Use helmet for security headers
import * as helmet from 'helmet';
app.use(helmet());
```

### Database Optimizations
- Create proper indexes
- Use aggregation pipelines for complex queries
- Implement caching (Redis) for frequently accessed data
- Monitor slow queries

### Frontend Optimizations
```bash
# Build with optimizations
flutter build web --release --dart-define=DART_VM_OPTIONS=--optimize

# Enable tree shaking
flutter build apk --release --split-debug-info=build/debug-info
```

## Backup and Recovery

### Database Backup
```bash
# MongoDB Atlas automatic backups
# Or manual backup script
mongodump --db ubermoto_prod --out /backup/$(date +%Y%m%d_%H%M%S)

# Restore
mongorestore --db ubermoto_prod /backup/backup_directory
```

### Application Backup
- Code is backed up via Git
- Configuration files should be version controlled (without secrets)
- Use environment-specific config files

### Disaster Recovery
1. **Multiple Regions**: Deploy to multiple geographic regions
2. **Load Balancing**: Distribute traffic across instances
3. **Auto-scaling**: Scale based on demand
4. **CDN**: Use CloudFront/Cloudflare for static assets

## Troubleshooting

### Common Issues

#### Backend Won't Start
```bash
# Check logs
pm2 logs ubermoto-api

# Check environment variables
pm2 show ubermoto-api

# Check database connection
curl http://localhost:3001/health
```

#### Frontend Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release

# Check Flutter doctor
flutter doctor -v
```

#### WebSocket Not Working
```bash
# Check server logs for WebSocket errors
pm2 logs ubermoto-api | grep -i websocket

# Test WebSocket connection
curl -I -N -H "Connection: Upgrade" -H "Upgrade: websocket" http://localhost:3001/delivery
```

#### Database Connection Issues
```bash
# Test connection
mongosh "mongodb+srv://username:password@cluster.mongodb.net/ubermoto_prod"

# Check connection string format
# Ensure IP whitelist includes your server IP
```

### Monitoring Commands

```bash
# Check application status
pm2 status

# Monitor logs
pm2 logs ubermoto-api --lines 100

# Check resource usage
pm2 monit

# Restart application
pm2 restart ubermoto-api

# Check MongoDB status
mongosh --eval "db.serverStatus()"
```

### Performance Debugging

```bash
# Check API response times
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3001/health

# Monitor database queries
mongosh --eval "db.currentOp()"

# Check memory usage
pm2 show ubermoto-api
```

---

## Post-Deployment Checklist

- [ ] Backend deployed and accessible
- [ ] Frontend deployed and loading
- [ ] Database connected and populated
- [ ] SSL certificate installed
- [ ] Domain configured
- [ ] Monitoring tools active
- [ ] Error tracking working
- [ ] Analytics collecting data
- [ ] Backup systems configured
- [ ] Security headers enabled
- [ ] Performance optimized
- [ ] Documentation updated

---

*This deployment guide ensures UberMoto is production-ready with high availability, security, and performance.*
