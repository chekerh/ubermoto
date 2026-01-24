# 🔧 UberMoto Troubleshooting Guide

Common issues and solutions for UberMoto deployment and development.

## Backend Issues

### Application Won't Start

**Symptoms:**
- `npm start` fails
- Port 3001 not accessible
- Application crashes immediately

**Solutions:**

1. **Check Node.js version**
```bash
node --version  # Should be 18+
npm --version   # Should be 8+
```

2. **Check environment variables**
```bash
# Ensure .env file exists
ls -la .env

# Check required variables
grep -E "(MONGODB_URI|JWT_SECRET)" .env
```

3. **Check database connection**
```bash
# Test MongoDB connection
mongosh "your_mongodb_uri" --eval "db.adminCommand('ping')"
```

4. **Check dependencies**
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

5. **Check build**
```bash
# Clean and rebuild
npm run build
npm run start:prod
```

### Database Connection Issues

**Symptoms:**
- `MongoServerError: bad auth` errors
- `ECONNREFUSED` errors
- Slow queries

**Solutions:**

1. **Verify connection string**
```bash
# MongoDB Atlas format
mongodb+srv://username:password@cluster.mongodb.net/database?retryWrites=true&w=majority

# Local format
mongodb://localhost:27017/ubermoto
```

2. **Check network access**
```bash
# Test basic connectivity
ping cluster.mongodb.net

# Check if IP is whitelisted (Atlas)
```

3. **Verify credentials**
```bash
# Test with MongoDB shell
mongosh "mongodb+srv://username:password@cluster.mongodb.net/database"
```

4. **Check database permissions**
```bash
# Ensure user has read/write access
db.getUser("username")
```

### WebSocket Connection Issues

**Symptoms:**
- Real-time updates not working
- WebSocket connection errors
- `WebSocket is not connected` messages

**Solutions:**

1. **Check CORS configuration**
```typescript
// backend/src/main.ts
app.enableCors({
  origin: true, // For development
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
  credentials: true,
});
```

2. **Verify WebSocket endpoint**
```bash
# Test WebSocket upgrade
curl -I -N -H "Connection: Upgrade" -H "Upgrade: websocket" http://localhost:3001/delivery
```

3. **Check client connection**
```javascript
// Frontend connection test
const socket = io('http://localhost:3001/delivery', {
  auth: { token: 'your_jwt_token' }
});

socket.on('connect', () => console.log('Connected'));
socket.on('connect_error', (error) => console.log('Error:', error));
```

4. **Check authentication**
```bash
# Verify JWT token is valid
curl -H "Authorization: Bearer your_token" http://localhost:3001/auth/me
```

## Frontend Issues

### Build Failures

**Symptoms:**
- `flutter build` fails
- Compilation errors
- Missing dependencies

**Solutions:**

1. **Clean build**
```bash
flutter clean
flutter pub get
flutter build web --release
```

2. **Check Flutter version**
```bash
flutter --version
flutter doctor
```

3. **Fix dependency issues**
```bash
# Update dependencies
flutter pub upgrade

# Check for conflicting versions
flutter pub deps
```

4. **Resolve compilation errors**
```bash
# Check for syntax errors
flutter analyze

# Fix import issues
flutter pub run import_sorter:main
```

### Hot Reload Not Working

**Symptoms:**
- Changes not reflected in browser
- Hot reload fails
- Page doesn't update

**Solutions:**

1. **Check development server**
```bash
flutter run -d web-server --web-port=8080
```

2. **Clear browser cache**
```bash
# Hard refresh in browser
Ctrl+Shift+R (Windows/Linux)
Cmd+Shift+R (Mac)
```

3. **Check for compilation errors**
```bash
flutter analyze
flutter build web --debug
```

4. **Restart development server**
```bash
# Kill existing process
pkill -f "flutter"
# Restart
flutter run -d web-server --web-port=8080
```

### Google Maps Not Loading

**Symptoms:**
- Map shows blank or error
- "Google Maps API error" messages
- Location services not working

**Solutions:**

1. **Check API key**
```bash
# Verify API key is valid
curl "https://maps.googleapis.com/maps/api/geocode/json?address=Tunis&key=YOUR_API_KEY"
```

2. **Enable required APIs**
```bash
# Google Cloud Console - APIs to enable:
# - Maps JavaScript API
# - Geocoding API
# - Places API (optional)
```

3. **Check billing**
```bash
# Ensure billing is enabled for Google Cloud project
# Check quota limits
```

4. **Verify configuration**
```dart
// Ensure API key is properly configured
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(36.8065, 10.1815),
    zoom: 12,
  ),
  markers: _markers,
  polylines: _polylines,
);
```

### Authentication Issues

**Symptoms:**
- Login fails
- Token not saved
- Unauthorized access errors

**Solutions:**

1. **Check backend authentication**
```bash
# Test login endpoint
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

2. **Verify token storage**
```dart
// Check secure storage
final token = await StorageService.getToken();
print('Token: $token');
```

3. **Check token expiration**
```bash
# Decode JWT token
node -e "
const jwt = require('jsonwebtoken');
const token = 'your_token_here';
console.log(jwt.decode(token));
"
```

4. **Verify API calls include token**
```dart
// Ensure Authorization header
final response = await http.get(
  Uri.parse('$baseUrl/deliveries'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

## Database Issues

### Connection Timeouts

**Symptoms:**
- Database queries timeout
- `MongoTimeoutError` errors
- Slow response times

**Solutions:**

1. **Check connection string**
```bash
# Ensure correct format
mongodb+srv://username:password@cluster.mongodb.net/database?retryWrites=true&w=majority
```

2. **Verify network connectivity**
```bash
# Test basic connectivity
ping cluster.mongodb.net

# Check firewall settings
telnet cluster.mongodb.net 27017
```

3. **Optimize connection pool**
```typescript
// In database config
mongoose.connect(uri, {
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
});
```

### Data Consistency Issues

**Symptoms:**
- Inconsistent data between collections
- Missing relationships
- Orphaned records

**Solutions:**

1. **Check foreign key relationships**
```javascript
// Verify referenced documents exist
db.deliveries.find({}).forEach(doc => {
  if (doc.userId && !db.users.findOne({_id: doc.userId})) {
    print('Orphaned delivery:', doc._id);
  }
});
```

2. **Validate data integrity**
```javascript
// Check for invalid data
db.deliveries.find({
  $or: [
    { status: { $nin: ['pending', 'accepted', 'picked_up', 'in_progress', 'completed', 'cancelled'] } },
    { estimatedCost: { $lt: 0 } }
  ]
});
```

3. **Fix data issues**
```javascript
// Remove invalid records
db.deliveries.remove({
  status: { $nin: ['pending', 'accepted', 'picked_up', 'in_progress', 'completed', 'cancelled'] }
});
```

## Performance Issues

### Slow API Responses

**Symptoms:**
- API calls take >2 seconds
- Database queries are slow
- High CPU/memory usage

**Solutions:**

1. **Check database indexes**
```javascript
// List existing indexes
db.deliveries.getIndexes()

// Create missing indexes
db.deliveries.createIndex({ userId: 1, status: 1 })
db.deliveries.createIndex({ createdAt: -1 })
```

2. **Profile slow queries**
```javascript
// Enable profiling
db.setProfilingLevel(2)

// Check slow queries
db.system.profile.find().sort({ ts: -1 }).limit(5)
```

3. **Optimize application code**
```typescript
// Use lean queries for read-only operations
const deliveries = await this.deliveryModel.find().lean();

// Implement caching
import { CacheModule } from '@nestjs/cache-manager';
```

### Memory Leaks

**Symptoms:**
- Increasing memory usage over time
- Application crashes with OOM errors
- Performance degrades over time

**Solutions:**

1. **Monitor memory usage**
```bash
# Check PM2 process
pm2 monit

# Check Node.js memory
node -e "console.log(process.memoryUsage())"
```

2. **Fix memory leaks**
```typescript
// Close database connections properly
process.on('SIGINT', async () => {
  await mongoose.connection.close();
  process.exit(0);
});

// Use connection pooling
mongoose.connect(uri, {
  maxPoolSize: 10,
  minPoolSize: 5,
});
```

3. **Implement garbage collection**
```bash
# Force garbage collection (development only)
node --expose-gc --max-old-space-size=4096
```

## Deployment Issues

### SSL Certificate Problems

**Symptoms:**
- HTTPS not working
- Certificate errors
- Mixed content warnings

**Solutions:**

1. **Check certificate installation**
```bash
# Verify certificate
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Check certificate validity
openssl x509 -in certificate.crt -text -noout
```

2. **Configure Nginx for SSL**
```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
}
```

3. **Redirect HTTP to HTTPS**
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

### Domain Configuration Issues

**Symptoms:**
- Website not accessible
- DNS resolution fails
- SSL certificate mismatch

**Solutions:**

1. **Check DNS configuration**
```bash
# Verify DNS records
dig yourdomain.com

# Check nameservers
whois yourdomain.com
```

2. **Update DNS records**
```bash
# A record for root domain
# CNAME for www subdomain
# Update nameservers if changed
```

3. **Wait for propagation**
```bash
# DNS changes can take 24-48 hours
# Check propagation with multiple DNS checkers
```

## Monitoring and Logging

### Setting up Application Logs

1. **Configure Winston logger**
```typescript
import * as winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});
```

2. **Log API requests**
```typescript
// middleware/logger.middleware.ts
import { Injectable, NestMiddleware, Logger } from '@nestjs/common';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  private logger = new Logger('HTTP');

  use(req: Request, res: Response, next: NextFunction) {
    const { method, originalUrl } = req;
    const start = Date.now();

    res.on('finish', () => {
      const { statusCode } = res;
      const duration = Date.now() - start;
      this.logger.log(`${method} ${originalUrl} ${statusCode} ${duration}ms`);
    });

    next();
  }
}
```

### Database Query Logging

```javascript
// Enable MongoDB profiling
db.setProfilingLevel(2, { slowms: 100 });

// View slow queries
db.system.profile.find().sort({ ts: -1 }).limit(10);

// Create indexes for slow queries
db.deliveries.createIndex({ userId: 1, status: 1 });
db.deliveries.createIndex({ createdAt: -1 });
```

## Emergency Procedures

### Application Down
1. **Check server status**
```bash
# SSH into server
ssh user@server

# Check process status
pm2 status
pm2 logs ubermoto-api --lines 50
```

2. **Restart services**
```bash
# Restart application
pm2 restart ubermoto-api

# Restart web server
sudo systemctl restart nginx
```

3. **Check database connectivity**
```bash
# Test database connection
mongosh "mongodb_uri" --eval "db.adminCommand('ping')"
```

### Data Loss Recovery
1. **Check backups**
```bash
# List available backups
ls -la /backup/

# Restore from backup
mongorestore --db ubermoto_prod /backup/latest_backup/
```

2. **Verify data integrity**
```bash
# Check record counts
db.users.count()
db.deliveries.count()
db.drivers.count()
```

### Security Incident Response
1. **Isolate affected systems**
2. **Change all credentials**
3. **Audit access logs**
4. **Update security patches**
5. **Notify affected users**

---

## Contact and Support

For additional support:
- 📧 Email: support@ubermoto.com
- 📖 Documentation: https://docs.ubermoto.com
- 🐛 GitHub Issues: https://github.com/ubermoto/platform/issues
- 💬 Community Forum: https://community.ubermoto.com

---

*This troubleshooting guide covers the most common issues encountered during UberMoto development and deployment.*
