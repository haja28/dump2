# Menu Management API - Complete Examples

## 1. Create Menu Item
**Endpoint**: `POST /api/v1/menu-items`

### cURL Request
```bash
curl -X POST http://localhost:8080/api/v1/menu-items \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Kitchen-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "itemName": "Chicken Biryani",
    "description": "Authentic Hyderabadi biryani with fragrant rice and tender chicken",
    "cost": 12.99,
    "isVeg": false,
    "isHalal": true,
    "spicyLevel": 4,
    "labelIds": [1, 2]
  }'
```

### Request Body
```json
{
  "itemName": "Paneer Tikka Masala",
  "description": "Creamy tomato-based curry with paneer cubes",
  "cost": 10.50,
  "isVeg": true,
  "isHalal": false,
  "spicyLevel": 3,
  "labelIds": [1, 3, 4]
}
```

### Response (Success - 201)
```json
{
  "success": true,
  "data": {
    "id": 5,
    "itemName": "Paneer Tikka Masala",
    "description": "Creamy tomato-based curry with paneer cubes",
    "cost": 10.50,
    "isVeg": true,
    "isHalal": false,
    "spicyLevel": 3,
    "kitchenId": 1,
    "labels": [
      {
        "id": 1,
        "name": "vegan"
      },
      {
        "id": 3,
        "name": "dairy-free"
      },
      {
        "id": 4,
        "name": "gluten-free"
      }
    ],
    "createdAt": "2026-02-05T10:30:00Z",
    "updatedAt": "2026-02-05T10:30:00Z"
  },
  "message": "Menu item created successfully",
  "timestamp": "2026-02-05T10:30:00Z",
  "errors": []
}
```

### Response (Validation Error - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Validation failed",
  "timestamp": "2026-02-05T10:30:00Z",
  "errors": [
    "itemName is required",
    "cost must be greater than 0",
    "spicyLevel must be between 1 and 5"
  ]
}
```

### Response (Unauthorized - 401)
```json
{
  "success": false,
  "data": null,
  "message": "Unauthorized - Invalid token",
  "timestamp": "2026-02-05T10:30:00Z",
  "errors": [
    "Authorization header is missing or invalid"
  ]
}
```

---

## 2. Advanced Search Menu Items
**Endpoint**: `GET /api/v1/menu-items/search`

### Example 1: Search with all filters
```bash
curl -X GET "http://localhost:8080/api/v1/menu-items/search?query=biryani&minPrice=10&maxPrice=20&veg=false&halal=true&labels=spicy,homemade&sort=rating_desc&page=0&size=10" \
  -H "Content-Type: application/json"
```

### Example 2: Simple keyword search
```bash
curl -X GET "http://localhost:8080/api/v1/menu-items/search?query=paneer&sort=newest" \
  -H "Content-Type: application/json"
```

### Example 3: Price range and dietary filters
```bash
curl -X GET "http://localhost:8080/api/v1/menu-items/search?minPrice=5&maxPrice=15&veg=true&page=0&size=20" \
  -H "Content-Type: application/json"
```

### Example 4: Filter by kitchen and spice level
```bash
curl -X GET "http://localhost:8080/api/v1/menu-items/search?kitchenId=2&minSpicyLevel=3&maxSpicyLevel=5&sort=price_asc" \
  -H "Content-Type: application/json"
```

### Query Parameters
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| query | string | Full-text search on names and descriptions | `query=biryani` |
| kitchenId | integer | Filter by specific kitchen | `kitchenId=1` |
| minPrice | decimal | Minimum price | `minPrice=5` |
| maxPrice | decimal | Maximum price | `maxPrice=20` |
| veg | boolean | Vegetarian items only | `veg=true` |
| halal | boolean | Halal items only | `halal=true` |
| minSpicyLevel | integer | Minimum spice level (1-5) | `minSpicyLevel=2` |
| maxSpicyLevel | integer | Maximum spice level (1-5) | `maxSpicyLevel=4` |
| labels | string | Comma-separated label names | `labels=vegan,spicy,homemade` |
| sort | string | Sort order | `sort=rating_desc` |
| page | integer | Page number (0-indexed) | `page=0` |
| size | integer | Page size | `size=10` |

### Sort Options
- `rating_desc` - Highest rated first
- `rating_asc` - Lowest rated first
- `price_asc` - Cheapest first
- `price_desc` - Most expensive first
- `newest` - Recently added first
- `oldest` - Oldest first

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "itemName": "Chicken Biryani",
        "description": "Authentic Hyderabadi biryani",
        "cost": 12.99,
        "isVeg": false,
        "isHalal": true,
        "spicyLevel": 4,
        "rating": 4.5,
        "ratingCount": 120,
        "kitchenId": 1,
        "kitchenName": "Priya's Kitchen",
        "labels": [
          {
            "id": 2,
            "name": "spicy"
          },
          {
            "id": 5,
            "name": "homemade"
          }
        ],
        "createdAt": "2026-01-15T08:00:00Z",
        "updatedAt": "2026-02-03T14:20:00Z"
      },
      {
        "id": 8,
        "itemName": "Mutton Biryani",
        "description": "Traditional mutton biryani with basmati rice",
        "cost": 15.50,
        "isVeg": false,
        "isHalal": true,
        "spicyLevel": 5,
        "rating": 4.7,
        "ratingCount": 85,
        "kitchenId": 3,
        "kitchenName": "Hassan's Kitchen",
        "labels": [
          {
            "id": 2,
            "name": "spicy"
          },
          {
            "id": 5,
            "name": "homemade"
          }
        ],
        "createdAt": "2026-01-20T09:30:00Z",
        "updatedAt": "2026-02-04T11:15:00Z"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "totalElements": 2,
      "totalPages": 1
    }
  },
  "message": "Menu items found",
  "timestamp": "2026-02-05T10:35:00Z",
  "errors": []
}
```

### Response (No Results - 200)
```json
{
  "success": true,
  "data": {
    "content": [],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "totalElements": 0,
      "totalPages": 0
    }
  },
  "message": "No menu items found matching criteria",
  "timestamp": "2026-02-05T10:35:00Z",
  "errors": []
}
```

---

## 3. Get Kitchen Menu
**Endpoint**: `GET /api/v1/menu-items/kitchen/{kitchenId}`

### cURL Request
```bash
curl -X GET "http://localhost:8080/api/v1/menu-items/kitchen/1?page=0&size=20" \
  -H "Content-Type: application/json"
```

### Query Parameters
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| kitchenId | integer | Kitchen ID (in URL) | Required |
| page | integer | Page number (0-indexed) | 0 |
| size | integer | Page size | 20 |

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "kitchenId": 1,
    "kitchenName": "Priya's Kitchen",
    "items": [
      {
        "id": 1,
        "itemName": "Chicken Biryani",
        "description": "Authentic Hyderabadi biryani with fragrant rice and tender chicken",
        "cost": 12.99,
        "isVeg": false,
        "isHalal": true,
        "spicyLevel": 4,
        "rating": 4.5,
        "ratingCount": 120,
        "labels": [
          {
            "id": 2,
            "name": "spicy"
          },
          {
            "id": 5,
            "name": "homemade"
          }
        ],
        "createdAt": "2026-01-15T08:00:00Z",
        "updatedAt": "2026-02-03T14:20:00Z"
      },
      {
        "id": 5,
        "itemName": "Paneer Tikka Masala",
        "description": "Creamy tomato-based curry with paneer cubes",
        "cost": 10.50,
        "isVeg": true,
        "isHalal": false,
        "spicyLevel": 3,
        "rating": 4.3,
        "ratingCount": 95,
        "labels": [
          {
            "id": 1,
            "name": "vegan"
          },
          {
            "id": 3,
            "name": "dairy-free"
          }
        ],
        "createdAt": "2026-01-20T10:15:00Z",
        "updatedAt": "2026-02-02T16:45:00Z"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20,
      "totalElements": 2,
      "totalPages": 1
    }
  },
  "message": "Kitchen menu retrieved successfully",
  "timestamp": "2026-02-05T10:40:00Z",
  "errors": []
}
```

### Response (Kitchen Not Found - 404)
```json
{
  "success": false,
  "data": null,
  "message": "Kitchen not found",
  "timestamp": "2026-02-05T10:40:00Z",
  "errors": [
    "Kitchen with ID 999 does not exist"
  ]
}
```

---

## 4. Create Label (Admin Only)
**Endpoint**: `POST /api/v1/menu-labels`

### cURL Request
```bash
curl -X POST "http://localhost:8080/api/v1/menu-labels?name=vegan&description=Vegan%20friendly" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

### Query Parameters
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| name | string | Label name | Yes |
| description | string | Label description | No |

### Examples with Different Labels

**Example 1: Dietary Label**
```bash
curl -X POST "http://localhost:8080/api/v1/menu-labels?name=gluten-free&description=Free%20from%20gluten" \
  -H "Authorization: Bearer {adminToken}" \
  -H "Content-Type: application/json"
```

**Example 2: Cuisine Label**
```bash
curl -X POST "http://localhost:8080/api/v1/menu-labels?name=organic&description=Organic%20ingredients%20used" \
  -H "Authorization: Bearer {adminToken}" \
  -H "Content-Type: application/json"
```

**Example 3: Preparation Label**
```bash
curl -X POST "http://localhost:8080/api/v1/menu-labels?name=low-calorie&description=Low%20calorie%20option" \
  -H "Authorization: Bearer {adminToken}" \
  -H "Content-Type: application/json"
```

### Response (Success - 201)
```json
{
  "success": true,
  "data": {
    "id": 6,
    "name": "vegan",
    "description": "Vegan friendly",
    "createdAt": "2026-02-05T10:45:00Z",
    "updatedAt": "2026-02-05T10:45:00Z"
  },
  "message": "Label created successfully",
  "timestamp": "2026-02-05T10:45:00Z",
  "errors": []
}
```

### Response (Unauthorized - 403)
```json
{
  "success": false,
  "data": null,
  "message": "Access denied - Admin role required",
  "timestamp": "2026-02-05T10:45:00Z",
  "errors": [
    "User must have ADMIN role to create labels"
  ]
}
```

### Response (Duplicate Label - 409)
```json
{
  "success": false,
  "data": null,
  "message": "Label already exists",
  "timestamp": "2026-02-05T10:45:00Z",
  "errors": [
    "Label 'vegan' already exists in the system"
  ]
}
```

---

## 5. List All Labels
**Endpoint**: `GET /api/v1/menu-labels`

### cURL Request
```bash
curl -X GET "http://localhost:8080/api/v1/menu-labels" \
  -H "Content-Type: application/json"
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "vegan",
      "description": "Vegan friendly",
      "createdAt": "2026-01-10T08:00:00Z",
      "updatedAt": "2026-01-10T08:00:00Z"
    },
    {
      "id": 2,
      "name": "spicy",
      "description": "Spicy dish",
      "createdAt": "2026-01-10T08:05:00Z",
      "updatedAt": "2026-01-10T08:05:00Z"
    },
    {
      "id": 3,
      "name": "dairy-free",
      "description": "No dairy products",
      "createdAt": "2026-01-10T08:10:00Z",
      "updatedAt": "2026-01-10T08:10:00Z"
    },
    {
      "id": 4,
      "name": "gluten-free",
      "description": "Free from gluten",
      "createdAt": "2026-01-10T08:15:00Z",
      "updatedAt": "2026-01-10T08:15:00Z"
    },
    {
      "id": 5,
      "name": "homemade",
      "description": "Made with homemade recipe",
      "createdAt": "2026-01-10T08:20:00Z",
      "updatedAt": "2026-01-10T08:20:00Z"
    },
    {
      "id": 6,
      "name": "organic",
      "description": "Organic ingredients used",
      "createdAt": "2026-02-05T10:45:00Z",
      "updatedAt": "2026-02-05T10:45:00Z"
    }
  ],
  "message": "Labels retrieved successfully",
  "timestamp": "2026-02-05T10:50:00Z",
  "errors": []
}
```

### Response (Empty List - 200)
```json
{
  "success": true,
  "data": [],
  "message": "No labels found",
  "timestamp": "2026-02-05T10:50:00Z",
  "errors": []
}
```

---

## Postman Collection Template

You can import this JSON into Postman:

```json
{
  "info": {
    "name": "Menu Management APIs",
    "description": "Collection for Menu Management endpoints"
  },
  "item": [
    {
      "name": "Create Menu Item",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{kitchenToken}}",
            "type": "text"
          },
          {
            "key": "X-Kitchen-Id",
            "value": "{{kitchenId}}",
            "type": "text"
          },
          {
            "key": "Content-Type",
            "value": "application/json",
            "type": "text"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"itemName\": \"Chicken Biryani\",\n  \"description\": \"Authentic Hyderabadi biryani with fragrant rice and tender chicken\",\n  \"cost\": 12.99,\n  \"isVeg\": false,\n  \"isHalal\": true,\n  \"spicyLevel\": 4,\n  \"labelIds\": [1, 2]\n}"
        },
        "url": {
          "raw": "http://localhost:8080/api/v1/menu-items",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "v1", "menu-items"]
        }
      }
    },
    {
      "name": "Search Menu Items",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json",
            "type": "text"
          }
        ],
        "url": {
          "raw": "http://localhost:8080/api/v1/menu-items/search?query=biryani&minPrice=10&maxPrice=20&veg=false&halal=true&labels=spicy,homemade&sort=rating_desc&page=0&size=10",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "v1", "menu-items", "search"],
          "query": [
            {
              "key": "query",
              "value": "biryani"
            },
            {
              "key": "minPrice",
              "value": "10"
            },
            {
              "key": "maxPrice",
              "value": "20"
            },
            {
              "key": "veg",
              "value": "false"
            },
            {
              "key": "halal",
              "value": "true"
            },
            {
              "key": "labels",
              "value": "spicy,homemade"
            },
            {
              "key": "sort",
              "value": "rating_desc"
            },
            {
              "key": "page",
              "value": "0"
            },
            {
              "key": "size",
              "value": "10"
            }
          ]
        }
      }
    },
    {
      "name": "Get Kitchen Menu",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json",
            "type": "text"
          }
        ],
        "url": {
          "raw": "http://localhost:8080/api/v1/menu-items/kitchen/1?page=0&size=20",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "v1", "menu-items", "kitchen", "1"],
          "query": [
            {
              "key": "page",
              "value": "0"
            },
            {
              "key": "size",
              "value": "20"
            }
          ]
        }
      }
    },
    {
      "name": "Create Label",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{adminToken}}",
            "type": "text"
          },
          {
            "key": "Content-Type",
            "value": "application/json",
            "type": "text"
          }
        ],
        "url": {
          "raw": "http://localhost:8080/api/v1/menu-labels?name=vegan&description=Vegan friendly",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "v1", "menu-labels"],
          "query": [
            {
              "key": "name",
              "value": "vegan"
            },
            {
              "key": "description",
              "value": "Vegan friendly"
            }
          ]
        }
      }
    },
    {
      "name": "List All Labels",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json",
            "type": "text"
          }
        ],
        "url": {
          "raw": "http://localhost:8080/api/v1/menu-labels",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "v1", "menu-labels"]
        }
      }
    }
  ]
}
```

---

## Testing Workflow

### 1. Setup (One-time)
```bash
# Get admin token
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"AdminPass123"}'

# Get kitchen token
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"kitchen@example.com","password":"KitchenPass123"}'
```

### 2. Create Labels (Admin)
```bash
# Create several labels
curl -X POST "http://localhost:8080/api/v1/menu-labels?name=spicy&description=Spicy%20dish" \
  -H "Authorization: Bearer {adminToken}"

curl -X POST "http://localhost:8080/api/v1/menu-labels?name=vegan&description=Vegan%20friendly" \
  -H "Authorization: Bearer {adminToken}"

curl -X POST "http://localhost:8080/api/v1/menu-labels?name=homemade&description=Made%20with%20homemade%20recipe" \
  -H "Authorization: Bearer {adminToken}"
```

### 3. Create Menu Items (Kitchen)
```bash
# Create menu item 1
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
    "labelIds": [1, 3]
  }'

# Create menu item 2
curl -X POST http://localhost:8080/api/v1/menu-items \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "itemName": "Paneer Tikka Masala",
    "description": "Creamy tomato-based curry with paneer",
    "cost": 10.50,
    "isVeg": true,
    "isHalal": false,
    "spicyLevel": 3,
    "labelIds": [2]
  }'
```

### 4. Search Menu Items (Customer/Public)
```bash
# Search biryani
curl "http://localhost:8080/api/v1/menu-items/search?query=biryani&sort=rating_desc"

# Search vegetarian items under $15
curl "http://localhost:8080/api/v1/menu-items/search?veg=true&maxPrice=15&sort=price_asc"

# Search spicy items
curl "http://localhost:8080/api/v1/menu-items/search?labels=spicy&minSpicyLevel=3"
```

### 5. Get Kitchen Menu
```bash
curl "http://localhost:8080/api/v1/menu-items/kitchen/1?page=0&size=20"
```

### 6. List Labels
```bash
curl "http://localhost:8080/api/v1/menu-labels"
```

---

## Key Points

### Headers Required
- **Authorization**: Required for Create Menu Item and Create Label
  - Format: `Bearer {token}`
  - Token must be valid JWT from login
- **X-Kitchen-Id**: Required for Create Menu Item
  - Must match the kitchen ID of the kitchen user
  - If mismatch, request will be rejected

### Validation Rules
- **itemName**: Required, max 255 characters
- **description**: Optional, max 1000 characters
- **cost**: Required, must be > 0
- **isVeg**: Required boolean
- **isHalal**: Required boolean
- **spicyLevel**: Optional, must be 1-5 if provided
- **labelIds**: Optional array of valid label IDs

### Response Format
All responses follow this structure:
```json
{
  "success": boolean,
  "data": object/array/null,
  "message": string,
  "timestamp": ISO-8601 datetime,
  "errors": array of error strings
}
```

### Pagination
- Default page size: 10-20
- Page is 0-indexed
- Response includes `totalElements` and `totalPages`

---

**Last Updated**: February 5, 2026
