# Makan For You - Screen Implementation Guide

## 📋 Overview

This guide provides detailed instructions for implementing all remaining screens in the Makan For You Flutter application. Each section includes specific requirements, UI components, and integration points.

---

## ✅ Completed Screens

1. ✅ Splash Screen - Animated splash with auto-navigation
2. ✅ Login Screen - Email/password authentication
3. ✅ Register Screen - Multi-role registration
4. ✅ Home Screen - Featured kitchens and categories
5. ✅ Main Navigation Screen - Bottom navigation bar
6. ✅ Profile Screen - User info and settings

---

## 🚧 Screens to Implement

### 1. Menu Search Screen
**File**: `lib/features/menu/screens/menu_search_screen.dart`

**Features**:
- Search bar with real-time search
- Filter chips (Veg, Non-Veg, Halal, Spicy levels)
- Price range slider
- Sort options (Rating, Price, Newest)
- Grid/List toggle view
- Menu item cards with images
- Add to cart quick action
- Recent searches

**Implementation Steps**:
```dart
// 1. Add search text field with debouncing
// 2. Create filter bottom sheet
// 3. Implement grid view with menu items
// 4. Add "Add to Cart" button on each card
// 5. Show dietary indicators (veg/non-veg/halal)
// 6. Implement pagination
```

**Provider Methods to Use**:
- `MenuProvider.searchMenuItems()`
- `MenuProvider.fetchLabels()`
- `CartProvider.addItem()`

---

### 2. Menu Item Detail Screen
**File**: `lib/features/menu/screens/menu_item_detail_screen.dart`

**Features**:
- Large item image (with placeholder)
- Item name and description
- Price display
- Dietary indicators (veg/non-veg/halal badges)
- Spicy level display
- Rating and reviews
- Quantity selector
- Add to cart button
- Kitchen info section (clickable to kitchen detail)
- Related items

**Implementation Steps**:
```dart
// 1. Fetch item details on screen init
// 2. Create image carousel
// 3. Show dietary badges
// 4. Add quantity +/- buttons
// 5. Calculate total
// 6. Handle add to cart
```

**UI Components**:
- CachedNetworkImage for item image
- RatingBar widget
- Custom quantity selector
- Floating "Add to Cart" button

---

### 3. Kitchen List Screen
**File**: `lib/features/kitchen/screens/kitchen_list_screen.dart`

**Features**:
- All approved kitchens
- Search bar for kitchens
- Filter by cuisine type
- Sort by rating, distance
- Kitchen cards with image, rating, cuisine types
- Favorite button on cards
- Pull to refresh
- Infinite scroll pagination

**Implementation Steps**:
```dart
// 1. Load kitchens on init
// 2. Add search functionality
// 3. Create filter chips for cuisines
// 4. Implement pagination with scroll controller
// 5. Add favorite toggle
```

**Provider Methods**:
- `KitchenProvider.fetchKitchens()`
- `KitchenProvider.searchKitchens()`

---

### 4. Kitchen Detail Screen
**File**: `lib/features/kitchen/screens/kitchen_detail_screen.dart`

**Features**:
- Kitchen banner/header
- Kitchen name, rating, cuisine types
- Address and contact info
- Favorite button
- Menu tabs (All, Veg, Non-Veg)
- Menu items in categories
- Add to cart from detail page
- Reviews section
- Operating hours

**Implementation Steps**:
```dart
// 1. Fetch kitchen details by ID
// 2. Create image header with gradient overlay
// 3. Show kitchen info card
// 4. Fetch kitchen menu items
// 5. Create tabbed menu view
// 6. Add items to cart
```

**Provider Methods**:
- `KitchenProvider.fetchKitchenById()`
- `MenuProvider.fetchKitchenMenu()`

---

### 5. Cart Screen
**File**: `lib/features/cart/screens/cart_screen.dart`

**Features**:
- Empty cart state
- Cart item list
- Quantity +/- controls
- Remove item button
- Subtotal, tax, delivery, total
- "Proceed to Checkout" button
- Kitchen info at top
- Coupon/promo code input (optional)

**Implementation Steps**:
```dart
// 1. Watch CartProvider for items
// 2. Create cart item card
// 3. Add quantity controls
// 4. Show price breakdown
// 5. Handle remove item
// 6. Navigate to checkout
```

**UI Components**:
```dart
Widget _buildCartItem(CartItem item) {
  return Card(
    child: Row(
      children: [
        // Item image
        // Item name, price
        // Quantity controls
        // Remove button
      ],
    ),
  );
}

Widget _buildPriceBreakdown() {
  return Column(
    children: [
      _buildPriceRow('Subtotal', cartProvider.subtotal),
      _buildPriceRow('Tax (5%)', cartProvider.tax),
      _buildPriceRow('Service Charge', cartProvider.serviceCharge),
      _buildPriceRow('Delivery', cartProvider.deliveryCharge),
      Divider(),
      _buildPriceRow('Total', cartProvider.total, bold: true),
    ],
  );
}
```

---

### 6. Checkout Screen
**File**: `lib/features/order/screens/checkout_screen.dart`

**Features**:
- Order summary
- Delivery address input/selection
- Payment method selection:
  - Credit/Debit Card
  - UPI
  - Net Banking
  - Wallet
  - Cash on Delivery
- Special instructions text field
- Total amount display
- "Place Order" button
- Loading state during order creation

**Implementation Steps**:
```dart
// 1. Get cart items
// 2. Show order summary
// 3. Add address form/selector
// 4. Create payment method selector
// 5. Handle place order:
//    a. Create order
//    b. Create payment
//    c. Clear cart
//    d. Navigate to order detail
```

**Provider Methods**:
- `OrderProvider.createOrder()`
- `PaymentProvider.createPayment()`
- `CartProvider.clearCart()`

---

### 7. Order List Screen
**File**: `lib/features/order/screens/order_list_screen.dart`

**Features**:
- Tabs: Active Orders / Past Orders
- Order cards showing:
  - Order ID
  - Kitchen name
  - Items count
  - Total amount
  - Order status with color coding
  - Date/time
- Status badges
- Pull to refresh
- Empty state for no orders
- Click to view details

**Implementation Steps**:
```dart
// 1. Fetch orders on init
// 2. Create tabs for active/past
// 3. Build order card widget
// 4. Color code status badges
// 5. Navigate to order detail
```

**Status Colors**:
- PENDING: Orange
- CONFIRMED: Blue
- PREPARING: Yellow
- OUT_FOR_DELIVERY: Purple
- DELIVERED: Green
- CANCELLED: Red

---

### 8. Order Detail Screen
**File**: `lib/features/order/screens/order_detail_screen.dart`

**Features**:
- Order status timeline/stepper
- Order items list
- Kitchen info
- Delivery address
- Payment info
- Total breakdown
- Track Delivery button (if active)
- Cancel Order button (if applicable)
- Help/Support button

**Implementation Steps**:
```dart
// 1. Fetch order details
// 2. Create status timeline widget
// 3. Show order items
// 4. Display payment status
// 5. Add track delivery button
// 6. Implement cancel order
```

**Timeline Widget**:
```dart
Widget _buildStatusTimeline(Order order) {
  final steps = [
    'Order Placed',
    'Confirmed',
    'Preparing',
    'Out for Delivery',
    'Delivered',
  ];
  
  return ListView.builder(
    itemCount: steps.length,
    itemBuilder: (context, index) {
      final isComplete = index <= order.currentStep;
      return _buildTimelineItem(steps[index], isComplete);
    },
  );
}
```

---

### 9. Delivery Tracking Screen
**File**: `lib/features/delivery/screens/delivery_tracking_screen.dart`

**Features**:
- Delivery status
- Delivery partner info (name, phone)
- Estimated delivery time
- Current location (text or map if implemented)
- Status timeline
- Call delivery partner button
- Order details button

**Implementation Steps**:
```dart
// 1. Fetch delivery by order ID
// 2. Show delivery status
// 3. Display partner info
// 4. Add call button (url_launcher)
// 5. Show estimated time
// 6. Optional: Add Google Maps integration
```

**Provider Methods**:
- `DeliveryProvider.fetchDeliveryByOrderId()`

**Optional Map Integration**:
```dart
// If implementing Google Maps:
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(latitude, longitude),
    zoom: 14,
  ),
  markers: {
    // Kitchen marker
    // Delivery location marker
    // Current location marker (if tracking)
  },
)
```

---

### 10. Kitchen Register Screen
**File**: `lib/features/kitchen/screens/kitchen_register_screen.dart`

**Features**:
- Multi-step form
- Step 1: Kitchen Info (name, description)
- Step 2: Address (street, city, zip)
- Step 3: Contact (phone, email)
- Step 4: Cuisine Types (checkboxes)
- Step 5: Additional Info
- Progress indicator
- Form validation
- Submit button
- Success/error handling

**Implementation Steps**:
```dart
// 1. Create step pages
// 2. Add step indicator
// 3. Implement next/previous
// 4. Validate each step
// 5. Submit registration
// 6. Show success message
```

**Provider Methods**:
- `KitchenProvider.registerKitchen()`

---

## 🎨 Reusable Widgets to Create

Create these in `lib/core/widgets/`:

### 1. KitchenCard Widget
```dart
class KitchenCard extends StatelessWidget {
  final Kitchen kitchen;
  final VoidCallback onTap;
  final bool showDistance;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: // Kitchen image/icon
        title: // Kitchen name
        subtitle: // Cuisine, rating
        trailing: // Favorite button
        onTap: onTap,
      ),
    );
  }
}
```

### 2. MenuItemCard Widget
```dart
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Item image
          // Dietary badges
          // Item name, price
          // Add to cart button
        ],
      ),
    );
  }
}
```

### 3. DietaryIndicator Widget
```dart
class DietaryIndicator extends StatelessWidget {
  final bool isVeg;
  final bool isHalal;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isVeg) _buildVegBadge(),
        if (!isVeg) _buildNonVegBadge(),
        if (isHalal) _buildHalalBadge(),
      ],
    );
  }
}
```

### 4. SpicyLevelIndicator Widget
```dart
class SpicyLevelIndicator extends StatelessWidget {
  final int level; // 1-5
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.local_fire_department,
          color: index < level ? Colors.red : Colors.grey,
          size: 16,
        );
      }),
    );
  }
}
```

### 5. PriceTag Widget
```dart
class PriceTag extends StatelessWidget {
  final double price;
  final bool large;
  
  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: large ? 24 : 16,
        fontWeight: FontWeight.bold,
        color: ThemeConfig.primaryColor,
      ),
    );
  }
}
```

### 6. EmptyState Widget
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            if (action != null) ...[
              SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

### 7. LoadingOverlay Widget
```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
```

### 8. StatusBadge Widget
```dart
class StatusBadge extends StatelessWidget {
  final String status;
  
  Color _getStatusColor() {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'CONFIRMED': return Colors.blue;
      case 'PREPARING': return Colors.yellow;
      case 'DELIVERED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

---

## 🔧 Common Patterns

### 1. Loading State Pattern
```dart
Consumer<YourProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (provider.error != null) {
      return ErrorWidget(message: provider.error!);
    }
    
    if (provider.items.isEmpty) {
      return EmptyState(
        icon: Icons.inbox,
        title: 'No items',
        subtitle: 'No items found',
      );
    }
    
    return ListView.builder(
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        return YourItemWidget(item: provider.items[index]);
      },
    );
  },
)
```

### 2. Pagination Pattern
```dart
class YourScreen extends StatefulWidget {
  @override
  _YourScreenState createState() => _YourScreenState();
}

class _YourScreenState extends State<YourScreen> {
  final _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }
  
  Future<void> _loadData() async {
    await context.read<YourProvider>().fetchData(refresh: true);
  }
  
  Future<void> _loadMore() async {
    await context.read<YourProvider>().fetchData(refresh: false);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### 3. Form Validation Pattern
```dart
final _formKey = GlobalKey<FormState>();

void _submit() {
  if (_formKey.currentState!.validate()) {
    // Process form
  }
}

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    ],
  ),
)
```

### 4. Confirmation Dialog Pattern
```dart
Future<void> _confirmAction() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm Action'),
      content: Text('Are you sure?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirm'),
        ),
      ],
    ),
  );
  
  if (confirm == true) {
    // Proceed with action
  }
}
```

---

## 📱 Testing Checklist

### Before Testing
- [ ] Backend services are running
- [ ] Base URL is configured correctly
- [ ] Flutter dependencies installed (`flutter pub get`)

### Registration & Login
- [ ] Register as CUSTOMER
- [ ] Register as KITCHEN  
- [ ] Login with valid credentials
- [ ] Login validation works
- [ ] Token is saved and persists
- [ ] Auto-logout on token expiry

### Home & Navigation
- [ ] Home screen loads kitchens
- [ ] Bottom navigation works
- [ ] Cart badge shows count
- [ ] Search navigation works
- [ ] Pull to refresh works

### Kitchen & Menu
- [ ] Kitchen list loads
- [ ] Kitchen detail shows menu
- [ ] Menu search works
- [ ] Filters apply correctly
- [ ] Add to cart works

### Cart & Checkout
- [ ] Cart shows items
- [ ] Quantity update works
- [ ] Remove item works
- [ ] Price calculation correct
- [ ] Checkout creates order
- [ ] Payment methods work

### Orders & Delivery
- [ ] Orders list shows correctly
- [ ] Order detail displays
- [ ] Cancel order works
- [ ] Delivery tracking loads
- [ ] Status updates reflect

### Profile
- [ ] Profile shows user info
- [ ] Logout works
- [ ] Settings load

---

## 🐛 Common Issues & Solutions

### Issue: Network Error
**Solution**: Check base URL, ensure backend is running, check device network

### Issue: Token Expired
**Solution**: Logout and login again, or wait for auto-refresh

### Issue: Build Error
**Solution**: Run `flutter clean && flutter pub get`

### Issue: Provider Not Found
**Solution**: Check MultiProvider setup in main.dart

### Issue: Navigation Not Working
**Solution**: Check GoRouter configuration in app_router.dart

---

## 🚀 Performance Tips

1. **Use const constructors** where possible
2. **Implement pagination** for long lists
3. **Cache images** with CachedNetworkImage
4. **Debounce search** input
5. **Lazy load** tabs and screens
6. **Optimize images** before upload
7. **Use ListView.builder** instead of ListView

---

## 📚 Next Steps

1. Complete all placeholder screens
2. Add error handling and retry logic
3. Implement offline support
4. Add animations and transitions
5. Write unit tests
6. Write widget tests
7. Performance optimization
8. Add analytics (optional)
9. Add push notifications (optional)
10. Prepare for deployment

---

**Happy Coding! 🎉**
