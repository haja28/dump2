# Coupon Service API Documentation

## Overview
The Coupon Service manages promotional coupons for the MakanForYou platform. It provides:
- **Admin APIs**: Create, update, delete, and manage coupons
- **Customer APIs**: View available coupons, validate, and redeem at checkout

**Base URL**: `http://localhost:8087/api/v1`

---

## Table of Contents
1. [Admin Endpoints](#admin-endpoints)
2. [Customer Endpoints](#customer-endpoints)
3. [Coupon Types](#coupon-types)
4. [Sample Coupons](#sample-coupons)
5. [Integration Guide](#integration-guide)

---

## Admin Endpoints

Base: `/api/v1/admin/coupons`

### 1. Create Coupon
**POST** `/api/v1/admin/coupons`

```bash
curl -X POST "http://localhost:8087/api/v1/admin/coupons" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "SUMMER25",
    "name": "Summer Sale 25% Off",
    "description": "Get 25% off during our summer promotion",
    "discount_type": "PERCENTAGE",
    "discount_value": 25.00,
    "max_discount_amount": 30.00,
    "min_order_amount": 30.00,
    "max_uses": 500,
    "max_uses_per_user": 2,
    "valid_from": "2026-06-01T00:00:00",
    "valid_until": "2026-08-31T23:59:59",
    "applicable_to": "ALL",
    "is_first_order_only": false,
    "is_new_user_only": false
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "coupon_id": 1,
    "code": "SUMMER25",
    "name": "Summer Sale 25% Off",
    "description": "Get 25% off during our summer promotion",
    "discount_type": "PERCENTAGE",
    "discount_value": 25.00,
    "discount_display": "25% off (max RM30)",
    "max_discount_amount": 30.00,
    "min_order_amount": 30.00,
    "max_uses": 500,
    "current_uses": 0,
    "remaining_uses": 500,
    "max_uses_per_user": 2,
    "valid_from": "2026-06-01T00:00:00",
    "valid_until": "2026-08-31T23:59:59",
    "status": "ACTIVE",
    "applicable_to": "ALL",
    "is_valid": true,
    "created_at": "2026-02-09T10:00:00"
  },
  "message": "Coupon created successfully"
}
```

### 2. Update Coupon
**PUT** `/api/v1/admin/coupons/{couponId}`

```bash
curl -X PUT "http://localhost:8087/api/v1/admin/coupons/1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Summer Sale 30% Off",
    "discount_value": 30.00,
    "max_uses": 1000
  }'
```

### 3. Delete (Deactivate) Coupon
**DELETE** `/api/v1/admin/coupons/{couponId}`

```bash
curl -X DELETE "http://localhost:8087/api/v1/admin/coupons/1"
```

### 4. Get All Coupons
**GET** `/api/v1/admin/coupons`

```bash
curl -X GET "http://localhost:8087/api/v1/admin/coupons?page=0&size=20&sort=createdAt&direction=DESC"
```

### 5. Search Coupons
**GET** `/api/v1/admin/coupons/search`

```bash
curl -X GET "http://localhost:8087/api/v1/admin/coupons/search?query=SUMMER&page=0&size=20"
```

### 6. Get Coupons by Status
**GET** `/api/v1/admin/coupons/status/{status}`

```bash
curl -X GET "http://localhost:8087/api/v1/admin/coupons/status/ACTIVE?page=0&size=20"
```

### 7. Activate/Deactivate Coupon
```bash
# Activate
curl -X PATCH "http://localhost:8087/api/v1/admin/coupons/1/activate"

# Deactivate
curl -X PATCH "http://localhost:8087/api/v1/admin/coupons/1/deactivate"
```

---

## Customer Endpoints

Base: `/api/v1/coupons`

### 1. Get Available Coupons
**GET** `/api/v1/coupons/available`

```bash
curl -X GET "http://localhost:8087/api/v1/coupons/available?kitchen_id=1"
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "coupon_id": 1,
      "code": "SAVE10",
      "name": "10% Off",
      "description": "Get 10% off your order",
      "discount_type": "PERCENTAGE",
      "discount_value": 10.00,
      "discount_display": "10% off (max RM15)",
      "min_order_amount": 20.00,
      "remaining_uses": 950,
      "valid_until": "2026-03-11T00:00:00",
      "is_valid": true
    },
    {
      "coupon_id": 2,
      "code": "FREESHIP",
      "name": "Free Delivery",
      "description": "Free delivery on your order",
      "discount_type": "FREE_DELIVERY",
      "discount_value": 5.00,
      "discount_display": "Free Delivery",
      "min_order_amount": 15.00,
      "is_valid": true
    }
  ]
}
```

### 2. Validate Coupon
**POST** `/api/v1/coupons/validate`

Use this before checkout to check if a coupon is valid.

```bash
curl -X POST "http://localhost:8087/api/v1/coupons/validate" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "coupon_code": "SAVE10",
    "order_amount": 50.00,
    "kitchen_id": 1,
    "is_first_order": false,
    "is_new_user": false
  }'
```

**Success Response:**
```json
{
  "success": true,
  "data": {
    "is_valid": true,
    "coupon_code": "SAVE10",
    "coupon_name": "10% Off",
    "discount_display": "10% off (max RM15)",
    "discount_amount": 5.00,
    "order_amount": 50.00,
    "final_amount": 45.00,
    "remaining_uses": 949
  },
  "message": "Coupon is valid"
}
```

**Error Response (Min Order Not Met):**
```json
{
  "success": true,
  "data": {
    "is_valid": false,
    "error_code": "MIN_ORDER_NOT_MET",
    "error_message": "Minimum order amount of RM20 required",
    "min_order_amount": 20.00,
    "order_amount": 15.00
  },
  "message": "Minimum order amount of RM20 required"
}
```

### 3. Redeem Coupon
**POST** `/api/v1/coupons/redeem`

Call this when the order is being placed.

```bash
curl -X POST "http://localhost:8087/api/v1/coupons/redeem" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "coupon_code": "SAVE10",
    "order_id": 1001,
    "order_amount": 50.00,
    "kitchen_id": 1
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "redemption_id": 1,
    "coupon_id": 1,
    "coupon_code": "SAVE10",
    "coupon_name": "10% Off",
    "user_id": 1,
    "order_id": 1001,
    "order_amount": 50.00,
    "discount_applied": 5.00,
    "status": "APPLIED",
    "redeemed_at": "2026-02-09T10:30:00"
  },
  "message": "Coupon applied! You saved RM5.00"
}
```

### 4. Get My Redemption History
**GET** `/api/v1/coupons/my-redemptions`

```bash
curl -X GET "http://localhost:8087/api/v1/coupons/my-redemptions?page=0&size=20" \
  -H "X-User-Id: 1"
```

### 5. Complete Redemption (Order Service Integration)
**POST** `/api/v1/coupons/redemptions/{orderId}/complete`

```bash
curl -X POST "http://localhost:8087/api/v1/coupons/redemptions/1001/complete"
```

### 6. Cancel Redemption (Order Service Integration)
**POST** `/api/v1/coupons/redemptions/{orderId}/cancel`

```bash
curl -X POST "http://localhost:8087/api/v1/coupons/redemptions/1001/cancel"
```

---

## Coupon Types

### Discount Types
| Type | Description | Example |
|------|-------------|---------|
| `PERCENTAGE` | Percentage off order | 10% off |
| `FIXED_AMOUNT` | Fixed amount off | RM5 off |
| `FREE_DELIVERY` | Waive delivery fee | Free Delivery |

### Coupon Status
| Status | Description |
|--------|-------------|
| `ACTIVE` | Coupon can be used |
| `INACTIVE` | Coupon disabled by admin |
| `EXPIRED` | Coupon past valid_until date |
| `EXHAUSTED` | Coupon reached max_uses |

### Applicable To
| Value | Description |
|-------|-------------|
| `ALL` | All orders |
| `SPECIFIC_KITCHEN` | Only for specific kitchen |
| `DELIVERY_ONLY` | Only delivery orders |
| `PICKUP_ONLY` | Only pickup orders |

---

## Sample Coupons

| Code | Type | Discount | Min Order | Description |
|------|------|----------|-----------|-------------|
| `SAVE10` | PERCENTAGE | 10% (max RM15) | RM20 | Standard discount |
| `SAVE20` | PERCENTAGE | 20% (max RM25) | RM30 | Better discount |
| `SAVE5` | FIXED_AMOUNT | RM5 | RM25 | Fixed amount off |
| `FLAT10` | FIXED_AMOUNT | RM10 | RM40 | Fixed amount off |
| `FREESHIP` | FREE_DELIVERY | Free | RM15 | Free delivery |
| `WELCOME` | PERCENTAGE | 25% (max RM20) | RM20 | New users only |
| `FIRSTORDER` | PERCENTAGE | 30% | RM25 | First order only |
| `FLASH40` | PERCENTAGE | 40% (max RM30) | RM30 | Limited time |

---

## Integration Guide

### Checkout Flow

```
1. Customer adds items to cart
          ↓
2. Customer enters coupon code
          ↓
3. Frontend calls POST /api/v1/coupons/validate
          ↓
4. Display discount to customer
          ↓
5. Customer confirms order
          ↓
6. Order Service creates order
          ↓
7. Order Service calls POST /api/v1/coupons/redeem
          ↓
8. Coupon applied, discount recorded
          ↓
9. When order completed: POST /api/v1/coupons/redemptions/{orderId}/complete
   OR
   When order cancelled: POST /api/v1/coupons/redemptions/{orderId}/cancel
```

### Order Service Integration

When creating an order with a coupon:

```java
// 1. Validate coupon
CouponValidationResult validation = couponServiceClient.validateCoupon(userId, 
    couponCode, orderAmount, kitchenId);

if (!validation.isValid()) {
    throw new ApplicationException(validation.getErrorCode(), validation.getErrorMessage());
}

// 2. Create order with discount
Order order = createOrder(userId, request);
order.setDiscountAmount(validation.getDiscountAmount());
order.setFinalAmount(validation.getFinalAmount());

// 3. Redeem coupon
couponServiceClient.redeemCoupon(userId, couponCode, order.getId(), orderAmount);

// 4. On order completion
couponServiceClient.completeRedemption(orderId);

// 5. On order cancellation
couponServiceClient.cancelRedemption(orderId);
```

---

## Error Codes

| Code | Message |
|------|---------|
| `COUPON_NOT_FOUND` | Coupon code not found |
| `COUPON_INACTIVE` | Coupon is not active |
| `COUPON_EXPIRED` | Coupon has expired |
| `COUPON_EXHAUSTED` | Coupon reached max usage |
| `USER_LIMIT_REACHED` | User exceeded per-user limit |
| `MIN_ORDER_NOT_MET` | Order doesn't meet minimum |
| `KITCHEN_MISMATCH` | Coupon not valid for this kitchen |
| `FIRST_ORDER_ONLY` | Coupon only for first orders |
| `NEW_USER_ONLY` | Coupon only for new users |
| `ALREADY_REDEEMED` | Coupon already applied to order |
| `COUPON_EXISTS` | Coupon code already exists (admin) |
| `INVALID_DATES` | Invalid date range (admin) |

---

**Service Port**: 8087  
**Swagger UI**: http://localhost:8087/swagger-ui.html  
**Last Updated**: February 9, 2026
