#!/bin/bash

# UberMoto CI/CD Verification Script
# This script verifies that tests pass locally and prepares for GitHub Actions

echo "🚀 UberMoto CI/CD Verification"
echo "=============================="

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
        exit 1
    fi
}

# Backend verification
echo ""
echo "🔧 Verifying Backend..."
cd backend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install > /dev/null 2>&1
    print_status $? "Backend dependencies installed"
fi

# Run linting
echo "Running ESLint..."
npm run lint > /dev/null 2>&1
print_status $? "Backend linting passed"

# Run tests
echo "Running backend tests..."
npm run test > /dev/null 2>&1
print_status $? "Backend tests passed"

# Check test coverage
echo "Checking test coverage..."
npm run test:cov > /dev/null 2>&1
print_status $? "Backend coverage generated"

cd ..

# Frontend verification
echo ""
echo "📱 Verifying Frontend..."
cd frontend

# Check if dependencies are installed
if [ ! -d ".dart_tool" ]; then
    echo "Installing frontend dependencies..."
    flutter pub get > /dev/null 2>&1
    print_status $? "Frontend dependencies installed"
fi

# Run Flutter analyze
echo "Running Flutter analyze..."
flutter analyze > /dev/null 2>&1
print_status $? "Frontend analysis passed"

# Run tests
echo "Running frontend tests..."
flutter test > /dev/null 2>&1
print_status $? "Frontend tests passed"

cd ..

# GitHub Actions verification
echo ""
echo "🔄 Checking GitHub Actions Configuration..."

# Check if workflows exist
if [ -f ".github/workflows/backend-ci.yml" ]; then
    echo -e "${GREEN}✅ Backend CI/CD workflow found${NC}"
else
    echo -e "${RED}❌ Backend CI/CD workflow missing${NC}"
fi

if [ -f ".github/workflows/frontend-ci.yml" ]; then
    echo -e "${GREEN}✅ Frontend CI/CD workflow found${NC}"
else
    echo -e "${RED}❌ Frontend CI/CD workflow missing${NC}"
fi

# Check git status
echo ""
echo "📊 Git Status Check..."
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${GREEN}✅ Working directory is clean${NC}"
else
    echo -e "${YELLOW}⚠️  Uncommitted changes detected${NC}"
    echo "Run 'git status' to see changes"
fi

echo ""
echo "🎯 CI/CD Verification Complete!"
echo ""
echo "Next steps:"
echo "1. Push changes to trigger GitHub Actions"
echo "2. Monitor Actions tab for test results"
echo "3. Check deployment status after successful tests"
echo ""
echo "🚀 Ready for automated deployment!"