# Makan For You - Multi-App Architecture

This project contains two separate Flutter applications:

1. **Customer App** (`main_customer.dart`) - For food ordering customers
2. **Kitchen App** (`main_kitchen.dart`) - For kitchen/restaurant owners

## Running Different Apps

### Customer App (Default)
```bash
flutter run -t lib/main.dart
# or
flutter run -t lib/main_customer.dart
```

### Kitchen App
```bash
flutter run -t lib/main_kitchen.dart
```

## Building APKs

### Customer App
```bash
flutter build apk -t lib/main_customer.dart --release
# Output: build/app/outputs/flutter-apk/app-release.apk
# Rename to: makan_customer.apk
```

### Kitchen App
```bash
flutter build apk -t lib/main_kitchen.dart --release
# Output: build/app/outputs/flutter-apk/app-release.apk
# Rename to: makan_kitchen.apk
```

## App Differences

### Customer App Features
- Browse kitchens and menus
- Search for food items
- Add items to cart
- Place orders
- Track deliveries
- View order history
- Chat with kitchens
- Manage profile
- Apply coupons

### Kitchen App Features
- Dashboard with order statistics
- Manage incoming orders (accept/reject/prepare/complete)
- Menu management (add/edit/delete items)
- Toggle item availability
- Kitchen profile settings
- Operating hours configuration
- Analytics and revenue tracking
- Chat with customers

## Architecture

### Shared Code (`lib/core/`)
- `config/` - App configuration, themes, app type
- `models/` - Data models (User, Kitchen, Order, MenuItem, etc.)
- `services/` - API service, storage service
- `routes/` - Customer and Kitchen specific routers

### Features (`lib/features/`)
- `auth/` - Authentication (shared)
- `kitchen/` - Kitchen-specific screens and providers
- `menu/` - Menu browsing and management
- `order/` - Order placement and management
- `cart/` - Shopping cart (customer only)
- `delivery/` - Delivery tracking
- `payment/` - Payment processing
- `chat/` - In-app messaging
- `profile/` - User profile management

## App Type Configuration

The app type is configured using `AppTypeConfig`:

```dart
// In main_customer.dart
AppTypeConfig.setAppType(AppType.customer);

// In main_kitchen.dart
AppTypeConfig.setAppType(AppType.kitchen);
```

This affects:
- Available routes
- Theme colors (Orange for Customer, Green for Kitchen)
- Available providers
- Login/registration flow

## Role-Based Access

Users have roles:
- `CUSTOMER` - Can use Customer app
- `KITCHEN` - Can use Kitchen app
- `ADMIN` - Administrative access

The Kitchen app validates that the logged-in user has the `KITCHEN` role.

