# UberMoto Backend Deployment Guide

## Prerequisites
- Node.js 18+
- MongoDB database
- Environment variables configured

## Environment Variables Required
```bash
MONGODB_URI=mongodb://username:password@host:port/database
JWT_SECRET=your_jwt_secret_key_here
PORT=3001
NODE_ENV=production
```

## Deployment Steps

### Option 1: Heroku Deployment
1. Create Heroku app: `heroku create your-app-name`
2. Set environment variables: `heroku config:set MONGODB_URI="..." JWT_SECRET="..."`
3. Deploy: `git push heroku main`

### Option 2: AWS EC2 Deployment
1. Launch EC2 instance with Node.js
2. Configure security groups (ports 22, 80, 443, 3001)
3. Clone repository and install dependencies
4. Configure PM2 for process management
5. Set up Nginx reverse proxy

### Option 3: Docker Deployment
```bash
# Build Docker image
docker build -t ubermoto-backend .

# Run container
docker run -p 3001:3001 \
  -e MONGODB_URI="..." \
  -e JWT_SECRET="..." \
  ubermoto-backend
```

## Health Checks
- Application health: `GET /health`
- API documentation: `GET /api`
- WebSocket endpoint: `ws://your-domain/delivery`

## Monitoring
- Logs: Check application logs for errors
- Database: Monitor MongoDB connection status
- Performance: Track response times and error rates
