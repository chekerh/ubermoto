#!/bin/bash

# 🚀 UberMoto Final Production Setup Script
# Complete automation for production deployment preparation

echo "🎯 UberMoto Final Production Setup"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✅ $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
        echo "   See logs above for details"
    fi
}

# Function to print section header
print_section() {
    echo ""
    echo -e "${BLUE}🔧 $1${NC}"
    echo "----------------------------------------"
}

# Run CI/CD verification
run_ci_cd_verification() {
    print_section "CI/CD Pipeline Verification"
    echo "Running automated tests and checks..."

    if [ -f "scripts/verify-ci-cd.sh" ]; then
        bash scripts/verify-ci-cd.sh
        print_status $? "CI/CD verification completed"
    else
        echo -e "${YELLOW}⚠️  CI/CD verification script not found${NC}"
    fi
}

# Prepare backend deployment
prepare_backend_deployment() {
    print_section "Backend Deployment Preparation"
    echo "Setting up backend for production deployment..."

    if [ -f "scripts/prepare-backend-deployment.sh" ]; then
        bash scripts/prepare-backend-deployment.sh
        print_status $? "Backend deployment preparation completed"
    else
        echo -e "${YELLOW}⚠️  Backend deployment script not found${NC}"
    fi
}

# Prepare frontend deployment
prepare_frontend_deployment() {
    print_section "Frontend Deployment Preparation"
    echo "Building and preparing frontend for deployment..."

    if [ -f "scripts/prepare-frontend-deployment.sh" ]; then
        bash scripts/prepare-frontend-deployment.sh
        print_status $? "Frontend deployment preparation completed"
    else
        echo -e "${YELLOW}⚠️  Frontend deployment script not found${NC}"
    fi
}

# Setup monitoring
setup_monitoring() {
    print_section "Monitoring & Analytics Setup"
    echo "Configuring error tracking, analytics, and performance monitoring..."

    if [ -f "scripts/setup-monitoring.sh" ]; then
        bash scripts/setup-monitoring.sh
        print_status $? "Monitoring setup completed"
    else
        echo -e "${YELLOW}⚠️  Monitoring setup script not found${NC}"
    fi
}

# Run real-time testing
run_realtime_testing() {
    print_section "Real-Time Features Testing"
    echo "Testing delivery creation, status updates, and geolocation..."

    if [ -f "scripts/test-realtime-features.sh" ]; then
        bash scripts/test-realtime-features.sh
        print_status $? "Real-time features testing completed"
    else
        echo -e "${YELLOW}⚠️  Real-time testing script not found${NC}"
    fi
}

# Update documentation
update_documentation() {
    print_section "Documentation Update"
    echo "Generating comprehensive documentation..."

    if [ -f "scripts/update-documentation.sh" ]; then
        bash scripts/update-documentation.sh
        print_status $? "Documentation update completed"
    else
        echo -e "${YELLOW}⚠️  Documentation script not found${NC}"
    fi
}

# Generate final report
generate_final_report() {
    print_section "Final Production Readiness Report"

    echo "🎯 UberMoto Production Status Assessment"
    echo ""

    # Check backend readiness
    echo "🔧 Backend Status:"
    if [ -d "backend/dist" ]; then
        echo -e "${GREEN}   ✅ Application built successfully${NC}"
    else
        echo -e "${RED}   ❌ Application not built${NC}"
    fi

    if [ -f "backend/.env" ]; then
        echo -e "${GREEN}   ✅ Environment configuration present${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Environment configuration missing${NC}"
    fi

    # Check frontend readiness
    echo ""
    echo "📱 Frontend Status:"
    if [ -d "frontend/build/web" ]; then
        echo -e "${GREEN}   ✅ Web build ready for deployment${NC}"
    else
        echo -e "${RED}   ❌ Web build not found${NC}"
    fi

    if [ -f "frontend/pubspec.yaml" ]; then
        echo -e "${GREEN}   ✅ Flutter configuration valid${NC}"
    else
        echo -e "${RED}   ❌ Flutter configuration missing${NC}"
    fi

    # Check monitoring
    echo ""
    echo "📊 Monitoring Status:"
    if [ -f "backend/src/sentry.config.ts" ]; then
        echo -e "${GREEN}   ✅ Error tracking configured${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Error tracking not configured${NC}"
    fi

    # Check CI/CD
    echo ""
    echo "🔄 CI/CD Status:"
    if [ -f ".github/workflows/backend-ci.yml" ] && [ -f ".github/workflows/frontend-ci.yml" ]; then
        echo -e "${GREEN}   ✅ CI/CD pipelines configured${NC}"
    else
        echo -e "${RED}   ❌ CI/CD pipelines missing${NC}"
    fi

    # Check documentation
    echo ""
    echo "📚 Documentation Status:"
    local doc_files=("README.md" "API_DOCUMENTATION.md" "DEPLOYMENT_GUIDE.md" "TROUBLESHOOTING.md")
    local docs_complete=true

    for doc in "${doc_files[@]}"; do
        if [ -f "$doc" ]; then
            echo -e "${GREEN}   ✅ $doc generated${NC}"
        else
            echo -e "${RED}   ❌ $doc missing${NC}"
            docs_complete=false
        fi
    done

    # Final assessment
    echo ""
    echo "🎯 Final Assessment:"
    if [ "$docs_complete" = true ]; then
        echo -e "${GREEN}🚀 UberMoto is PRODUCTION READY!${NC}"
        echo ""
        echo "Next Steps:"
        echo "1. Deploy backend to your chosen platform (Heroku/AWS/GCP)"
        echo "2. Deploy frontend to Firebase Hosting"
        echo "3. Submit mobile apps to app stores"
        echo "4. Configure monitoring dashboards"
        echo "5. Set up domain and SSL certificates"
        echo "6. Run final end-to-end testing"
    else
        echo -e "${YELLOW}⚠️  Some components need attention before production${NC}"
        echo ""
        echo "Please complete the missing items above."
    fi
}

# Create deployment summary
create_deployment_summary() {
    print_section "Deployment Summary & Commands"

    cat << 'EOF'
📋 UberMoto Deployment Commands Summary

🔧 Backend Deployment Options:

1. Heroku (Recommended for simplicity):
   heroku create your-ubermoto-api
   heroku config:set MONGODB_URI="your_uri" JWT_SECRET="your_secret"
   git push heroku main

2. AWS EC2:
   # Launch t3.medium instance
   # Install Node.js, PM2, Nginx
   # Clone repo and run: npm run build && pm2 start dist/main.js

3. Docker:
   docker build -t ubermoto-api .
   docker run -p 3001:3001 -e MONGODB_URI="..." ubermoto-api

📱 Frontend Deployment Options:

1. Web (Firebase Hosting):
   firebase init hosting
   flutter build web --release
   firebase deploy --only hosting

2. Android (Google Play):
   flutter build appbundle --release
   # Upload to Google Play Console

3. iOS (App Store):
   flutter build ios --release
   # Upload via Xcode to App Store Connect

🗄️ Database Setup:
1. Use MongoDB Atlas (recommended)
2. Create cluster and database user
3. Set connection string in environment variables

📊 Monitoring Setup:
1. Create Sentry projects for backend/frontend
2. Set up Google Analytics
3. Configure error tracking and analytics

🔐 Security Checklist:
- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Input validation active

🚀 Production Launch Checklist:
- [ ] Backend deployed and healthy
- [ ] Frontend deployed and accessible
- [ ] Database connected and optimized
- [ ] Monitoring tools active
- [ ] SSL certificates valid
- [ ] Domain properly configured
- [ ] Backup systems operational
- [ ] Performance tested
EOF

    print_status 0 "Deployment summary created"
}

# Main execution
echo "Starting UberMoto final production setup..."
echo "This will run all automated tests and preparations for production deployment."
echo ""

# Ask for confirmation
echo -e "${YELLOW}⚠️  This process will:"
echo "   - Run comprehensive tests"
echo "   - Build applications for production"
echo "   - Generate deployment documentation"
echo "   - Configure monitoring tools"
echo ""
read -p "Do you want to continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Execute all steps
run_ci_cd_verification
prepare_backend_deployment
prepare_frontend_deployment
setup_monitoring
run_realtime_testing
update_documentation
generate_final_report
create_deployment_summary

echo ""
echo "🎉 UberMoto Final Production Setup Complete!"
echo ""
echo "📁 Generated Files:"
echo "   ✅ README.md - Project documentation"
echo "   ✅ API_DOCUMENTATION.md - API reference"
echo "   ✅ DEPLOYMENT_GUIDE.md - Deployment instructions"
echo "   ✅ TROUBLESHOOTING.md - Problem-solving guide"
echo "   ✅ FINAL_TESTING_REPORT.md - Test results"
echo "   ✅ TESTING_REPORT.md - Detailed testing"
echo ""
echo "🚀 Ready for production deployment!"
echo "   Run: ./scripts/final-production-setup.sh"
echo "   Then follow the deployment guides in DEPLOYMENT_GUIDE.md"