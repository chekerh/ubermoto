# API Testing Guide - UberMoto

## 📚 Table of Contents
1. [MongoDB Setup](#mongodb-setup)
2. [Swagger Documentation](#swagger-documentation)
3. [Postman Collection](#postman-collection)
4. [Testing Endpoints](#testing-endpoints)

---

## 🗄️ MongoDB Setup

### Option 1: Install MongoDB Locally

**macOS (using Homebrew):**
```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

**Verify Installation:**
```bash
mongosh
# or
mongo
```

### Option 2: Use MongoDB Atlas (Cloud - Free Tier)

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free account
3. Create a new cluster (free tier)
4. Get your connection string
5. Update `.env` file:
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ubermoto?retryWrites=true&w=majority
```

### Option 3: Use Docker

```bash
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

### Update .env File

Create or update `backend/.env`:
```env
MONGODB_URI=mongodb://localhost:27017/ubermoto
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=1h
PORT=3000
FUEL_PRICE_PER_LITER=2.5
BASE_DELIVERY_FEE=5.0
```

---

## 📖 Swagger Documentation

### Access Swagger UI

Once the backend is running, open your browser and navigate to:

```
http://localhost:3000/api
```

### Features:
- ✅ Interactive API documentation
- ✅ Test endpoints directly from the browser
- ✅ JWT authentication support
- ✅ Request/Response examples
- ✅ Schema validation

### Using Swagger:

1. **Start the backend:**
   ```bash
   cd backend
   npm run start:dev
   ```

2. **Open Swagger UI:**
   - Navigate to `http://localhost:3000/api`
   - You'll see all available endpoints organized by tags

3. **Test Authentication:**
   - Click on `POST /auth/register` or `POST /auth/login`
   - Click "Try it out"
   - Fill in the request body
   - Click "Execute"
   - Copy the `access_token` from the response

4. **Use JWT Token:**
   - Click the "Authorize" button at the top
   - Enter your token: `Bearer <your-token>`
   - Click "Authorize"
   - Now all protected endpoints will use this token

---

## 📮 Postman Collection

### Import Collection

1. **Open Postman**
2. **Import Collection:**
   - Click "Import" button
   - Select `UberMoto_API.postman_collection.json`
   - Also import `UberMoto_API.postman_environment.json`

3. **Set Environment:**
   - Select "UberMoto Local" from the environment dropdown
   - Verify `base_url` is set to `http://localhost:3000/api`

### Using the Collection

#### 1. Register/Login First

**Register:**
- Go to `Authentication > Register`
- Update the request body with your details
- Click "Send"
- The token will be automatically saved to `access_token` variable

**Login:**
- Go to `Authentication > Login`
- Update email and password
- Click "Send"
- Token is automatically saved

#### 2. Test Protected Endpoints

All endpoints in `Motorcycles` and `Deliveries` folders are protected and will automatically use the saved token.

#### 3. Available Endpoints

**Authentication:**
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user

**Motorcycles:**
- `POST /motorcycles` - Create motorcycle
- `GET /motorcycles` - Get all motorcycles
- `GET /motorcycles/:id` - Get motorcycle by ID
- `PATCH /motorcycles/:id` - Update motorcycle
- `DELETE /motorcycles/:id` - Delete motorcycle

**Deliveries:**
- `POST /deliveries` - Create delivery
- `GET /deliveries` - Get all deliveries (for authenticated user)
- `GET /deliveries/:id` - Get delivery by ID
- `PATCH /deliveries/:id/status` - Update delivery status
- `POST /deliveries/:id/calculate-cost` - Calculate delivery cost

**Health:**
- `GET /health` - Health check

---

## 🧪 Testing Endpoints

### Example: Complete Flow

1. **Register a user:**
   ```json
   POST /api/auth/register
   {
     "email": "test@example.com",
     "password": "password123",
     "name": "Test User"
   }
   ```

2. **Login:**
   ```json
   POST /api/auth/login
   {
     "email": "test@example.com",
     "password": "password123"
   }
   ```
   Response:
   ```json
   {
     "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   }
   ```

3. **Create a motorcycle:**
   ```json
   POST /api/motorcycles
   Authorization: Bearer <token>
   {
     "model": "Forza",
     "brand": "Honda",
     "fuelConsumption": 3.5,
     "engineType": "4-stroke",
     "capacity": 300,
     "year": 2020
   }
   ```

4. **Create a delivery:**
   ```json
   POST /api/deliveries
   Authorization: Bearer <token>
   {
     "pickupLocation": "123 Main St, Tunis",
     "deliveryAddress": "456 Avenue Habib Bourguiba, Tunis",
     "deliveryType": "Food",
     "distance": 10.5,
     "motorcycleId": "<motorcycle_id_from_step_3>"
   }
   ```

---

## 💡 Tips

### Postman vs Swagger

**Postman is better for:**
- ✅ Complex workflows and testing sequences
- ✅ Environment variables and data management
- ✅ Automated testing and collections
- ✅ Team collaboration
- ✅ CI/CD integration
- ✅ Mock servers

**Swagger is better for:**
- ✅ Quick API exploration
- ✅ Documentation sharing
- ✅ Schema validation
- ✅ Interactive testing in browser
- ✅ No installation required

**Both are useful!** Use Swagger for quick tests and documentation, Postman for comprehensive testing and automation.

---

## 🔧 Troubleshooting

### MongoDB Connection Issues

```bash
# Check if MongoDB is running
brew services list | grep mongodb

# Restart MongoDB
brew services restart mongodb-community

# Check MongoDB logs
tail -f /usr/local/var/log/mongodb/mongo.log
```

### Backend Not Starting

1. Check MongoDB is running
2. Verify `.env` file exists and has correct values
3. Check port 3000 is not in use:
   ```bash
   lsof -i :3000
   ```

### Token Issues

- Make sure to include `Bearer ` prefix in Authorization header
- Token expires after 1 hour (configurable in `.env`)
- Re-login to get a new token

---

## 📝 Notes

- All protected endpoints require JWT token in Authorization header
- Token format: `Bearer <your-token>`
- Base URL: `http://localhost:3000/api`
- Swagger UI: `http://localhost:3000/api`
