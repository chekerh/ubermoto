#!/bin/bash

# Script to start both backend and frontend for development
# Supports multiple ports: 3001, 3002, 3003, 3004

PORT=${1:-3001}  # Use first argument as port, default to 3001

if [[ ! "$PORT" =~ ^300[1-4]$ ]]; then
  echo "❌ Error: Port must be 3001, 3002, 3003, or 3004"
  echo "Usage: ./start-dev.sh [PORT]"
  exit 1
fi

echo "🚀 Starting UberMoto Development Environment on port $PORT..."
echo ""

# Export PORT for backend
export PORT=$PORT

# Start backend in background
echo "📦 Starting NestJS Backend on port $PORT..."
cd backend
npm run start:dev &
BACKEND_PID=$!
cd ..

# Wait a bit for backend to start
sleep 5

# Start frontend
echo "📱 Starting Flutter Frontend..."
echo "💡 Make sure frontend/lib/config/app_config.dart has backendPort = $PORT"
cd frontend
flutter run

# When frontend exits, kill backend
echo "🛑 Stopping backend..."
kill $BACKEND_PID 2>/dev/null || true
