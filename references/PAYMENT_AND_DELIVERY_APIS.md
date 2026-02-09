# Payment and Delivery Services - Comprehensive API Documentation

## Table of Contents
1. [Payment Service APIs](#payment-service-apis)
2. [Delivery Service APIs](#delivery-service-apis)
3. [Database Dependencies](#database-dependencies)
4. [Entity Models](#entity-models)
5. [Integration with Order Service](#integration-with-order-service)
6. [Error Handling](#error-handling)
7. [Status Enums](#status-enums)

---

## Payment Service APIs

### Service Overview
- **Port**: 8085
- **Base URL**: `http://localhost:8085/api/v1/payments`
- **Authentication**: JWT Bearer Token
- **Database**: MySQL (payments, orders, users tables)

### Database Dependencies
- **payments** table - Primary data store
- **orders** table - Foreign key reference (order_id)
- **users** table - Foreign key reference (user_id)

---

### 1. Create Payment Record

**Endpoint**: `POST /api/v1/payments`

**Description**: Create a new payment record for an order.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "orderId": 1,
  "userId": 5,
  "paymentAmount": 599.99,
  "paymentMethod": "CREDIT_CARD",
  "transactionId": "TXN-2025-001234"
}
```

**Response (201 Created)**:
```json
{
  "paymentId": 101,
  "orderId": 1,
  "userId": 5,
  "paymentAmount": 599.99,
  "paymentMethod": "CREDIT_CARD",
  "paymentStatus": "PENDING",
  "transactionId": "TXN-2025-001234",
  "paymentDate": null,
  "refundAmount": 0.00,
  "refundDate": null,
  "refundReason": null,
  "createdAt": "2026-02-03T10:30:00Z",
  "updatedAt": "2026-02-03T10:30:00Z"
}
```

**Validation Rules**:
- `orderId`: Required, must exist in orders table
- `userId`: Required, must exist in users table
- `paymentAmount`: Required, must be > 0
- `paymentMethod`: Required, one of [CREDIT_CARD, DEBIT_CARD, NET_BANKING, WALLET, CASH_ON_DELIVERY, UPI]
- `transactionId`: Optional for CASH_ON_DELIVERY

**Errors**:
- `400 Bad Request` - Invalid payment data
- `404 Not Found` - Order or user not found
- `409 Conflict` - Payment already exists for this order

---

### 2. Get Payment by ID

**Endpoint**: `GET /api/v1/payments/{paymentId}`

**Description**: Retrieve payment details by payment ID.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "paymentId": 101,
  "orderId": 1,
  "userId": 5,
  "paymentAmount": 599.99,
  "paymentMethod": "CREDIT_CARD",
  "paymentStatus": "COMPLETED",
  "transactionId": "TXN-2025-001234",
  "paymentDate": "2026-02-03T10:35:00Z",
  "refundAmount": 0.00,
  "refundDate": null,
  "refundReason": null,
  "createdAt": "2026-02-03T10:30:00Z",
  "updatedAt": "2026-02-03T10:35:00Z"
}
```

**Errors**:
- `404 Not Found` - Payment not found
- `401 Unauthorized` - Invalid or missing token

---

### 3. Get Payment by Order ID

**Endpoint**: `GET /api/v1/payments/order/{orderId}`

**Description**: Retrieve payment details using order ID.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "paymentId": 101,
  "orderId": 1,
  "userId": 5,
  "paymentAmount": 599.99,
  "paymentMethod": "CREDIT_CARD",
  "paymentStatus": "COMPLETED",
  "transactionId": "TXN-2025-001234",
  "paymentDate": "2026-02-03T10:35:00Z",
  "refundAmount": 0.00,
  "refundDate": null,
  "refundReason": null,
  "createdAt": "2026-02-03T10:30:00Z",
  "updatedAt": "2026-02-03T10:35:00Z"
}
```

**Errors**:
- `404 Not Found` - Payment not found for order

---

### 4. Process Payment

**Endpoint**: `PUT /api/v1/payments/{paymentId}/process`

**Description**: Process payment and update status to COMPLETED.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "transactionId": "TXN-2025-001234",
  "paymentMethod": "CREDIT_CARD"
}
```

**Response (200 OK)**:
```json
{
  "paymentId": 101,
  "orderId": 1,
  "userId": 5,
  "paymentAmount": 599.99,
  "paymentMethod": "CREDIT_CARD",
  "paymentStatus": "COMPLETED",
  "transactionId": "TXN-2025-001234",
  "paymentDate": "2026-02-03T10:35:00Z",
  "refundAmount": 0.00,
  "refundDate": null,
  "refundReason": null,
  "createdAt": "2026-02-03T10:30:00Z",
  "updatedAt": "2026-02-03T10:35:00Z"
}
```

**Errors**:
- `404 Not Found` - Payment not found
- `400 Bad Request` - Payment already processed or invalid status transition

---

### 5. Refund Payment

**Endpoint**: `PUT /api/v1/payments/{paymentId}/refund`

**Description**: Initiate refund for a completed payment.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "refundAmount": 599.99,
  "refundReason": "Order cancelled by customer"
}
```

**Response (200 OK)**:
```json
{
  "paymentId": 101,
  "orderId": 1,
  "userId": 5,
  "paymentAmount": 599.99,
  "paymentMethod": "CREDIT_CARD",
  "paymentStatus": "REFUNDED",
  "transactionId": "TXN-2025-001234",
  "paymentDate": "2026-02-03T10:35:00Z",
  "refundAmount": 599.99,
  "refundDate": "2026-02-03T11:00:00Z",
  "refundReason": "Order cancelled by customer",
  "createdAt": "2026-02-03T10:30:00Z",
  "updatedAt": "2026-02-03T11:00:00Z"
}
```

**Validation**:
- `refundAmount` <= `paymentAmount`
- Payment status must be COMPLETED
- Refund can only be done once per payment

**Errors**:
- `404 Not Found` - Payment not found
- `400 Bad Request` - Invalid refund amount or invalid payment status

---

### 6. List User Payments

**Endpoint**: `GET /api/v1/payments/user/{userId}`

**Description**: List all payments for a user with pagination.

**Query Parameters**:
- `page`: Page number (0-indexed, default: 0)
- `size`: Page size (default: 20)
- `status`: Filter by payment status (optional)
- `sortBy`: Field to sort by (paymentDate, createdAt - default: paymentDate)
- `sortOrder`: asc or desc (default: desc)

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Example**: `GET /api/v1/payments/user/5?page=0&size=10&status=COMPLETED&sortOrder=desc`

**Response (200 OK)**:
```json
{
  "content": [
    {
      "paymentId": 101,
      "orderId": 1,
      "userId": 5,
      "paymentAmount": 599.99,
      "paymentMethod": "CREDIT_CARD",
      "paymentStatus": "COMPLETED",
      "transactionId": "TXN-2025-001234",
      "paymentDate": "2026-02-03T10:35:00Z",
      "refundAmount": 0.00,
      "refundDate": null,
      "refundReason": null,
      "createdAt": "2026-02-03T10:30:00Z",
      "updatedAt": "2026-02-03T10:35:00Z"
    }
  ],
  "totalElements": 15,
  "totalPages": 2,
  "currentPage": 0,
  "pageSize": 10,
  "hasNext": true,
  "hasPrevious": false
}
```

---

### 7. Payment Statistics

**Endpoint**: `GET /api/v1/payments/stats/user/{userId}`

**Description**: Get payment statistics for a user.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "userId": 5,
  "totalPayments": 15,
  "totalAmount": 8999.85,
  "completedPayments": 13,
  "completedAmount": 7799.87,
  "pendingPayments": 1,
  "pendingAmount": 599.99,
  "failedPayments": 1,
  "failedAmount": 199.99,
  "refundedPayments": 0,
  "refundedAmount": 0.00,
  "lastPaymentDate": "2026-02-03T10:35:00Z",
  "averagePaymentAmount": 599.99
}
```

---

### 8. Update Payment Status

**Endpoint**: `PATCH /api/v1/payments/{paymentId}/status`

**Description**: Update payment status directly (Admin only).

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "status": "FAILED",
  "reason": "Card declined"
}
```

**Response (200 OK)**:
```json
{
  "paymentId": 101,
  "paymentStatus": "FAILED",
  "updatedAt": "2026-02-03T10:40:00Z"
}
```

---

## Delivery Service APIs

### Service Overview
- **Port**: 8086
- **Base URL**: `http://localhost:8086/api/v1/deliveries`
- **Authentication**: JWT Bearer Token
- **Database**: MySQL (deliveries, orders, users, kitchens, kitchen_menu tables)

### Database Dependencies
- **deliveries** table - Primary data store
- **orders** table - Foreign key reference (order_id)
- **users** table - Foreign key reference (user_id)
- **kitchens** table - Foreign key reference (kitchen_id)
- **kitchen_menu** table - Foreign key reference (item_id)

---

### 1. Create Delivery Record

**Endpoint**: `POST /api/v1/deliveries`

**Description**: Create a new delivery record for an order.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "orderId": 1,
  "kitchenId": 2,
  "userId": 5,
  "itemId": 10,
  "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
  "deliveryNotes": "Leave at gate if no one is home"
}
```

**Response (201 Created)**:
```json
{
  "deliveryId": 201,
  "orderId": 1,
  "kitchenId": 2,
  "userId": 5,
  "itemId": 10,
  "deliveryStatus": "PENDING",
  "assignedTo": null,
  "pickupTime": null,
  "deliveryTime": null,
  "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
  "currentLocation": null,
  "deliveryNotes": "Leave at gate if no one is home",
  "createdAt": "2026-02-03T10:45:00Z",
  "updatedAt": "2026-02-03T10:45:00Z"
}
```

**Validation Rules**:
- `orderId`: Required, must exist in orders table and not already have a delivery
- `kitchenId`: Required, must exist in kitchens table
- `userId`: Required, must exist in users table
- `itemId`: Required, must exist in kitchen_menu table
- `estimatedDeliveryTime`: Required, must be in future

**Errors**:
- `400 Bad Request` - Invalid delivery data
- `404 Not Found` - Order, kitchen, user, or item not found
- `409 Conflict` - Delivery already exists for this order

---

### 2. Get Delivery by ID

**Endpoint**: `GET /api/v1/deliveries/{deliveryId}`

**Description**: Retrieve delivery details by delivery ID.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "deliveryId": 201,
  "orderId": 1,
  "kitchenId": 2,
  "userId": 5,
  "itemId": 10,
  "deliveryStatus": "IN_TRANSIT",
  "assignedTo": "Rajesh Kumar",
  "pickupTime": "2026-02-03T10:50:00Z",
  "deliveryTime": null,
  "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
  "currentLocation": "12.9716° N, 77.5946° E",
  "deliveryNotes": "Leave at gate if no one is home",
  "createdAt": "2026-02-03T10:45:00Z",
  "updatedAt": "2026-02-03T10:55:00Z"
}
```

**Errors**:
- `404 Not Found` - Delivery not found
- `401 Unauthorized` - Invalid or missing token

---

### 3. Get Delivery by Order ID

**Endpoint**: `GET /api/v1/deliveries/order/{orderId}`

**Description**: Retrieve delivery details using order ID.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "deliveryId": 201,
  "orderId": 1,
  "kitchenId": 2,
  "userId": 5,
  "itemId": 10,
  "deliveryStatus": "DELIVERED",
  "assignedTo": "Rajesh Kumar",
  "pickupTime": "2026-02-03T10:50:00Z",
  "deliveryTime": "2026-02-03T11:45:00Z",
  "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
  "currentLocation": "Delivered at gate",
  "deliveryNotes": "Leave at gate if no one is home",
  "createdAt": "2026-02-03T10:45:00Z",
  "updatedAt": "2026-02-03T11:45:00Z"
}
```

**Errors**:
- `404 Not Found` - Delivery not found for order

---

### 4. Assign Delivery Partner

**Endpoint**: `PUT /api/v1/deliveries/{deliveryId}/assign`

**Description**: Assign a delivery partner to a delivery.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "partnerName": "Rajesh Kumar",
  "partnerPhone": "9876543210"
}
```

**Response (200 OK)**:
```json
{
  "deliveryId": 201,
  "orderId": 1,
  "deliveryStatus": "ASSIGNED",
  "assignedTo": "Rajesh Kumar",
  "pickupTime": null,
  "deliveryTime": null,
  "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
  "updatedAt": "2026-02-03T11:00:00Z"
}
```

**Validation**:
- Delivery status must be PENDING
- Partner name and phone are required

**Errors**:
- `404 Not Found` - Delivery not found
- `400 Bad Request` - Invalid status transition

---

### 5. Update Pickup Status

**Endpoint**: `PUT /api/v1/deliveries/{deliveryId}/pickup`

**Description**: Mark delivery as picked up from kitchen.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "pickupTime": "2026-02-03T10:50:00Z",
  "notes": "Order picked up successfully"
}
```

**Response (200 OK)**:
```json
{
  "deliveryId": 201,
  "orderId": 1,
  "deliveryStatus": "PICKED_UP",
  "assignedTo": "Rajesh Kumar",
  "pickupTime": "2026-02-03T10:50:00Z",
  "deliveryTime": null,
  "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
  "updatedAt": "2026-02-03T10:50:00Z"
}
```

**Errors**:
- `404 Not Found` - Delivery not found
- `400 Bad Request` - Delivery not in ASSIGNED status

---

### 6. Update In-Transit Status

**Endpoint**: `PUT /api/v1/deliveries/{deliveryId}/in-transit`

**Description**: Mark delivery as in transit and update current location.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "currentLocation": "12.9716° N, 77.5946° E",
  "notes": "On the way to customer"
}
```

**Response (200 OK)**:
```json
{
  "deliveryId": 201,
  "orderId": 1,
  "deliveryStatus": "IN_TRANSIT",
  "assignedTo": "Rajesh Kumar",
  "currentLocation": "12.9716° N, 77.5946° E",
  "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
  "updatedAt": "2026-02-03T11:00:00Z"
}
```

**Errors**:
- `404 Not Found` - Delivery not found
- `400 Bad Request` - Delivery not in PICKED_UP status

---

### 7. Complete Delivery

**Endpoint**: `PUT /api/v1/deliveries/{deliveryId}/complete`

**Description**: Mark delivery as complete.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "deliveryTime": "2026-02-03T11:45:00Z",
  "notes": "Delivered successfully",
  "recipientName": "Mr. Smith"
}
```

**Response (200 OK)**:
```json
{
  "deliveryId": 201,
  "orderId": 1,
  "deliveryStatus": "DELIVERED",
  "assignedTo": "Rajesh Kumar",
  "deliveryTime": "2026-02-03T11:45:00Z",
  "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
  "currentLocation": "Customer location",
  "updatedAt": "2026-02-03T11:45:00Z"
}
```

**Errors**:
- `404 Not Found` - Delivery not found
- `400 Bad Request` - Delivery not in IN_TRANSIT status

---

### 8. Mark Delivery as Failed

**Endpoint**: `PUT /api/v1/deliveries/{deliveryId}/failed`

**Description**: Mark delivery as failed with reason.

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body**:
```json
{
  "reason": "Customer not available at address",
  "notes": "Will retry tomorrow"
}
```

**Response (200 OK)**:
```json
{
  "deliveryId": 201,
  "orderId": 1,
  "deliveryStatus": "FAILED",
  "assignedTo": "Rajesh Kumar",
  "deliveryNotes": "Customer not available at address - Will retry tomorrow",
  "updatedAt": "2026-02-03T12:30:00Z"
}
```

**Errors**:
- `404 Not Found` - Delivery not found

---

### 9. List Deliveries by Kitchen

**Endpoint**: `GET /api/v1/deliveries/kitchen/{kitchenId}`

**Description**: List all deliveries for a kitchen with pagination.

**Query Parameters**:
- `page`: Page number (0-indexed, default: 0)
- `size`: Page size (default: 20)
- `status`: Filter by delivery status (optional)
- `date`: Filter by specific date (YYYY-MM-DD, optional)
- `sortOrder`: asc or desc (default: desc)

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Example**: `GET /api/v1/deliveries/kitchen/2?page=0&size=10&status=DELIVERED`

**Response (200 OK)**:
```json
{
  "content": [
    {
      "deliveryId": 201,
      "orderId": 1,
      "kitchenId": 2,
      "userId": 5,
      "deliveryStatus": "DELIVERED",
      "assignedTo": "Rajesh Kumar",
      "pickupTime": "2026-02-03T10:50:00Z",
      "deliveryTime": "2026-02-03T11:45:00Z",
      "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
      "currentLocation": "Customer location",
      "createdAt": "2026-02-03T10:45:00Z",
      "updatedAt": "2026-02-03T11:45:00Z"
    }
  ],
  "totalElements": 25,
  "totalPages": 3,
  "currentPage": 0,
  "pageSize": 10,
  "hasNext": true,
  "hasPrevious": false
}
```

---

### 10. List Deliveries by User

**Endpoint**: `GET /api/v1/deliveries/user/{userId}`

**Description**: List all deliveries for a customer.

**Query Parameters**:
- `page`: Page number (0-indexed, default: 0)
- `size`: Page size (default: 20)
- `status`: Filter by delivery status (optional)
- `sortBy`: createdAt or deliveryTime (default: createdAt)
- `sortOrder`: asc or desc (default: desc)

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "content": [
    {
      "deliveryId": 201,
      "orderId": 1,
      "kitchenId": 2,
      "deliveryStatus": "DELIVERED",
      "assignedTo": "Rajesh Kumar",
      "deliveryTime": "2026-02-03T11:45:00Z",
      "estimatedDeliveryTime": "2026-02-03T12:00:00Z",
      "createdAt": "2026-02-03T10:45:00Z",
      "updatedAt": "2026-02-03T11:45:00Z"
    }
  ],
  "totalElements": 10,
  "totalPages": 1,
  "currentPage": 0,
  "pageSize": 20,
  "hasNext": false,
  "hasPrevious": false
}
```

---

### 11. Get Delivery Partner Stats

**Endpoint**: `GET /api/v1/deliveries/partner/{partnerName}/stats`

**Description**: Get statistics for a delivery partner.

**Query Parameters**:
- `startDate`: Start date for statistics (YYYY-MM-DD, optional)
- `endDate`: End date for statistics (YYYY-MM-DD, optional)

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "partnerName": "Rajesh Kumar",
  "totalDeliveries": 45,
  "completedDeliveries": 42,
  "failedDeliveries": 2,
  "pendingDeliveries": 1,
  "averageDeliveryTime": "PT45M30S",
  "successRate": 95.45,
  "totalDistance": 234.5,
  "topRating": 4.8,
  "lastDeliveryDate": "2026-02-03T11:45:00Z"
}
```

---

### 12. Get Delivery Statistics

**Endpoint**: `GET /api/v1/deliveries/stats`

**Description**: Get overall delivery statistics (Admin only).

**Query Parameters**:
- `startDate`: Start date for statistics (YYYY-MM-DD, optional)
- `endDate`: End date for statistics (YYYY-MM-DD, optional)

**Headers**:
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "totalDeliveries": 1250,
  "completedDeliveries": 1200,
  "failedDeliveries": 30,
  "pendingDeliveries": 20,
  "averageDeliveryTime": "PT50M15S",
  "successRate": 96.0,
  "onTimeDeliveries": 1180,
  "lateDeliveries": 20,
  "averageRating": 4.7,
  "topPartner": "Rajesh Kumar",
  "bottleneckLocation": "Downtown area"
}
```

---

## Database Dependencies

### Payment Service Dependencies

```
payments (PRIMARY)
├── orders (FOREIGN KEY: order_id)
│   ├── users (FOREIGN KEY: user_id)
│   └── kitchens (FOREIGN KEY: kitchen_id)
└── users (FOREIGN KEY: user_id)
```

### Delivery Service Dependencies

```
deliveries (PRIMARY)
├── orders (FOREIGN KEY: order_id)
│   ├── users (FOREIGN KEY: user_id)
│   ├── kitchens (FOREIGN KEY: kitchen_id)
│   └── order_items (FOREIGN KEY: order_id)
│       └── kitchen_menu (FOREIGN KEY: item_id)
├── users (FOREIGN KEY: user_id)
├── kitchens (FOREIGN KEY: kitchen_id)
└── kitchen_menu (FOREIGN KEY: item_id)
```

---

## Entity Models

### Payment Entity

```java
@Entity
@Table(name = "payments")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer paymentId;
    
    @Column(unique = true, nullable = false)
    private Integer orderId;
    
    @Column(nullable = false)
    private Integer userId;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal paymentAmount;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentMethod paymentMethod;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus paymentStatus;
    
    @Column(length = 100)
    private String transactionId;
    
    @Column
    private LocalDateTime paymentDate;
    
    @Column(precision = 10, scale = 2)
    private BigDecimal refundAmount;
    
    @Column
    private LocalDateTime refundDate;
    
    @Column(columnDefinition = "TEXT")
    private String refundReason;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
```

### Delivery Entity

```java
@Entity
@Table(name = "deliveries")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Delivery {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer deliveryId;
    
    @Column(unique = true, nullable = false)
    private Integer orderId;
    
    @Column(nullable = false)
    private Integer kitchenId;
    
    @Column(nullable = false)
    private Integer userId;
    
    @Column(nullable = false)
    private Integer itemId;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DeliveryStatus deliveryStatus;
    
    @Column(length = 100)
    private String assignedTo;
    
    @Column
    private LocalDateTime pickupTime;
    
    @Column
    private LocalDateTime deliveryTime;
    
    @Column(nullable = false)
    private LocalDateTime estimatedDeliveryTime;
    
    @Column(length = 255)
    private String currentLocation;
    
    @Column(columnDefinition = "TEXT")
    private String deliveryNotes;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
```

---

## Integration with Order Service

### Order Service Updates

When an order is created, the Order Service should:

1. **Create Payment Record**: Call Payment Service to create a payment record
   ```
   POST /api/v1/payments
   ```

2. **Create Delivery Record**: Call Delivery Service to create a delivery record
   ```
   POST /api/v1/deliveries
   ```

3. **Listen for Payment Status**: Order status transitions based on payment confirmation
   ```
   Order Status: PENDING → CONFIRMED (when payment is COMPLETED)
   Order Status: CONFIRMED → CANCELLED (if payment is FAILED)
   ```

4. **Listen for Delivery Status**: Order status transitions based on delivery completion
   ```
   Order Status: PREPARING → READY (when delivery is ASSIGNED)
   Order Status: READY → OUT_FOR_DELIVERY (when delivery is IN_TRANSIT)
   Order Status: OUT_FOR_DELIVERY → DELIVERED (when delivery is DELIVERED)
   ```

---

## Error Handling

### Standard Error Response Format

```json
{
  "timestamp": "2026-02-03T11:00:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Invalid payment amount",
  "path": "/api/v1/payments",
  "traceId": "uuid-here"
}
```

### Common HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid input data |
| 401 | Unauthorized | Missing/invalid JWT token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 500 | Internal Server Error | Server error |

---

## Status Enums

### PaymentStatus
- `PENDING` - Payment awaiting processing
- `COMPLETED` - Payment successfully processed
- `FAILED` - Payment processing failed
- `REFUNDED` - Payment refunded to customer

### PaymentMethod
- `CREDIT_CARD` - Credit card payment
- `DEBIT_CARD` - Debit card payment
- `NET_BANKING` - Online banking transfer
- `WALLET` - Digital wallet (UPI, PayTM, etc.)
- `CASH_ON_DELIVERY` - Cash payment at delivery
- `UPI` - Unified Payments Interface

### DeliveryStatus
- `PENDING` - Delivery order pending assignment
- `ASSIGNED` - Delivery partner assigned
- `PICKED_UP` - Order picked up from kitchen
- `IN_TRANSIT` - Order on the way to customer
- `DELIVERED` - Order successfully delivered
- `FAILED` - Delivery failed (retry needed)

---

## Authentication & Authorization

### JWT Token Structure

```json
{
  "sub": "user_id",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "CUSTOMER|KITCHEN|ADMIN",
  "iat": 1675000000,
  "exp": 1675086400
}
```

### Role-Based Access Control

| Endpoint | CUSTOMER | KITCHEN | ADMIN |
|----------|----------|---------|-------|
| POST /payments | ✓ | ✗ | ✓ |
| GET /payments/{id} | ✓ | ✗ | ✓ |
| PUT /payments/{id}/refund | ✓ | ✗ | ✓ |
| GET /deliveries/user/{id} | ✓ | ✗ | ✓ |
| GET /deliveries/kitchen/{id} | ✗ | ✓ | ✓ |
| PUT /deliveries/{id}/pickup | ✗ | ✓ | ✓ |

---

## Rate Limiting

All endpoints are rate limited:
- **Public endpoints**: 100 requests/hour
- **Authenticated endpoints**: 1000 requests/hour
- **Admin endpoints**: Unlimited

Headers returned:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1675086400
```

---

## Pagination Standards

All list endpoints support pagination:

```json
{
  "content": [...],
  "totalElements": 100,
  "totalPages": 5,
  "currentPage": 0,
  "pageSize": 20,
  "hasNext": true,
  "hasPrevious": false
}
```

---

## Webhook Events

Services publish the following events:

### Payment Service Events
- `payment.created` - When payment is created
- `payment.completed` - When payment is completed
- `payment.failed` - When payment fails
- `payment.refunded` - When payment is refunded

### Delivery Service Events
- `delivery.created` - When delivery is created
- `delivery.assigned` - When delivery partner is assigned
- `delivery.picked_up` - When order is picked up
- `delivery.in_transit` - When delivery is in transit
- `delivery.completed` - When delivery is completed
- `delivery.failed` - When delivery fails

---
