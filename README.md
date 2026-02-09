# Makan For You - Flutter Mobile Application

## 🎯 Overview

Makan For You is a comprehensive food delivery mobile application built with Flutter. It connects customers with home kitchens offering homemade meals, featuring a complete order management system with payment and delivery tracking.

## ✨ Features

### Customer Features
- 🔐 **Authentication** - Register, login, JWT token management
- 🔍 **Search & Discovery** - Advanced search with filters (veg, halal, spicy level, price, cuisine)
- 🛒 **Cart Management** - Add items, manage quantities, calculate totals with tax and delivery
- 📦 **Order Placement** - Create orders with delivery address and special instructions
- 💳 **Payment** - Multiple payment methods (UPI, cards, cash on delivery, wallets)
- 🚚 **Delivery Tracking** - Real-time order and delivery status updates
- ⭐ **Favorites** - Save favorite kitchens and menu items
- 📜 **Order History** - View past and active orders
- 👤 **Profile Management** - Update user information

### Kitchen Features
- 🏪 **Kitchen Registration** - Register as a home kitchen
- 📋 **Menu Management** - Add, update, and manage menu items
- 📊 **Order Management** - View, accept, and update order status
- 🚚 **Delivery Coordination** - Track delivery partners and status

### Admin Features
- ✅ **Kitchen Approval** - Approve new kitchen registrations
- 🏷️ **Label Management** - Create and manage food labels
- 📊 **Analytics** - View platform statistics

## 🏗️ Architecture

### State Management
- **Provider** for state management across the app
- Separate providers for each feature domain

### Project Structure
```
lib/
├── core/
│   ├── config/
│   │   ├── app_config.dart          # App-wide configuration
│   │   └── theme_config.dart        # Theme and design tokens
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── kitchen_model.dart
│   │   ├── menu_model.dart
│   │   ├── order_model.dart
│   │   ├── payment_model.dart
│   │   └── delivery_model.dart
│   ├── routes/
│   │   └── app_router.dart          # GoRouter configuration
│   └── services/
│       ├── api_service.dart         # API client with Dio
│       └── storage_service.dart     # Local storage (SharedPreferences + Secure Storage)
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── home/
│   │   └── screens/
│   │       ├── home_screen.dart
│   │       └── main_navigation_screen.dart
│   ├── kitchen/
│   │   ├── providers/
│   │   │   └── kitchen_provider.dart
│   │   └── screens/
│   │       ├── kitchen_list_screen.dart
│   │       ├── kitchen_detail_screen.dart
│   │       └── kitchen_register_screen.dart
│   ├── menu/
│   │   ├── providers/
│   │   │   └── menu_provider.dart
│   │   └── screens/
│   │       ├── menu_search_screen.dart
│   │       └── menu_item_detail_screen.dart
│   ├── cart/
│   │   ├── providers/
│   │   │   └── cart_provider.dart
│   │   └── screens/
│   │       └── cart_screen.dart
│   ├── order/
│   │   ├── providers/
│   │   │   └── order_provider.dart
│   │   └── screens/
│   │       ├── checkout_screen.dart
│   │       ├── order_list_screen.dart
│   │       └── order_detail_screen.dart
│   ├── payment/
│   │   ├── providers/
│   │   │   └── payment_provider.dart
│   │   └── screens/
│   │       └── payment_screen.dart
│   ├── delivery/
│   │   ├── providers/
│   │   │   └── delivery_provider.dart
│   │   └── screens/
│   │       └── delivery_tracking_screen.dart
│   ├── profile/
│   │   └── screens/
│   │       └── profile_screen.dart
│   └── splash/
│       └── screens/
│           └── splash_screen.dart
└── main.dart
```

## 🔌 API Integration

All API endpoints are configured to work with the backend Makan For You microservices:

### Services
- **Auth Service** (Port 8081) - User authentication
- **Kitchen Service** (Port 8082) - Kitchen management
- **Menu Service** (Port 8083) - Menu items and search
- **Order Service** (Port 8084) - Order processing
- **Payment Service** (Port 8085) - Payment handling
- **Delivery Service** (Port 8086) - Delivery tracking
- **API Gateway** (Port 8080) - Unified entry point

### Configuration
Update the base URL in `lib/core/config/app_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:8080';
```

For local testing with Android Emulator:
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

For local testing with iOS Simulator:
```dart
static const String baseUrl = 'http://localhost:8080';
```

For local testing with Physical Device:
```dart
static const String baseUrl = 'http://YOUR_LOCAL_IP:8080';
```

## 🎨 Design System

### Colors
- **Primary**: Orange (#FF6B35) - Main brand color
- **Secondary**: Golden Orange (#F7931E) - Accent color
- **Accent**: Turquoise (#4ECDC4) - Highlights
- **Success**: Green (#4CAF50) - Success states
- **Error**: Red (#E53935) - Error states

### Typography
- **Font Family**: Poppins (Google Fonts)
- Responsive font sizes with semantic naming
- Bold headings and regular body text

### Components
- Rounded corners (12px default)
- Elevated cards with shadows
- Gradient backgrounds for emphasis
- Smooth animations and transitions

## 📱 Screens to Implement

### Authentication Screens
1. **Login Screen** - Email/password login with validation
2. **Register Screen** - Multi-role registration (customer/kitchen/admin)

### Main Screens
3. **Main Navigation Screen** - Bottom navigation (Home, Search, Orders, Profile)
4. **Home Screen** - Featured kitchens, popular dishes, categories
5. **Search Screen** - Advanced filters and search results
6. **Kitchen List Screen** - Browse all approved kitchens
7. **Kitchen Detail Screen** - Kitchen info and menu
8. **Menu Item Detail Screen** - Item details with add to cart
9. **Cart Screen** - Review cart, update quantities
10. **Checkout Screen** - Address, payment method selection
11. **Order List Screen** - Active and past orders
12. **Order Detail Screen** - Order status and details
13. **Delivery Tracking Screen** - Real-time delivery tracking
14. **Profile Screen** - User settings and preferences
15. **Kitchen Register Screen** - Register new kitchen

## 🚀 Getting Started

### Prerequisites
```bash
flutter --version  # Ensure Flutter 3.0+ is installed
dart --version     # Ensure Dart 3.0+ is installed
```

### Installation

1. **Install Dependencies**
```bash
cd flutter_makan_for_you
flutter pub get
```

2. **Generate Asset Files** (if using code generation)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Configure Backend URL**
Edit `lib/core/config/app_config.dart` and set your backend URL

4. **Run the App**
```bash
# For Android
flutter run

# For iOS
flutter run

# For specific device
flutter devices
flutter run -d <device_id>
```

## 🔑 Environment Setup

### Android
- Minimum SDK: 21
- Target SDK: 34
- Add internet permission in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS
- Minimum iOS version: 12.0
- Add permissions in `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby kitchens</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos to upload food images</string>
```

## 📦 Dependencies

### Core
- `flutter` - Flutter SDK
- `provider` - State management
- `go_router` - Navigation and routing

### Networking
- `dio` - HTTP client
- `pretty_dio_logger` - Request/response logging
- `connectivity_plus` - Network status

### Storage
- `shared_preferences` - Simple key-value storage
- `flutter_secure_storage` - Secure token storage
- `hive` - Local database

### UI
- `google_fonts` - Typography
- `cached_network_image` - Image caching
- `shimmer` - Loading skeletons
- `lottie` - Animations
- `flutter_rating_bar` - Star ratings
- `badges` - Badge indicators

### Maps & Location
- `google_maps_flutter` - Map integration
- `geolocator` - Location services
- `geocoding` - Address geocoding

### Utils
- `intl` - Internationalization
- `timeago` - Time formatting
- `uuid` - Unique identifiers

## 🎯 Implementation Checklist

### Completed ✅
- [x] Project structure created
- [x] Dependencies configured
- [x] Core configuration (app config, theme)
- [x] API service with all endpoints
- [x] Storage service
- [x] Data models (User, Kitchen, Menu, Order, Payment, Delivery)
- [x] Routing configuration
- [x] State providers (Auth, Kitchen, Menu, Cart, Order, Payment, Delivery)
- [x] Splash screen
- [x] Main entry point

### Remaining Tasks 📋
- [ ] Complete Login screen UI
- [ ] Complete Register screen UI
- [ ] Main navigation screen with bottom nav
- [ ] Home screen with featured content
- [ ] Kitchen list and detail screens
- [ ] Menu search screen with filters
- [ ] Menu item detail screen
- [ ] Cart screen
- [ ] Checkout screen
- [ ] Order list and detail screens
- [ ] Delivery tracking screen with map
- [ ] Profile screen
- [ ] Kitchen registration screen
- [ ] Reusable UI widgets (cards, buttons, inputs)
- [ ] Error handling and loading states
- [ ] Offline support
- [ ] Push notifications (optional)
- [ ] Unit and widget tests

## 🧩 Reusable Widgets to Create

Create these in `lib/core/widgets/`:

1. **CustomButton** - Styled button component
2. **CustomTextField** - Styled input field
3. **LoadingIndicator** - Consistent loading spinner
4. **ErrorWidget** - Error display component
5. **EmptyState** - Empty data placeholder
6. **KitchenCard** - Kitchen display card
7. **MenuItemCard** - Menu item display card
8. **OrderCard** - Order summary card
9. **StatusBadge** - Status indicator
10. **RatingStars** - Rating display
11. **VegNonVegIndicator** - Dietary indicator
12. **HalalIndicator** - Halal certification badge
13. **SpicyLevelIndicator** - Spicy level display
14. **PriceTag** - Price display
15. **SearchBar** - Custom search input

## 🔒 Security Best Practices

- ✅ JWT tokens stored in secure storage
- ✅ Automatic token refresh on 401
- ✅ API request interceptors
- ✅ Input validation
- ✅ HTTPS only in production
- ✅ No sensitive data in logs (disable in production)

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

## 📱 Building for Release

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🎨 UI/UX Guidelines

1. **Consistency** - Use theme colors and components
2. **Accessibility** - Proper contrast, touch targets
3. **Performance** - Lazy loading, image optimization
4. **Responsive** - Handle different screen sizes
5. **Animations** - Smooth transitions, 60 FPS
6. **Feedback** - Loading states, error messages, success confirmations

## 🐛 Troubleshooting

### Common Issues

1. **Network Error**
   - Check base URL configuration
   - Ensure backend services are running
   - Check device network connectivity

2. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Flutter version compatibility

3. **Token Expiration**
   - Automatic refresh is implemented
   - If issues persist, logout and login again

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Material Design Guidelines](https://material.io/design)

## 👥 Development Team

- Frontend: Flutter Development Team
- Backend: Spring Boot Microservices Team
- Design: UX/UI Team

## 📄 License

Copyright © 2026 Makan For You. All rights reserved.

---

## 🚀 Quick Start Commands

```bash
# Setup
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk

# Generate code
flutter pub run build_runner build

# Clean build
flutter clean && flutter pub get && flutter run
```

## 📞 Support

For issues and questions:
- Check TROUBLESHOOTING.md
- Review API_DOCUMENTATION.md
- Contact development team

---

**Happy Coding! 🎉**
