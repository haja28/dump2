# Order & Cart Management API - Complete Documentation

This document provides comprehensive API documentation for Order Management and Cart Management endpoints with complete request/response examples.

> **Implementation Status**: ✅ Both Cart and Order APIs are fully implemented in `order-service`.

---

## Table of Contents
1. [Cart Management API](#cart-management-api)
   - [Get Cart](#1-get-cart)
   - [Add Item to Cart](#2-add-item-to-cart)
   - [Update Cart Item Quantity](#3-update-cart-item-quantity)
   - [Remove Item from Cart](#4-remove-item-from-cart)
   - [Clear Cart](#5-clear-cart)
   - [Apply Coupon](#6-apply-coupon)
2. [Order Management API](#order-management-api)
   - [Create Order](#7-create-order)
   - [Get Order by ID](#8-get-order-by-id)
   - [Get My Orders](#9-get-my-orders-customer)
   - [Get Kitchen Orders](#10-get-kitchen-orders)
   - [Get Kitchen Pending Orders](#11-get-kitchen-pending-orders)
   - [Accept Order](#12-accept-order-kitchen)
   - [Update Order Status](#13-update-order-status)
   - [Cancel Order](#14-cancel-order)
3. [Order Status Flow](#order-status-flow)
4. [Postman Collection](#postman-collection)
5. [Testing Workflow](#testing-workflow)

---

# Cart Management API

Base URL: `http://localhost:8080/api/v1/cart`

## 1. Get Cart
**Endpoint**: `GET /api/v1/cart`

Retrieves the current user's shopping cart.

### cURL Request
```bash
curl -X GET "http://localhost:8080/api/v1/cart" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json"
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "cartId": 123,
    "userId": 1,
    "kitchenId": 5,
    "kitchenName": "Priya's Kitchen",
    "items": [
      {
        "cartItemId": 1,
        "itemId": 10,
        "itemName": "Chicken Biryani",
        "itemDescription": "Authentic Hyderabadi biryani",
        "quantity": 2,
        "unitPrice": 12.99,
        "totalPrice": 25.98,
        "specialRequests": "Extra spicy",
        "imageUrl": "https://cdn.example.com/images/biryani.jpg"
      },
      {
        "cartItemId": 2,
        "itemId": 15,
        "itemName": "Paneer Tikka Masala",
        "itemDescription": "Creamy tomato-based curry",
        "quantity": 1,
        "unitPrice": 10.50,
        "totalPrice": 10.50,
        "specialRequests": null,
        "imageUrl": "https://cdn.example.com/images/paneer.jpg"
      }
    ],
    "subtotal": 36.48,
    "deliveryFee": 3.00,
    "discount": 0.00,
    "couponCode": null,
    "total": 39.48,
    "itemCount": 3,
    "createdAt": "2026-02-09T08:00:00Z",
    "updatedAt": "2026-02-09T10:30:00Z"
  },
  "message": "Cart retrieved successfully",
  "timestamp": "2026-02-09T10:35:00Z",
  "errors": []
}
```

### Response (Empty Cart - 200)
```json
{
  "success": true,
  "data": {
    "cartId": null,
    "userId": 1,
    "kitchenId": null,
    "kitchenName": null,
    "items": [],
    "subtotal": 0.00,
    "deliveryFee": 0.00,
    "discount": 0.00,
    "couponCode": null,
    "total": 0.00,
    "itemCount": 0,
    "createdAt": null,
    "updatedAt": null
  },
  "message": "Cart is empty",
  "timestamp": "2026-02-09T10:35:00Z",
  "errors": []
}
```

---

## 2. Add Item to Cart
**Endpoint**: `POST /api/v1/cart/items`

Adds a menu item to the cart. If cart is empty, creates new cart with the kitchen. If cart already has items from a different kitchen, returns error.

### cURL Request
```bash
curl -X POST "http://localhost:8080/api/v1/cart/items" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "itemId": 10,
    "quantity": 2,
    "specialRequests": "Extra spicy"
  }'
```

### Request Body
```json
{
  "itemId": 10,
  "quantity": 2,
  "specialRequests": "Extra spicy"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| itemId | Long | Yes | Menu item ID |
| quantity | Integer | Yes | Quantity (min: 1) |
| specialRequests | String | No | Special requests/notes |

### Response (Success - 201)
```json
{
  "success": true,
  "data": {
    "cartId": 123,
    "userId": 1,
    "kitchenId": 5,
    "kitchenName": "Priya's Kitchen",
    "items": [
      {
        "cartItemId": 1,
        "itemId": 10,
        "itemName": "Chicken Biryani",
        "itemDescription": "Authentic Hyderabadi biryani",
        "quantity": 2,
        "unitPrice": 12.99,
        "totalPrice": 25.98,
        "specialRequests": "Extra spicy",
        "imageUrl": "https://cdn.example.com/images/biryani.jpg"
      }
    ],
    "subtotal": 25.98,
    "deliveryFee": 3.00,
    "discount": 0.00,
    "couponCode": null,
    "total": 28.98,
    "itemCount": 2,
    "createdAt": "2026-02-09T10:30:00Z",
    "updatedAt": "2026-02-09T10:30:00Z"
  },
  "message": "Item added to cart",
  "timestamp": "2026-02-09T10:30:00Z",
  "errors": []
}
```

### Response (Different Kitchen Error - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Cannot add items from different kitchen",
  "timestamp": "2026-02-09T10:30:00Z",
  "errors": [
    "Your cart contains items from 'Priya's Kitchen'. Please clear your cart to order from a different kitchen."
  ]
}
```

### Response (Item Not Found - 404)
```json
{
  "success": false,
  "data": null,
  "message": "Item not found",
  "timestamp": "2026-02-09T10:30:00Z",
  "errors": [
    "Menu item with ID 999 does not exist"
  ]
}
```

### Response (Item Unavailable - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Item unavailable",
  "timestamp": "2026-02-09T10:30:00Z",
  "errors": [
    "This item is currently not available for ordering"
  ]
}
```

---

## 3. Update Cart Item Quantity
**Endpoint**: `PUT /api/v1/cart/items/{cartItemId}`

Updates the quantity of an item in the cart.

### cURL Request
```bash
curl -X PUT "http://localhost:8080/api/v1/cart/items/1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 3,
    "specialRequests": "No onions"
  }'
```

### Request Body
```json
{
  "quantity": 3,
  "specialRequests": "No onions"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| quantity | Integer | Yes | New quantity (min: 1) |
| specialRequests | String | No | Updated special requests |

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "cartId": 123,
    "userId": 1,
    "kitchenId": 5,
    "kitchenName": "Priya's Kitchen",
    "items": [
      {
        "cartItemId": 1,
        "itemId": 10,
        "itemName": "Chicken Biryani",
        "itemDescription": "Authentic Hyderabadi biryani",
        "quantity": 3,
        "unitPrice": 12.99,
        "totalPrice": 38.97,
        "specialRequests": "No onions",
        "imageUrl": "https://cdn.example.com/images/biryani.jpg"
      }
    ],
    "subtotal": 38.97,
    "deliveryFee": 3.00,
    "discount": 0.00,
    "couponCode": null,
    "total": 41.97,
    "itemCount": 3,
    "createdAt": "2026-02-09T08:00:00Z",
    "updatedAt": "2026-02-09T10:35:00Z"
  },
  "message": "Cart item updated",
  "timestamp": "2026-02-09T10:35:00Z",
  "errors": []
}
```

### Response (Item Not Found - 404)
```json
{
  "success": false,
  "data": null,
  "message": "Cart item not found",
  "timestamp": "2026-02-09T10:35:00Z",
  "errors": [
    "Cart item with ID 999 does not exist in your cart"
  ]
}
```

---

## 4. Remove Item from Cart
**Endpoint**: `DELETE /api/v1/cart/items/{cartItemId}`

Removes an item from the cart.

### cURL Request
```bash
curl -X DELETE "http://localhost:8080/api/v1/cart/items/1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json"
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "cartId": 123,
    "userId": 1,
    "kitchenId": 5,
    "kitchenName": "Priya's Kitchen",
    "items": [
      {
        "cartItemId": 2,
        "itemId": 15,
        "itemName": "Paneer Tikka Masala",
        "quantity": 1,
        "unitPrice": 10.50,
        "totalPrice": 10.50
      }
    ],
    "subtotal": 10.50,
    "deliveryFee": 3.00,
    "discount": 0.00,
    "total": 13.50,
    "itemCount": 1
  },
  "message": "Item removed from cart",
  "timestamp": "2026-02-09T10:40:00Z",
  "errors": []
}
```

---

## 5. Clear Cart
**Endpoint**: `DELETE /api/v1/cart`

Clears all items from the cart.

### cURL Request
```bash
curl -X DELETE "http://localhost:8080/api/v1/cart" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json"
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": null,
  "message": "Cart cleared successfully",
  "timestamp": "2026-02-09T10:45:00Z",
  "errors": []
}
```

---

## 6. Apply Coupon
**Endpoint**: `POST /api/v1/cart/coupon`

Applies a coupon code to the cart.

### cURL Request
```bash
curl -X POST "http://localhost:8080/api/v1/cart/coupon" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "couponCode": "SAVE10"
  }'
```

### Request Body
```json
{
  "couponCode": "SAVE10"
}
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "cartId": 123,
    "userId": 1,
    "kitchenId": 5,
    "items": [...],
    "subtotal": 36.48,
    "deliveryFee": 3.00,
    "discount": 3.65,
    "couponCode": "SAVE10",
    "couponDescription": "10% off your order",
    "total": 35.83,
    "itemCount": 3
  },
  "message": "Coupon applied successfully",
  "timestamp": "2026-02-09T10:50:00Z",
  "errors": []
}
```

### Response (Invalid Coupon - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Invalid coupon",
  "timestamp": "2026-02-09T10:50:00Z",
  "errors": [
    "Coupon code 'INVALID123' is not valid or has expired"
  ]
}
```

### Response (Minimum Order Not Met - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Minimum order not met",
  "timestamp": "2026-02-09T10:50:00Z",
  "errors": [
    "This coupon requires a minimum order of $50.00"
  ]
}
```

### Remove Coupon
**Endpoint**: `DELETE /api/v1/cart/coupon`

```bash
curl -X DELETE "http://localhost:8080/api/v1/cart/coupon" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1"
```

---

# Order Management API

Base URL: `http://localhost:8080/api/v1/orders`

## 7. Create Order
**Endpoint**: `POST /api/v1/orders`

Creates a new order from cart items or directly with order details.

### cURL Request (Direct Order)
```bash
curl -X POST "http://localhost:8080/api/v1/orders" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "kitchenId": 5,
    "deliveryAddress": "123 Main Street, Apt 4B",
    "deliveryCity": "Kuala Lumpur",
    "deliveryState": "Wilayah Persekutuan",
    "deliveryPostalCode": "50000",
    "specialInstructions": "Please call when you arrive",
    "items": [
      {
        "itemId": 10,
        "quantity": 2,
        "specialRequests": "Extra spicy"
      },
      {
        "itemId": 15,
        "quantity": 1,
        "specialRequests": null
      }
    ]
  }'
```

### Request Body
```json
{
  "kitchenId": 5,
  "deliveryAddress": "123 Main Street, Apt 4B",
  "deliveryCity": "Kuala Lumpur",
  "deliveryState": "Wilayah Persekutuan",
  "deliveryPostalCode": "50000",
  "specialInstructions": "Please call when you arrive",
  "items": [
    {
      "itemId": 10,
      "quantity": 2,
      "specialRequests": "Extra spicy"
    },
    {
      "itemId": 15,
      "quantity": 1,
      "specialRequests": null
    }
  ]
}
```

### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| kitchenId | Long | Yes | Kitchen ID |
| deliveryAddress | String | Yes | Delivery address (5-255 chars) |
| deliveryCity | String | No | City (max 50 chars) |
| deliveryState | String | No | State (max 50 chars) |
| deliveryPostalCode | String | No | Postal code (max 10 chars) |
| specialInstructions | String | No | Special instructions (max 500 chars) |
| items | Array | Yes | Order items (at least 1) |
| items[].itemId | Long | Yes | Menu item ID |
| items[].quantity | Integer | Yes | Quantity (min: 1) |
| items[].specialRequests | String | No | Special requests for item |

### Response (Success - 201)
```json
{
  "success": true,
  "data": {
    "id": 1001,
    "userId": 1,
    "kitchenId": 5,
    "orderTotal": 36.48,
    "orderStatus": "PENDING",
    "confirmationByKitchen": false,
    "confirmationTimestamp": null,
    "deliveryAddress": "123 Main Street, Apt 4B",
    "deliveryCity": "Kuala Lumpur",
    "deliveryState": "Wilayah Persekutuan",
    "deliveryPostalCode": "50000",
    "specialInstructions": "Please call when you arrive",
    "items": [
      {
        "id": 1,
        "orderId": 1001,
        "itemId": 10,
        "itemQuantity": 2,
        "itemUnitPrice": 12.99,
        "itemTotal": 25.98,
        "specialRequests": "Extra spicy"
      },
      {
        "id": 2,
        "orderId": 1001,
        "itemId": 15,
        "itemQuantity": 1,
        "itemUnitPrice": 10.50,
        "itemTotal": 10.50,
        "specialRequests": null
      }
    ],
    "createdAt": "2026-02-09T11:00:00Z",
    "updatedAt": "2026-02-09T11:00:00Z"
  },
  "message": "Order created successfully",
  "timestamp": "2026-02-09T11:00:00Z",
  "errors": []
}
```

### Response (Validation Error - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Validation failed",
  "timestamp": "2026-02-09T11:00:00Z",
  "errors": [
    "Kitchen ID is required",
    "Delivery address is required",
    "Delivery address must be between 5 and 255 characters",
    "Order must contain at least one item"
  ]
}
```

### Response (Kitchen Not Found - 404)
```json
{
  "success": false,
  "data": null,
  "message": "Kitchen not found",
  "timestamp": "2026-02-09T11:00:00Z",
  "errors": [
    "Kitchen with ID 999 does not exist"
  ]
}
```

### Response (Kitchen Closed - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Kitchen unavailable",
  "timestamp": "2026-02-09T11:00:00Z",
  "errors": [
    "This kitchen is currently not accepting orders"
  ]
}
```

---

## 8. Get Order by ID
**Endpoint**: `GET /api/v1/orders/{orderId}`

Retrieves order details by order ID.

### cURL Request
```bash
curl -X GET "http://localhost:8080/api/v1/orders/1001" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "id": 1001,
    "userId": 1,
    "kitchenId": 5,
    "orderTotal": 36.48,
    "orderStatus": "CONFIRMED",
    "confirmationByKitchen": true,
    "confirmationTimestamp": "2026-02-09T11:05:00Z",
    "deliveryAddress": "123 Main Street, Apt 4B",
    "deliveryCity": "Kuala Lumpur",
    "deliveryState": "Wilayah Persekutuan",
    "deliveryPostalCode": "50000",
    "specialInstructions": "Please call when you arrive",
    "items": [
      {
        "id": 1,
        "orderId": 1001,
        "itemId": 10,
        "itemQuantity": 2,
        "itemUnitPrice": 12.99,
        "itemTotal": 25.98,
        "specialRequests": "Extra spicy"
      },
      {
        "id": 2,
        "orderId": 1001,
        "itemId": 15,
        "itemQuantity": 1,
        "itemUnitPrice": 10.50,
        "itemTotal": 10.50,
        "specialRequests": null
      }
    ],
    "createdAt": "2026-02-09T11:00:00Z",
    "updatedAt": "2026-02-09T11:05:00Z"
  },
  "message": null,
  "timestamp": "2026-02-09T11:10:00Z",
  "errors": []
}
```

### Response (Not Found - 404)
```json
{
  "success": false,
  "data": null,
  "message": "Order not found",
  "timestamp": "2026-02-09T11:10:00Z",
  "errors": [
    "Order with ID 9999 does not exist"
  ]
}
```

---

## 9. Get My Orders (Customer)
**Endpoint**: `GET /api/v1/orders/my-orders`

Retrieves the current user's order history with pagination.

### cURL Request
```bash
curl -X GET "http://localhost:8080/api/v1/orders/my-orders?page=0&size=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json"
```

### Query Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | Integer | 0 | Page number (0-indexed) |
| size | Integer | 10 | Page size |

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1001,
        "userId": 1,
        "kitchenId": 5,
        "orderTotal": 36.48,
        "orderStatus": "DELIVERED",
        "confirmationByKitchen": true,
        "confirmationTimestamp": "2026-02-08T12:00:00Z",
        "deliveryAddress": "123 Main Street, Apt 4B",
        "deliveryCity": "Kuala Lumpur",
        "deliveryState": "Wilayah Persekutuan",
        "deliveryPostalCode": "50000",
        "specialInstructions": null,
        "items": [
          {
            "id": 1,
            "orderId": 1001,
            "itemId": 10,
            "itemQuantity": 2,
            "itemUnitPrice": 12.99,
            "itemTotal": 25.98,
            "specialRequests": null
          }
        ],
        "createdAt": "2026-02-08T11:00:00Z",
        "updatedAt": "2026-02-08T13:30:00Z"
      },
      {
        "id": 1000,
        "userId": 1,
        "kitchenId": 3,
        "orderTotal": 22.50,
        "orderStatus": "DELIVERED",
        "confirmationByKitchen": true,
        "confirmationTimestamp": "2026-02-05T18:00:00Z",
        "deliveryAddress": "123 Main Street, Apt 4B",
        "deliveryCity": "Kuala Lumpur",
        "deliveryState": "Wilayah Persekutuan",
        "deliveryPostalCode": "50000",
        "specialInstructions": null,
        "items": [...],
        "createdAt": "2026-02-05T17:30:00Z",
        "updatedAt": "2026-02-05T19:00:00Z"
      }
    ],
    "pagination": {
      "page": 0,
      "size": 10,
      "totalElements": 15,
      "totalPages": 2,
      "hasNext": true,
      "hasPrevious": false
    }
  },
  "message": null,
  "timestamp": "2026-02-09T11:15:00Z",
  "errors": []
}
```

---

## 10. Get Kitchen Orders
**Endpoint**: `GET /api/v1/orders/kitchen/{kitchenId}`

Retrieves all orders for a specific kitchen.

### cURL Request
```bash
curl -X GET "http://localhost:8080/api/v1/orders/kitchen/5?page=0&size=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Kitchen-Id: 5" \
  -H "Content-Type: application/json"
```

### Query Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | Integer | 0 | Page number (0-indexed) |
| size | Integer | 10 | Page size |

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1005,
        "userId": 42,
        "kitchenId": 5,
        "orderTotal": 45.00,
        "orderStatus": "PENDING",
        "confirmationByKitchen": false,
        "confirmationTimestamp": null,
        "deliveryAddress": "456 Oak Avenue",
        "deliveryCity": "Petaling Jaya",
        "deliveryState": "Selangor",
        "deliveryPostalCode": "47800",
        "specialInstructions": "Ring doorbell twice",
        "items": [...],
        "createdAt": "2026-02-09T11:30:00Z",
        "updatedAt": "2026-02-09T11:30:00Z"
      },
      {
        "id": 1004,
        "userId": 38,
        "kitchenId": 5,
        "orderTotal": 28.75,
        "orderStatus": "PREPARING",
        "confirmationByKitchen": true,
        "confirmationTimestamp": "2026-02-09T11:15:00Z",
        "deliveryAddress": "789 Maple Road",
        "deliveryCity": "Kuala Lumpur",
        "deliveryState": "Wilayah Persekutuan",
        "deliveryPostalCode": "50100",
        "specialInstructions": null,
        "items": [...],
        "createdAt": "2026-02-09T11:00:00Z",
        "updatedAt": "2026-02-09T11:20:00Z"
      }
    ],
    "pagination": {
      "page": 0,
      "size": 10,
      "totalElements": 25,
      "totalPages": 3,
      "hasNext": true,
      "hasPrevious": false
    }
  },
  "message": null,
  "timestamp": "2026-02-09T11:35:00Z",
  "errors": []
}
```

---

## 11. Get Kitchen Pending Orders
**Endpoint**: `GET /api/v1/orders/kitchen/{kitchenId}/pending`

Retrieves only pending orders for a kitchen (orders waiting to be accepted).

### cURL Request
```bash
curl -X GET "http://localhost:8080/api/v1/orders/kitchen/5/pending?page=0&size=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Kitchen-Id: 5" \
  -H "Content-Type: application/json"
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1005,
        "userId": 42,
        "kitchenId": 5,
        "orderTotal": 45.00,
        "orderStatus": "PENDING",
        "confirmationByKitchen": false,
        "confirmationTimestamp": null,
        "deliveryAddress": "456 Oak Avenue",
        "deliveryCity": "Petaling Jaya",
        "deliveryState": "Selangor",
        "deliveryPostalCode": "47800",
        "specialInstructions": "Ring doorbell twice",
        "items": [
          {
            "id": 10,
            "orderId": 1005,
            "itemId": 10,
            "itemQuantity": 3,
            "itemUnitPrice": 12.99,
            "itemTotal": 38.97,
            "specialRequests": "No onions"
          }
        ],
        "createdAt": "2026-02-09T11:30:00Z",
        "updatedAt": "2026-02-09T11:30:00Z"
      }
    ],
    "pagination": {
      "page": 0,
      "size": 10,
      "totalElements": 3,
      "totalPages": 1,
      "hasNext": false,
      "hasPrevious": false
    }
  },
  "message": null,
  "timestamp": "2026-02-09T11:40:00Z",
  "errors": []
}
```

---

## 12. Accept Order (Kitchen)
**Endpoint**: `PATCH /api/v1/orders/{orderId}/accept`

Kitchen accepts a pending order.

### cURL Request
```bash
curl -X PATCH "http://localhost:8080/api/v1/orders/1005/accept" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Kitchen-Id: 5" \
  -H "Content-Type: application/json"
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "id": 1005,
    "userId": 42,
    "kitchenId": 5,
    "orderTotal": 45.00,
    "orderStatus": "CONFIRMED",
    "confirmationByKitchen": true,
    "confirmationTimestamp": "2026-02-09T11:45:00Z",
    "deliveryAddress": "456 Oak Avenue",
    "deliveryCity": "Petaling Jaya",
    "deliveryState": "Selangor",
    "deliveryPostalCode": "47800",
    "specialInstructions": "Ring doorbell twice",
    "items": [...],
    "createdAt": "2026-02-09T11:30:00Z",
    "updatedAt": "2026-02-09T11:45:00Z"
  },
  "message": "Order accepted successfully",
  "timestamp": "2026-02-09T11:45:00Z",
  "errors": []
}
```

### Response (Unauthorized - 403)
```json
{
  "success": false,
  "data": null,
  "message": "Unauthorized",
  "timestamp": "2026-02-09T11:45:00Z",
  "errors": [
    "Kitchen cannot accept this order"
  ]
}
```

### Response (Already Accepted - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Invalid order status",
  "timestamp": "2026-02-09T11:45:00Z",
  "errors": [
    "Order has already been accepted or is in a different status"
  ]
}
```

---

## 13. Update Order Status
**Endpoint**: `PATCH /api/v1/orders/{orderId}/status`

Updates the order status (for kitchen or delivery personnel).

### cURL Request
```bash
curl -X PATCH "http://localhost:8080/api/v1/orders/1005/status?status=PREPARING" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-Kitchen-Id: 5" \
  -H "Content-Type: application/json"
```

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| status | OrderStatus | Yes | New order status |

### Valid Status Values
| Status | Description |
|--------|-------------|
| `PENDING` | Order placed, waiting for kitchen confirmation |
| `CONFIRMED` | Kitchen has accepted the order |
| `PREPARING` | Kitchen is preparing the order |
| `READY` | Order is ready for pickup/delivery |
| `OUT_FOR_DELIVERY` | Order is being delivered |
| `DELIVERED` | Order has been delivered |
| `CANCELLED` | Order has been cancelled |

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "id": 1005,
    "userId": 42,
    "kitchenId": 5,
    "orderTotal": 45.00,
    "orderStatus": "PREPARING",
    "confirmationByKitchen": true,
    "confirmationTimestamp": "2026-02-09T11:45:00Z",
    "deliveryAddress": "456 Oak Avenue",
    "deliveryCity": "Petaling Jaya",
    "deliveryState": "Selangor",
    "deliveryPostalCode": "47800",
    "specialInstructions": "Ring doorbell twice",
    "items": [...],
    "createdAt": "2026-02-09T11:30:00Z",
    "updatedAt": "2026-02-09T11:50:00Z"
  },
  "message": "Order status updated successfully",
  "timestamp": "2026-02-09T11:50:00Z",
  "errors": []
}
```

### Response (Invalid Status Transition - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Invalid status transition",
  "timestamp": "2026-02-09T11:50:00Z",
  "errors": [
    "Cannot change status from PENDING to DELIVERED directly"
  ]
}
```

---

## 14. Cancel Order
**Endpoint**: `PATCH /api/v1/orders/{orderId}/cancel`

Cancels an order (only allowed for PENDING or CONFIRMED orders).

### cURL Request
```bash
curl -X PATCH "http://localhost:8080/api/v1/orders/1005/cancel" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "X-User-Id: 42" \
  -H "Content-Type: application/json"
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "id": 1005,
    "userId": 42,
    "kitchenId": 5,
    "orderTotal": 45.00,
    "orderStatus": "CANCELLED",
    "confirmationByKitchen": false,
    "confirmationTimestamp": null,
    "deliveryAddress": "456 Oak Avenue",
    "deliveryCity": "Petaling Jaya",
    "deliveryState": "Selangor",
    "deliveryPostalCode": "47800",
    "specialInstructions": "Ring doorbell twice",
    "items": [...],
    "createdAt": "2026-02-09T11:30:00Z",
    "updatedAt": "2026-02-09T11:55:00Z"
  },
  "message": "Order cancelled successfully",
  "timestamp": "2026-02-09T11:55:00Z",
  "errors": []
}
```

### Response (Cannot Cancel - 400)
```json
{
  "success": false,
  "data": null,
  "message": "Cannot cancel order",
  "timestamp": "2026-02-09T11:55:00Z",
  "errors": [
    "Cannot cancel order in OUT_FOR_DELIVERY status"
  ]
}
```

---

# Order Status Flow

```
┌─────────────┐
│   PENDING   │ ← Order created by customer
└──────┬──────┘
       │
       ▼ (Kitchen accepts)
┌─────────────┐
│  CONFIRMED  │
└──────┬──────┘
       │
       ▼ (Kitchen starts cooking)
┌─────────────┐
│  PREPARING  │
└──────┬──────┘
       │
       ▼ (Food is ready)
┌─────────────┐
│    READY    │
└──────┬──────┘
       │
       ▼ (Delivery person picks up)
┌──────────────────┐
│ OUT_FOR_DELIVERY │
└────────┬─────────┘
         │
         ▼ (Customer receives order)
┌─────────────┐
│  DELIVERED  │
└─────────────┘

         ╔═══════════════╗
         ║   CANCELLED   ║ ← Can cancel from PENDING or CONFIRMED
         ╚═══════════════╝
```

### Status Transition Rules
| From Status | Allowed Next Status |
|-------------|---------------------|
| PENDING | CONFIRMED, CANCELLED |
| CONFIRMED | PREPARING, CANCELLED |
| PREPARING | READY |
| READY | OUT_FOR_DELIVERY |
| OUT_FOR_DELIVERY | DELIVERED |
| DELIVERED | - (final) |
| CANCELLED | - (final) |

---

# Postman Collection

```json
{
  "info": {
    "name": "Order & Cart Management APIs",
    "description": "Complete collection for Order and Cart management"
  },
  "variable": [
    {
      "key": "baseUrl",
      "value": "http://localhost:8080"
    },
    {
      "key": "customerToken",
      "value": ""
    },
    {
      "key": "kitchenToken",
      "value": ""
    }
  ],
  "item": [
    {
      "name": "Cart",
      "item": [
        {
          "name": "Get Cart",
          "request": {
            "method": "GET",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"}
            ],
            "url": "{{baseUrl}}/api/v1/cart"
          }
        },
        {
          "name": "Add Item to Cart",
          "request": {
            "method": "POST",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"},
              {"key": "Content-Type", "value": "application/json"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"itemId\": 10,\n  \"quantity\": 2,\n  \"specialRequests\": \"Extra spicy\"\n}"
            },
            "url": "{{baseUrl}}/api/v1/cart/items"
          }
        },
        {
          "name": "Update Cart Item",
          "request": {
            "method": "PUT",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"},
              {"key": "Content-Type", "value": "application/json"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"quantity\": 3,\n  \"specialRequests\": \"No onions\"\n}"
            },
            "url": "{{baseUrl}}/api/v1/cart/items/1"
          }
        },
        {
          "name": "Remove Cart Item",
          "request": {
            "method": "DELETE",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"}
            ],
            "url": "{{baseUrl}}/api/v1/cart/items/1"
          }
        },
        {
          "name": "Clear Cart",
          "request": {
            "method": "DELETE",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"}
            ],
            "url": "{{baseUrl}}/api/v1/cart"
          }
        },
        {
          "name": "Apply Coupon",
          "request": {
            "method": "POST",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"},
              {"key": "Content-Type", "value": "application/json"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"couponCode\": \"SAVE10\"\n}"
            },
            "url": "{{baseUrl}}/api/v1/cart/coupon"
          }
        }
      ]
    },
    {
      "name": "Orders",
      "item": [
        {
          "name": "Create Order",
          "request": {
            "method": "POST",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"},
              {"key": "Content-Type", "value": "application/json"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"kitchenId\": 5,\n  \"deliveryAddress\": \"123 Main Street, Apt 4B\",\n  \"deliveryCity\": \"Kuala Lumpur\",\n  \"deliveryState\": \"Wilayah Persekutuan\",\n  \"deliveryPostalCode\": \"50000\",\n  \"specialInstructions\": \"Please call when you arrive\",\n  \"items\": [\n    {\"itemId\": 10, \"quantity\": 2, \"specialRequests\": \"Extra spicy\"},\n    {\"itemId\": 15, \"quantity\": 1}\n  ]\n}"
            },
            "url": "{{baseUrl}}/api/v1/orders"
          }
        },
        {
          "name": "Get Order by ID",
          "request": {
            "method": "GET",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"}
            ],
            "url": "{{baseUrl}}/api/v1/orders/1001"
          }
        },
        {
          "name": "Get My Orders",
          "request": {
            "method": "GET",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"}
            ],
            "url": {
              "raw": "{{baseUrl}}/api/v1/orders/my-orders?page=0&size=10",
              "query": [
                {"key": "page", "value": "0"},
                {"key": "size", "value": "10"}
              ]
            }
          }
        },
        {
          "name": "Get Kitchen Orders",
          "request": {
            "method": "GET",
            "header": [
              {"key": "Authorization", "value": "Bearer {{kitchenToken}}"},
              {"key": "X-Kitchen-Id", "value": "5"}
            ],
            "url": {
              "raw": "{{baseUrl}}/api/v1/orders/kitchen/5?page=0&size=10",
              "query": [
                {"key": "page", "value": "0"},
                {"key": "size", "value": "10"}
              ]
            }
          }
        },
        {
          "name": "Get Kitchen Pending Orders",
          "request": {
            "method": "GET",
            "header": [
              {"key": "Authorization", "value": "Bearer {{kitchenToken}}"},
              {"key": "X-Kitchen-Id", "value": "5"}
            ],
            "url": {
              "raw": "{{baseUrl}}/api/v1/orders/kitchen/5/pending?page=0&size=10",
              "query": [
                {"key": "page", "value": "0"},
                {"key": "size", "value": "10"}
              ]
            }
          }
        },
        {
          "name": "Accept Order",
          "request": {
            "method": "PATCH",
            "header": [
              {"key": "Authorization", "value": "Bearer {{kitchenToken}}"},
              {"key": "X-Kitchen-Id", "value": "5"}
            ],
            "url": "{{baseUrl}}/api/v1/orders/1005/accept"
          }
        },
        {
          "name": "Update Order Status",
          "request": {
            "method": "PATCH",
            "header": [
              {"key": "Authorization", "value": "Bearer {{kitchenToken}}"},
              {"key": "X-Kitchen-Id", "value": "5"}
            ],
            "url": {
              "raw": "{{baseUrl}}/api/v1/orders/1005/status?status=PREPARING",
              "query": [
                {"key": "status", "value": "PREPARING"}
              ]
            }
          }
        },
        {
          "name": "Cancel Order",
          "request": {
            "method": "PATCH",
            "header": [
              {"key": "Authorization", "value": "Bearer {{customerToken}}"},
              {"key": "X-User-Id", "value": "1"}
            ],
            "url": "{{baseUrl}}/api/v1/orders/1005/cancel"
          }
        }
      ]
    }
  ]
}
```

---

# Testing Workflow

## 1. Setup - Get Authentication Tokens

```bash
# Customer Login
curl -X POST "http://localhost:8080/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"customer@example.com","password":"CustomerPass123"}'

# Kitchen Login
curl -X POST "http://localhost:8080/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"kitchen@example.com","password":"KitchenPass123"}'
```

## 2. Customer Flow - Add to Cart and Create Order

```bash
# Step 1: Add items to cart
curl -X POST "http://localhost:8080/api/v1/cart/items" \
  -H "Authorization: Bearer {customerToken}" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"itemId": 10, "quantity": 2, "specialRequests": "Extra spicy"}'

# Step 2: Add another item
curl -X POST "http://localhost:8080/api/v1/cart/items" \
  -H "Authorization: Bearer {customerToken}" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"itemId": 15, "quantity": 1}'

# Step 3: View cart
curl -X GET "http://localhost:8080/api/v1/cart" \
  -H "Authorization: Bearer {customerToken}" \
  -H "X-User-Id: 1"

# Step 4: Apply coupon (optional)
curl -X POST "http://localhost:8080/api/v1/cart/coupon" \
  -H "Authorization: Bearer {customerToken}" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"couponCode": "SAVE10"}'

# Step 5: Create order
curl -X POST "http://localhost:8080/api/v1/orders" \
  -H "Authorization: Bearer {customerToken}" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "kitchenId": 5,
    "deliveryAddress": "123 Main Street, Apt 4B",
    "deliveryCity": "Kuala Lumpur",
    "deliveryState": "Wilayah Persekutuan",
    "deliveryPostalCode": "50000",
    "items": [
      {"itemId": 10, "quantity": 2, "specialRequests": "Extra spicy"},
      {"itemId": 15, "quantity": 1}
    ]
  }'

# Step 6: Check order status
curl -X GET "http://localhost:8080/api/v1/orders/1001" \
  -H "Authorization: Bearer {customerToken}"
```

## 3. Kitchen Flow - Process Order

```bash
# Step 1: View pending orders
curl -X GET "http://localhost:8080/api/v1/orders/kitchen/5/pending" \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 5"

# Step 2: Accept order
curl -X PATCH "http://localhost:8080/api/v1/orders/1001/accept" \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 5"

# Step 3: Start preparing
curl -X PATCH "http://localhost:8080/api/v1/orders/1001/status?status=PREPARING" \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 5"

# Step 4: Mark as ready
curl -X PATCH "http://localhost:8080/api/v1/orders/1001/status?status=READY" \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 5"

# Step 5: Out for delivery
curl -X PATCH "http://localhost:8080/api/v1/orders/1001/status?status=OUT_FOR_DELIVERY" \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 5"

# Step 6: Delivered
curl -X PATCH "http://localhost:8080/api/v1/orders/1001/status?status=DELIVERED" \
  -H "Authorization: Bearer {kitchenToken}" \
  -H "X-Kitchen-Id: 5"
```

---

# Key Points

## Headers Required
| Header | Required For | Description |
|--------|--------------|-------------|
| `Authorization` | All endpoints | Bearer token from login |
| `X-User-Id` | Customer endpoints | Customer's user ID |
| `X-Kitchen-Id` | Kitchen endpoints | Kitchen's ID |
| `Content-Type` | POST/PUT/PATCH | Must be `application/json` |

## Response Format
All responses follow this structure:
```json
{
  "success": boolean,
  "data": object/array/null,
  "message": string,
  "timestamp": "ISO-8601 datetime",
  "errors": ["array of error strings"]
}
```

## Pagination
For paginated endpoints:
- Default page size: 10
- Page is 0-indexed
- Response includes `pagination` object with:
  - `page`: Current page number
  - `size`: Page size
  - `totalElements`: Total items
  - `totalPages`: Total pages
  - `hasNext`: Boolean
  - `hasPrevious`: Boolean

## Error Codes
| HTTP Status | Meaning |
|-------------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request / Validation Error |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 500 | Internal Server Error |

---

**Last Updated**: February 9, 2026
