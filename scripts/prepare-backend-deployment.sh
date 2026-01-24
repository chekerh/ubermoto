#!/bin/bash

# UberMoto Backend Deployment Preparation Script
# Prepares backend for deployment without actually deploying

echo "🔧 UberMoto Backend Deployment Preparation"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✅ $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

cd backend

# Check environment variables
echo "🔍 Checking Environment Variables..."

# Check for required environment variables
required_vars=("MONGODB_URI" "JWT_SECRET" "PORT")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All required environment variables are set${NC}"
else
    echo -e "${YELLOW}⚠️  Missing environment variables:${NC}"
    for var in "${missing_vars[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "Please set these environment variables:"
    echo "export MONGODB_URI='your_mongodb_connection_string'"
    echo "export JWT_SECRET='your_jwt_secret_key'"
    echo "export PORT=3001"
fi

# Check database connectivity
echo ""
echo "🗄️  Checking Database Connectivity..."

# Test MongoDB connection (requires mongosh or mongo client)
if command -v mongosh &> /dev/null; then
    echo "Testing MongoDB connection..."
    # This would require actual MongoDB URI - placeholder for now
    echo -e "${YELLOW}⚠️  Manual MongoDB connection test required${NC}"
elif command -v mongo &> /dev/null; then
    echo "Testing MongoDB connection..."
    echo -e "${YELLOW}⚠️  Manual MongoDB connection test required${NC}"
else
    echo -e "${YELLOW}⚠️  MongoDB client not found - install mongosh for connection testing${NC}"
fi

# Build the application
echo ""
echo "🔨 Building Backend Application..."
npm run build > /dev/null 2>&1
print_status $? "Backend build successful"

# Check build output
if [ -d "dist" ]; then
    echo -e "${GREEN}✅ Build artifacts created in 'dist/' directory${NC}"
    echo "   Build size: $(du -sh dist | cut -f1)"
else
    echo -e "${RED}❌ Build artifacts not found${NC}"
fi

# Security check
echo ""
echo "🔒 Security Checks..."

# Check for sensitive files
sensitive_files=(".env" ".env.local" ".env.production")
for file in "${sensitive_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${RED}⚠️  Sensitive file found: $file${NC}"
        echo "   Ensure this file is not committed to version control"
    fi
done

# Check for hardcoded secrets in source code
echo "Checking for hardcoded secrets..."
if grep -r "mongodb://" src/ --include="*.ts" > /dev/null 2>&1; then
    echo -e "${RED}⚠️  Potential hardcoded MongoDB URI found in source code${NC}"
else
    echo -e "${GREEN}✅ No hardcoded MongoDB URIs found${NC}"
fi

# Performance check
echo ""
echo "⚡ Performance Checks..."

# Check bundle size
if [ -f "dist/main.js" ]; then
    bundle_size=$(stat -f%z dist/main.js 2>/dev/null || stat -c%s dist/main.js 2>/dev/null || echo "unknown")
    echo "Bundle size: ${bundle_size} bytes"

    # Warning for large bundles
    if [ "$bundle_size" -gt 10000000 ] 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Bundle size is large (>10MB)${NC}"
    else
        echo -e "${GREEN}✅ Bundle size is reasonable${NC}"
    fi
fi

# Generate deployment documentation
echo ""
echo "📚 Generating Deployment Documentation..."

cat > DEPLOYMENT_README.md << 'EOF'
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
EOF

print_status 0 "Deployment documentation generated"

echo ""
echo "🎯 Backend Deployment Preparation Complete!"
echo ""
echo "📋 Manual Deployment Steps:"
echo "1. Choose your deployment platform (Heroku/AWS/Docker)"
echo "2. Set environment variables on your platform"
echo "3. Deploy using platform-specific commands"
echo "4. Test endpoints: /health, /api"
echo "5. Configure domain and SSL certificates"
echo ""
echo "🚀 Ready for manual deployment to production!"