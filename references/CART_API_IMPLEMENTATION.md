# Cart Management API - Implementation Summary

## Overview
The Cart Management API has been fully implemented in the `order-service` microservice. It allows customers to manage their shopping cart before placing an order with advanced features for stock validation, price tracking, and cart expiration.

## Files Created/Updated

### Entities
| File | Description |
|------|-------------|
| `entity/Cart.java` | Cart entity with user, kitchen, coupon, and items |
| `entity/CartItem.java` | Individual items with price tracking and stock info |

### DTOs
| File | Description |
|------|-------------|
| `dto/CartDTO.java` | Response DTO with validation warnings |
| `dto/CartItemDTO.java` | Response DTO with stock and price change info |
| `dto/MenuItemDTO.java` | DTO for menu item with stock information |
| `dto/AddToCartRequest.java` | Request DTO for adding items |
| `dto/UpdateCartItemRequest.java` | Request DTO for updating items |
| `dto/ApplyCouponRequest.java` | Request DTO for applying coupons |
| `dto/CreateOrderFromCartRequest.java` | Request DTO for checkout |

### Repositories
| File | Description |
|------|-------------|
| `repository/CartRepository.java` | JPA repository with expiration queries |
| `repository/CartItemRepository.java` | JPA repository for CartItem entity |

### Services
| File | Description |
|------|-------------|
| `service/CartService.java` | Business logic for cart operations |
| `service/CartExpirationService.java` | Scheduled service for cart cleanup |
| `service/MenuServiceClient.java` | Mock client for menu/stock data |

### Controller
| File | Description |
|------|-------------|
| `controller/CartController.java` | REST endpoints for cart management |

### Database Migration
| File | Description |
|------|-------------|
| `db/migration/V3__create_cart_tables.sql` | SQL script with all cart columns |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/cart` | Get current user's cart |
| `POST` | `/api/v1/cart/items` | Add item to cart (with stock validation) |
| `PUT` | `/api/v1/cart/items/{cartItemId}` | Update cart item quantity |
| `DELETE` | `/api/v1/cart/items/{cartItemId}` | Remove item from cart |
| `DELETE` | `/api/v1/cart` | Clear entire cart |
| `POST` | `/api/v1/cart/coupon` | Apply coupon code |
| `DELETE` | `/api/v1/cart/coupon` | Remove applied coupon |
| `POST` | `/api/v1/cart/refresh` | Refresh cart with latest prices/stock |
| `POST` | `/api/v1/cart/validate` | Validate cart for checkout |
| `POST` | `/api/v1/orders/from-cart` | Create order from cart (checkout) |

## Key Features

### 1. Stock Validation ✅
When adding items to cart:
- Checks if item is available
- Validates sufficient stock exists
- Enforces max order quantity limits
- Returns clear error messages if stock insufficient

```json
{
  "success": false,
  "message": "'Chicken Biryani' - Only 3 available"
}
```

### 2. Cart Expiration ✅
- Carts automatically expire after 24 hours of inactivity
- Warning shown when cart is about to expire (2 hours before)
- Scheduled job runs every hour to clean up expired carts
- Configuration in `application.yml`:

```yaml
cart:
  expiration:
    hours: 24           # Expiration time
    warning-hours: 2    # Warning period
    cron: "0 0 * * * *" # Cleanup schedule
```

### 3. Price Change Detection ✅
- Original price stored when item added to cart
- When cart is refreshed, current prices are fetched
- Price changes are detected and flagged
- Users see warning messages for price changes

```json
{
  "cart_item_id": 1,
  "item_name": "Chicken Biryani",
  "unit_price": 14.99,
  "original_price": 12.99,
  "price_changed": true,
  "price_difference": 2.00,
  "price_change_message": "Chicken Biryani price increased by RM2.00"
}
```

### 4. Cart Response with Warnings
Cart response now includes validation status and warnings:

```json
{
  "cart_id": 123,
  "items": [...],
  "subtotal": 36.48,
  "total": 39.48,
  "is_valid": true,
  "has_stock_issues": false,
  "has_price_changes": true,
  "warnings": [
    "Chicken Biryani price increased by RM2.00",
    "Only 3 left of Special Chef's Thali",
    "Your cart will expire in 45 minutes. Complete your order soon!"
  ],
  "expires_at": "2026-02-10T10:00:00",
  "minutes_until_expiry": 45
}
```

### 5. Single Kitchen Constraint
- Cart can only contain items from one kitchen
- Adding items from a different kitchen returns an error
- User must clear cart to order from a different kitchen

### 6. Coupon System
Three test coupons are pre-configured:
| Code | Discount |
|------|----------|
| `SAVE10` | 10% off order |
| `SAVE5` | RM 5 off order |
| `FREESHIP` | Free delivery |

## Testing with cURL

### 1. Get Cart
```bash
curl -X GET "http://localhost:8084/api/v1/cart" \
  -H "X-User-Id: 1"
```

### 2. Add Item to Cart (with stock validation)
```bash
curl -X POST "http://localhost:8084/api/v1/cart/items" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"item_id": 1, "quantity": 2, "special_requests": "Extra spicy"}'
```

### 3. Add Item with Limited Stock (item_id 5 has only 3 available)
```bash
curl -X POST "http://localhost:8084/api/v1/cart/items" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"item_id": 5, "quantity": 5}'
# Returns error: Maximum order quantity exceeded
```

### 4. Add Out of Stock Item (item_id 6)
```bash
curl -X POST "http://localhost:8084/api/v1/cart/items" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"item_id": 6, "quantity": 1}'
# Returns error: Item unavailable
```

### 5. Refresh Cart (check for price/stock changes)
```bash
curl -X POST "http://localhost:8084/api/v1/cart/refresh" \
  -H "X-User-Id: 1"
```

### 6. Validate Cart for Checkout
```bash
curl -X POST "http://localhost:8084/api/v1/cart/validate" \
  -H "X-User-Id: 1"
```

### 7. Apply Coupon
```bash
curl -X POST "http://localhost:8084/api/v1/cart/coupon" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"coupon_code": "SAVE10"}'
```

### 8. Create Order from Cart (Checkout)
```bash
curl -X POST "http://localhost:8084/api/v1/orders/from-cart" \
  -H "X-User-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "delivery_address": "123 Main Street, Apt 4B",
    "delivery_city": "Kuala Lumpur",
    "delivery_state": "Wilayah Persekutuan",
    "delivery_postal_code": "50000",
    "special_instructions": "Please call when you arrive"
  }'
```

## Database Schema

### carts Table
```sql
CREATE TABLE carts (
    cart_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    kitchen_id BIGINT,
    kitchen_name VARCHAR(100),
    coupon_code VARCHAR(50),
    coupon_description VARCHAR(255),
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    delivery_fee DECIMAL(10, 2) DEFAULT 3.00,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    INDEX idx_cart_updated_at (updated_at)
);
```

### cart_items Table
```sql
CREATE TABLE cart_items (
    cart_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    item_id BIGINT NOT NULL,
    item_name VARCHAR(100),
    item_description VARCHAR(500),
    image_url VARCHAR(500),
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    current_menu_price DECIMAL(10, 2),
    price_changed BOOLEAN DEFAULT FALSE,
    in_stock BOOLEAN DEFAULT TRUE,
    available_stock INT,
    special_requests VARCHAR(500),
    added_at TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE
);
```

## Mock Menu Items for Testing

| Item ID | Name | Price | Stock | Max Order |
|---------|------|-------|-------|-----------|
| 1 | Chicken Biryani | RM 12.99 | 50 | 10 |
| 2 | Paneer Tikka Masala | RM 10.50 | 30 | 5 |
| 3 | Butter Naan | RM 2.50 | 100 | 20 |
| 4 | Nasi Lemak Special | RM 8.99 | 25 | 5 |
| 5 | Special Chef's Thali | RM 18.99 | **3** | 2 |
| 6 | Mango Lassi | RM 4.50 | **0** (Out of Stock) | 10 |

## Configuration

Add to `application.yml`:

```yaml
cart:
  expiration:
    hours: 24           # Cart expires after 24 hours
    warning-hours: 2    # Warning 2 hours before expiry
    cron: "0 0 * * * *" # Run cleanup every hour
```

---

**Last Updated**: February 9, 2026
