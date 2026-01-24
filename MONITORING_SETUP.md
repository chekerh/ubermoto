# UberMoto Monitoring Setup Guide

## Backend Monitoring

### Sentry Error Tracking
1. Create a Sentry project at https://sentry.io
2. Get your DSN from the project settings
3. Set environment variable: `SENTRY_DSN=your_dsn_here`
4. Errors will be automatically captured and reported

### Performance Monitoring
- Response times are logged for all API endpoints
- Slow requests (>1000ms) are highlighted in logs
- Database query performance is monitored

### Health Checks
- Application health: `GET /health`
- Database connectivity status
- WebSocket server status

## Frontend Monitoring

### Sentry Error Tracking
1. Add your Sentry DSN to environment variables:
   ```bash
   flutter run --dart-define=SENTRY_DSN=your_dsn_here
   ```
2. Errors are automatically captured with stack traces
3. User feedback can be collected for crashes

### Google Analytics
1. Create a Google Analytics 4 property
2. Add your measurement ID to the app
3. Track user behavior and conversion funnels

### Custom Events Tracked
- `delivery_created`: When a customer creates a delivery
- `delivery_status_update`: When delivery status changes
- `driver_action`: Driver interactions (accept, start, complete)
- `user_registration`: New user signups
- `login_attempts`: Authentication events

## Datadog Integration (Optional)

### Setup Steps
1. Create Datadog account at https://datadog.com
2. Install Datadog agent on your server
3. Configure application metrics collection
4. Set up dashboards for UberMoto KPIs

### Metrics to Monitor
- API response times
- Error rates by endpoint
- User session duration
- Delivery completion rates
- Driver availability status
- Real-time active connections

## Alerting Setup

### Critical Alerts
- Application downtime
- High error rates (>5%)
- Database connection failures
- WebSocket server issues

### Performance Alerts
- Slow API responses (>2000ms)
- High memory usage (>80%)
- Database query timeouts

## Log Management

### Backend Logs
- Structured JSON logging
- Error level filtering
- Log rotation and archival
- Search and filtering capabilities

### Frontend Logs
- Console logging in development
- Error boundary captures in production
- User interaction tracking

## Testing Monitoring

### Backend Testing
```bash
# Test error reporting
curl -X GET http://localhost:3001/test-error

# Test performance monitoring
curl -X GET http://localhost:3001/health

# Check application metrics
curl -X GET http://localhost:3001/metrics
```

### Frontend Testing
```bash
# Test analytics events
flutter run --dart-define=ANALYTICS_DEBUG=true

# Test error reporting
flutter run --dart-define=SENTRY_DEBUG=true
```

## Environment Variables Required

### Backend
```bash
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
NODE_ENV=production
LOG_LEVEL=info
```

### Frontend
```bash
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
ANALYTICS_MEASUREMENT_ID=GA-XXXXXXXXXX
FIREBASE_PROJECT_ID=your-project-id
```

## Troubleshooting

### Common Issues
1. **Sentry not reporting errors**: Check DSN configuration
2. **Analytics not tracking**: Verify measurement ID
3. **Slow performance**: Check database indexes
4. **Memory leaks**: Monitor garbage collection

### Debug Mode
Enable debug logging:
```bash
# Backend
DEBUG=* npm run start:dev

# Frontend
flutter run --dart-define=DEBUG=true
```
