#!/bin/bash

# Script to easily switch backend port for multiple projects

if [ -z "$1" ]; then
  echo "Usage: ./switch-port.sh <PORT>"
  echo "Available ports: 3001, 3002, 3003, 3004"
  echo ""
  echo "Example: ./switch-port.sh 3002"
  exit 1
fi

PORT=$1

# Validate port
if [[ ! "$PORT" =~ ^300[1-4]$ ]]; then
  echo "❌ Error: Port must be 3001, 3002, 3003, or 3004"
  exit 1
fi

echo "🔄 Switching to port $PORT..."

# Update backend .env file
if [ -f "backend/.env" ]; then
  if grep -q "^PORT=" backend/.env; then
    sed -i.bak "s/^PORT=.*/PORT=$PORT/" backend/.env
  else
    echo "PORT=$PORT" >> backend/.env
  fi
  echo "✅ Updated backend/.env"
else
  echo "⚠️  backend/.env not found, creating it..."
  cp backend/.env.example backend/.env 2>/dev/null || echo "PORT=$PORT" > backend/.env
  echo "✅ Created backend/.env with PORT=$PORT"
fi

# Update frontend config
sed -i.bak "s/static const int backendPort = [0-9]*;/static const int backendPort = $PORT;/" frontend/lib/config/app_config.dart
echo "✅ Updated frontend/lib/config/app_config.dart"

# Clean up backup files
rm -f backend/.env.bak frontend/lib/config/app_config.dart.bak

echo ""
echo "✅ Port switched to $PORT"
echo "📝 Don't forget to:"
echo "   1. Restart your backend: cd backend && npm run start:dev"
echo "   2. Hot reload your Flutter app (press 'r' in the Flutter terminal)"
echo ""
