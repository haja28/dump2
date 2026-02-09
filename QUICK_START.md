# Quick Start Guide - Makan For You Flutter App

## 🚀 Get Started in 5 Minutes

### Prerequisites Check
```bash
# Check Flutter installation
flutter doctor

# Expected output should show:
# ✓ Flutter (Channel stable, 3.x.x)
# ✓ Android toolchain
# ✓ iOS toolchain (Mac only)
# ✓ VS Code / Android Studio
```

If Flutter is not installed, visit: https://docs.flutter.dev/get-started/install

---

## 📥 Step 1: Install Dependencies

```bash
cd flutter_makan_for_you
flutter pub get
```

This will download all required packages (~2-3 minutes).

---

## ⚙️ Step 2: Configure Backend URL

### Option A: Local Development (Recommended for Testing)

Edit `lib/core/config/app_config.dart`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:8080';
```

**For Physical Device (get your computer's IP):**
```bash
# On Windows
ipconfig
# Look for IPv4 Address (e.g., 192.168.1.100)

# On Mac/Linux
ifconfig
# Look for inet address
```

Then use:
```dart
static const String baseUrl = 'http://YOUR_IP:8080';
```

### Option B: Remote Server
```dart
static const String baseUrl = 'https://api.yourserver.com';
```

---

## 🏃 Step 3: Start Backend Services

The app requires all backend services to be running.

### Option 1: All Services via API Gateway
```bash
# Make sure these are running:
# - Port 8080: API Gateway
# - Port 8081: Auth Service
# - Port 8082: Kitchen Service
# - Port 8083: Menu Service
# - Port 8084: Order Service
# - Port 8085: Payment Service
# - Port 8086: Delivery Service

# Test if backend is up:
curl http://localhost:8080/api/v1/kitchens
```

### Option 2: Docker (if configured)
```bash
docker-compose up -d
```

---

## 📱 Step 4: Run the App

### Check Available Devices
```bash
flutter devices
```

### Run on Specific Device

**Android Emulator:**
```bash
flutter run -d emulator-5554
```

**iOS Simulator:**
```bash
flutter run -d "iPhone 14"
```

**Physical Device:**
```bash
flutter run -d <device-id>
```

**Auto-detect (runs on first available device):**
```bash
flutter run
```

---

## 🧪 Step 5: Test the App

### 1. Register a New Account
- Tap "Register" on login screen
- Fill in details:
  - First Name: Test
  - Last Name: User
  - Email: test@example.com
  - Phone: 1234567890
  - Password: test123
  - Role: Customer
- Tap "Create Account"

### 2. Browse Kitchens
- Home screen shows featured kitchens
- Tap on a kitchen to view details
- Browse menu items

### 3. Add to Cart
- Tap on a menu item
- Select quantity
- Tap "Add to Cart"
- Cart badge will update

### 4. View Cart
- Tap cart icon in app bar
- Review items
- Proceed to checkout

### 5. Place Order
- Enter delivery address
- Select payment method
- Place order

### 6. Track Order
- Navigate to Orders tab
- View order status
- Track delivery

---

## 🔧 Troubleshooting

### Backend Connection Failed

**Error:** "Network Error" or "Failed to load kitchens"

**Solutions:**
1. Check backend is running:
   ```bash
   curl http://localhost:8080/api/v1/kitchens
   ```
2. Verify baseUrl in app_config.dart
3. Check firewall settings
4. For physical device: ensure on same network

### Build Failed

**Error:** Build errors or missing dependencies

**Solutions:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Hot Reload Not Working

**Solutions:**
```bash
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
# Or stop and run again
```

### iOS Build Issues (Mac only)

**Solutions:**
```bash
cd ios
pod install
cd ..
flutter run
```

### Token Expired Error

**Solution:**
- Logout and login again
- Token auto-refresh is implemented but may need re-login for first time

---

## 📊 Development Workflow

### 1. Making Changes
```bash
# Make code changes
# Flutter automatically hot reloads
# Check console for errors
```

### 2. Testing
```bash
# Run tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

### 3. Analyzing Code
```bash
# Check for issues
flutter analyze

# Format code
flutter format lib/
```

### 4. Building Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (Mac only)
flutter build ios --release
```

---

## 🎯 Common Tasks

### Add New Dependency
```yaml
# 1. Add to pubspec.yaml
dependencies:
  new_package: ^1.0.0

# 2. Install
flutter pub get

# 3. Import in Dart file
import 'package:new_package/new_package.dart';
```

### Create New Screen
```bash
# 1. Create file in appropriate feature folder
lib/features/your_feature/screens/your_screen.dart

# 2. Add route in app_router.dart
# 3. Navigate using context.push('/your-route')
```

### Add New Provider
```bash
# 1. Create provider file
lib/features/your_feature/providers/your_provider.dart

# 2. Add to MultiProvider in main.dart
ChangeNotifierProvider(create: (_) => YourProvider()),
```

### Update API Endpoint
```bash
# Add method in lib/core/services/api_service.dart
static Future<Response> yourEndpoint() {
  return _dio.get('/your-endpoint');
}
```

---

## 🐛 Debug Mode

### Enable Debug Features
```dart
// In app_config.dart
static const bool isProduction = false;
static const bool enableLogging = true;
```

### View Logs
```bash
# Filter Flutter logs
flutter logs

# View specific device logs
adb logcat flutter:I *:S  # Android
```

### Use Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Then open URL shown in terminal.

---

## 📱 Platform-Specific Setup

### Android

**Required:**
- Android Studio
- Android SDK
- Android Emulator or Physical Device

**Permissions in AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS (Mac Only)

**Required:**
- Xcode
- CocoaPods
- iOS Simulator or Physical Device

**Run:**
```bash
cd ios
pod install
cd ..
flutter run
```

---

## 🎨 UI Development Tips

### 1. Use Hot Reload
- Make UI changes
- Press 'r' in terminal
- See changes instantly

### 2. Use Flutter Inspector
- Open DevTools
- Inspect widget tree
- Check properties

### 3. Test Different Screen Sizes
```bash
# Run with different device sizes
flutter run -d "iPhone SE"
flutter run -d "Pixel 6"
```

---

## 🔑 Test Accounts (After Backend Setup)

### Customer Account
```
Email: customer@test.com
Password: test123
Role: CUSTOMER
```

### Kitchen Account
```
Email: kitchen@test.com
Password: test123
Role: KITCHEN
```

### Admin Account
```
Email: admin@test.com
Password: test123
Role: ADMIN
```

*Note: These need to be registered first if not seeded in database*

---

## 📚 Helpful Commands

```bash
# List all Flutter commands
flutter help

# Show app performance
flutter run --trace-skia

# Profile mode (better performance than debug)
flutter run --profile

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade

# Clean build artifacts
flutter clean

# Doctor with verbose output
flutter doctor -v
```

---

## 🚀 Performance Tips

### 1. Use const Constructors
```dart
const Text('Hello')  // ✓ Good
Text('Hello')        // ✗ Bad (if content is constant)
```

### 2. Use ListView.builder
```dart
ListView.builder(...)  // ✓ Good (lazy loading)
ListView(children: [...])  // ✗ Bad (loads all at once)
```

### 3. Avoid setState in build()
```dart
// ✓ Good
@override
void initState() {
  super.initState();
  fetchData();
}

// ✗ Bad
@override
Widget build(BuildContext context) {
  fetchData(); // Never do this!
}
```

---

## 📖 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter YouTube Channel](https://www.youtube.com/c/flutterdev)

---

## 🎯 Next Steps

After running the app:

1. ✅ Test authentication flow
2. ✅ Browse kitchens
3. ✅ Test cart functionality
4. 🚧 Implement remaining screens (see IMPLEMENTATION_GUIDE.md)
5. 🚧 Add error handling
6. 🚧 Write tests
7. 🚧 Optimize performance
8. 🚧 Deploy to stores

---

## 💡 Pro Tips

1. **Use Flutter DevTools** - Invaluable for debugging
2. **Hot Reload Often** - Fastest way to see changes
3. **Check Logs** - Monitor console for errors
4. **Test on Real Devices** - Emulators don't always match real performance
5. **Read Provider Docs** - Understanding state management is key
6. **Follow Flutter Style Guide** - Keep code consistent

---

## 📞 Getting Help

**If stuck:**
1. Check console for error messages
2. Review IMPLEMENTATION_GUIDE.md
3. Check existing similar screens
4. Review provider methods
5. Check API service documentation

**Common Error Patterns:**
- Red screen: Check error message at top
- Network error: Check backend connection
- Widget not found: Check provider setup
- Navigation error: Check router configuration

---

## ✅ Ready to Go!

Your app should now be running! You're seeing:
- ✅ Animated splash screen
- ✅ Login screen
- ✅ After login: Home screen with kitchens
- ✅ Bottom navigation bar
- ✅ Profile screen

**Happy Coding! 🎉**

For detailed implementation of remaining screens, see **IMPLEMENTATION_GUIDE.md**

---

*Last Updated: February 3, 2026*
