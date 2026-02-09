# Makan For You - Quick Reference Guide

## 🚀 Quick Start (5 Minutes)

### 1. Start Services (Open 5 terminals)
```bash
# Terminal 1
cd auth-service && mvn spring-boot:run

# Terminal 2
cd kitchen-service && mvn spring-boot:run

# Terminal 3
cd menu-service && mvn spring-boot:run

# Terminal 4
cd order-service && mvn spring-boot:run

# Terminal 5
cd api-gateway && mvn spring-boot:run
```

### 2. Test the API
```bash
# Register user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"John","lastName":"Doe","email":"john@test.com","phoneNumber":"9876543210","password":"Pass123456","role":"CUSTOMER"}'

# Copy the accessToken from response

# Browse kitchens (public endpoint)
curl http://localhost:8080/api/v1/kitchens?page=0&size=10

# Search menu items (public endpoint)
curl "http://localhost:8080/api/v1/menu-items/search?query=biryani"
```

---

## 📋 Common Tasks

### Authentication
```bash
# Register
POST /api/v1/auth/register
Body: {firstName, lastName, email, phoneNumber, password, role}

# Login
POST /api/v1/auth/login
Body: {email, password}

# Refresh Token
POST /api/v1/auth/refresh
Body: {refreshToken}

# Get Current User
GET /api/v1/auth/me
Header: Authorization: Bearer {token}, X-User-Id: {userId}
```

### Kitchen Management
```bash
# Register Kitchen (as KITCHEN user)
POST /api/v1/kitchens/register
Header: Authorization: Bearer {token}, X-User-Id: {userId}
Body: {kitchenName, address, city, ownerContact, ownerEmail, ...}

# Get Kitchen Details
GET /api/v1/kitchens/{id}

# List Approved Kitchens
GET /api/v1/kitchens?approved=true&page=0&size=10

# Search Kitchens
GET /api/v1/kitchens/search?query=indian

# Approve Kitchen (Admin only)
PATCH /api/v1/kitchens/{id}/approve
Header: Authorization: Bearer {adminToken}
```

### Menu Management
```bash
# Create Menu Item
POST /api/v1/menu-items
Header: Authorization: Bearer {token}, X-Kitchen-Id: {kitchenId}
Body: {itemName, description, cost, isVeg, isHalal, labelIds, ...}

# Advanced Search Menu Items
GET /api/v1/menu-items/search?query=biryani&minPrice=10&maxPrice=20&veg=false&halal=true&labels=spicy,homemade&sort=rating_desc

# Get Kitchen Menu
GET /api/v1/menu-items/kitchen/{kitchenId}?page=0&size=20

# Create Label (Admin)
POST /api/v1/menu-labels?name=vegan&description=Vegan friendly
Header: Authorization: Bearer {adminToken}

# List All Labels
GET /api/v1/menu-labels
```

### Order Management
```bash
# Create Order
POST /api/v1/orders
Header: Authorization: Bearer {customerToken}, X-User-Id: {userId}
Body: {
  kitchenId: 1,
  deliveryAddress: "123 Main St",
  items: [{itemId: 5, quantity: 2}, ...]
}

# Get My Orders
GET /api/v1/orders/my-orders?page=0&size=10
Header: Authorization: Bearer {customerToken}, X-User-Id: {userId}

# Get Kitchen Orders
GET /api/v1/orders/kitchen/{kitchenId}
Header: Authorization: Bearer {kitchenToken}

# Get Pending Orders
GET /api/v1/orders/kitchen/{kitchenId}/pending
Header: Authorization: Bearer {kitchenToken}

# Accept Order
PATCH /api/v1/orders/{orderId}/accept
Header: Authorization: Bearer {kitchenToken}, X-Kitchen-Id: {kitchenId}

# Update Status
PATCH /api/v1/orders/{orderId}/status?status=PREPARING
Header: Authorization: Bearer {kitchenToken}

# Cancel Order
PATCH /api/v1/orders/{orderId}/cancel
Header: Authorization: Bearer {customerToken}
```

---

## 🔑 Key Concepts

### Roles
- **CUSTOMER**: Browse, search, order, cancel orders
- **KITCHEN**: Register kitchen, manage menu, accept orders
- **ADMIN**: Approve kitchens, manage labels

### Order Status Flow
```
PENDING → CONFIRMED → PREPARING → READY → OUT_FOR_DELIVERY → DELIVERED
                                ↓
                            CANCELLED (any time)
```

### Filter Operators
- **query**: Full-text search on names and descriptions
- **kitchenId**: Filter by specific kitchen
- **minPrice, maxPrice**: Price range filter
- **veg**: true/false for vegetarian items
- **halal**: true/false for halal items
- **minSpicyLevel, maxSpicyLevel**: 1-5 scale
- **labels**: Comma-separated label names (e.g., "vegan,halal")
- **sort**: "rating_desc", "price_asc", "price_desc", "newest"

### Response Format
```json
{
  "success": true,
  "data": { /* actual data */ },
  "message": "Success message",
  "timestamp": "2026-01-30T10:15:00Z",
  "errors": []
}
```

---

## 🌐 Service Ports

| Service | Port | Health Check |
|---------|------|--------------|
| API Gateway | 8080 | http://localhost:8080/api/v1/kitchens |
| Auth Service | 8081 | http://localhost:8081/swagger-ui.html |
| Kitchen Service | 8082 | http://localhost:8082/swagger-ui.html |
| Menu Service | 8083 | http://localhost:8083/swagger-ui.html |
| Order Service | 8084 | http://localhost:8084/swagger-ui.html |

---

## 🗄️ Database Credentials

```yaml
# Default Config
Host: localhost
Port: 3306
Username: root
Password: root

# Databases
- makan_auth_db (Auth Service)
- makan_kitchen_db (Kitchen Service)
- makan_menu_db (Menu Service)
- makan_order_db (Order Service)
```

---

## 📊 Example Workflow

### 1. User Registration
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Priya",
    "lastName": "Kumar",
    "email": "priya@example.com",
    "phoneNumber": "9876543210",
    "password": "SecurePass123",
    "role": "KITCHEN"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "user": {
      "id": 1,
      "email": "priya@example.com",
      "role": "KITCHEN"
    }
  }
}
```

### 2. Register Kitchen
```bash
curl -X POST http://localhost:8080/api/v1/kitchens/register \
  -H "Authorization: Bearer {accessToken}" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "kitchenName": "Priya'\''s Kitchen",
    "address": "123 Main St, Apt 4",
    "city": "New York",
    "ownerContact": "9876543210",
    "ownerEmail": "priya@example.com",
    "cuisineTypes": "Indian,Continental"
  }'
```

### 3. Admin Approves Kitchen
```bash
curl -X PATCH http://localhost:8080/api/v1/kitchens/1/approve \
  -H "Authorization: Bearer {adminToken}"
```

### 4. Create Menu Items
```bash
curl -X POST http://localhost:8080/api/v1/menu-items \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "itemName": "Chicken Biryani",
    "description": "Authentic Hyderabadi biryani",
    "cost": 12.99,
    "isVeg": false,
    "isHalal": true,
    "spicyLevel": 4,
    "labelIds": [1, 2]
  }'
```

### 5. Customer Searches & Orders
```bash
# Search
curl "http://localhost:8080/api/v1/menu-items/search?query=biryani&halal=true"

# Create Order
curl -X POST http://localhost:8080/api/v1/orders \
  -H "Authorization: Bearer {customerToken}" \
  -H "X-User-Id: 2" \
  -H "Content-Type: application/json" \
  -d '{
    "kitchenId": 1,
    "deliveryAddress": "456 Oak Ave",
    "items": [{"itemId": 1, "quantity": 2}]
  }'
```

### 6. Kitchen Accepts Order
```bash
curl -X PATCH http://localhost:8080/api/v1/orders/1/accept \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 1"
```

---

## 🔧 Configuration Files

### Important Locations
- **Auth Service**: `auth-service/src/main/resources/application.yml`
- **Kitchen Service**: `kitchen-service/src/main/resources/application.yml`
- **Menu Service**: `menu-service/src/main/resources/application.yml`
- **Order Service**: `order-service/src/main/resources/application.yml`
- **API Gateway**: `api-gateway/src/main/resources/application.yml`

### Update Credentials
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/makan_[service]_db
    username: root
    password: root

jwt:
  secret: your_jwt_secret_key
```

---

## 🐛 Debugging

### View Service Logs
```bash
# Auth Service logs
tail -f auth-service.log

# Gateway logs (contains request routing info)
tail -f api-gateway.log
```

### Test Database Connection
```bash
mysql -h localhost -u root -p makan_auth_db -e "SELECT 1;"
```

### Test Service Health
```bash
curl http://localhost:8081/swagger-ui.html
curl http://localhost:8082/swagger-ui.html
curl http://localhost:8083/swagger-ui.html
curl http://localhost:8084/swagger-ui.html
```

### Check Open Ports
```bash
# Linux/Mac
lsof -i :8080
lsof -i :8081

# Windows
netstat -ano | findstr :8080
```

---

## 📱 Flutter Integration

### Headers Required
```javascript
// After login, store both tokens
String accessToken = response.data['data']['accessToken'];
String userId = response.data['data']['user']['id'];

// For all protected requests
headers: {
  'Authorization': 'Bearer $accessToken',
  'X-User-Id': '$userId',
  'Content-Type': 'application/json'
}

// Refresh token when expired
POST /api/v1/auth/refresh
Body: { "refreshToken": storedRefreshToken }
```

### Handle Responses
```javascript
if (response.statusCode == 200 && response.data['success'] == true) {
  // Extract data from response.data['data']
  final data = response.data['data'];
} else {
  // Show error from response.data['message']
  String error = response.data['message'];
}
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Project overview and getting started |
| `API_DOCUMENTATION.md` | Complete API reference |
| `SETUP_AND_DEPLOYMENT.md` | Installation and deployment guide |
| `TROUBLESHOOTING.md` | Common issues and solutions |
| `DELIVERABLES.md` | Complete deliverables checklist |
| `database_schema.sql` | Database structure |
| `QUICK_REFERENCE.md` | This file - quick reference |

---

## ⚡ Pro Tips

1. **Use Swagger UI for testing**: http://localhost:8080/swagger-ui.html
2. **Keep tokens in Postman**: Use environment variables for easy switching
3. **Save common requests**: In Postman collections for quick access
4. **Enable SQL logging**: For database query debugging
5. **Check Redis**: `redis-cli keys '*'` to see cached items
6. **Watch logs in real-time**: Keep terminal windows visible
7. **Use Insomnia or Postman**: Better than cURL for testing
8. **Test pagination**: Add `?page=0&size=5` to list endpoints

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 8080 in use | Kill process: `kill -9 <PID>` or change port in application.yml |
| Can't connect to MySQL | Start MySQL: `sudo systemctl start mysql` |
| JWT invalid | Re-login to get new token |
| Empty search results | Create menu items first, wait for Redis cache |
| 404 errors | Check endpoint path (case-sensitive) and service status |
| 400 validation error | Check required fields and data types |

---

## 📞 Support

- **Docs**: README.md, API_DOCUMENTATION.md
- **Setup Help**: SETUP_AND_DEPLOYMENT.md
- **Issues**: TROUBLESHOOTING.md
- **API Examples**: This file

**Everything is documented. Start with README.md!**

---

**Last Updated**: January 30, 2026
**Status**: Production Ready ✅
