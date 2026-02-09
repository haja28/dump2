I need to develop a comprehensive Flutter mobile application UI for the MakanForYou food delivery platform. The app should implement Cart Management, Order Management, Payment, and Delivery tracking features based on the existing backend APIs.

Project Context
Backend APIs Available:

Cart Management API (Port 8084)
Order Management API (Port 8080)
Payment Service API (Port 8085)
Delivery Service API (Port 8086)
Coupon Service API (Port 8087)
Authentication: JWT Bearer Token with headers:

Authorization: Bearer <token>
X-User-Id: <userId> for customer endpoints
X-Kitchen-Id: <kitchenId> for kitchen endpoints
Required Features & Screens
1. CART MANAGEMENT MODULE
   1.1 Cart Screen (CartScreen)
   Purpose: Display and manage shopping cart

UI Components:

AppBar with "My Cart" title and clear cart icon button
Empty cart state with illustration and "Browse Menu" CTA button
Cart items list with:
Item image thumbnail (network image with placeholder)
Item name and description (truncated to 2 lines)
Unit price and quantity selector (+/- buttons)
Special requests text (if any)
Subtotal per item
Delete icon button
Cart expiration warning banner (if minutes_until_expiry < 120)
Orange warning with countdown timer
Example: "⚠️ Cart expires in 45 minutes"
Price change warnings list (if has_price_changes = true)
Yellow alert cards for each item with price changes
Show old price (strikethrough) and new price
Example: "Chicken Biryani: RM12.99 RM10.99 (+RM2.00)"
Stock warnings list (if has_stock_issues = true)
Red/orange alerts for low stock items
Example: "Only 3 left of Special Chef's Thali"
Coupon section:
If no coupon: "Apply Coupon" button with icon
If coupon applied: Green chip showing coupon code and discount with remove icon
Bottom price summary card:
Subtotal
Delivery fee
Discount (if applied, in green)
Total (bold, large text)
Fixed bottom button: "Proceed to Checkout" (disabled if cart invalid)
API Integration:

Dart
// Get cart
GET /api/v1/cart

// Add item to cart
POST /api/v1/cart/items
Body: {itemId, quantity, specialRequests}

// Update cart item
PUT /api/v1/cart/items/{cartItemId}
Body: {quantity, specialRequests}

// Remove item
DELETE /api/v1/cart/items/{cartItemId}

// Clear cart
DELETE /api/v1/cart

// Refresh cart (prices/stock)
POST /api/v1/cart/refresh
State Management:

CartProvider/CartBloc to manage cart state
Loading states for API calls
Error handling with SnackBar
Optimistic UI updates for quantity changes
Validations:

Show error if adding item from different kitchen
Show stock validation errors
Prevent checkout if is_valid = false
Show validation warnings before checkout
1.2 Coupon Bottom Sheet (CouponBottomSheet)
Purpose: Apply/view available coupons

UI Components:

Title: "Available Coupons"
Coupon code input field with "Apply" button
Available coupons list (horizontal scrollable cards):
Coupon code (bold, large)
Discount display (e.g., "10% off (max RM15)")
Description
Min order requirement
Valid until date
"Apply" button
Remaining uses badge (if limited)
Applied coupon indicator at top (if any)
API Integration:

Dart
// Get available coupons
GET /api/v1/coupons/available?kitchen_id={kitchenId}

// Apply coupon to cart
POST /api/v1/cart/coupon
Body: {couponCode}

// Remove coupon
DELETE /api/v1/cart/coupon

// Validate coupon (before applying)
POST /api/v1/coupons/validate
Body: {couponCode, orderAmount, kitchenId, isFirstOrder, isNewUser}
Error Handling:

Show validation errors (min order not met, expired, etc.)
Display error messages from API
1.3 Cart Item Edit Bottom Sheet (CartItemEditSheet)
Purpose: Edit quantity and special requests for cart item

UI Components:

Item name and image
Quantity selector with +/- buttons (min: 1)
Special requests text field (multiline, max 500 chars)
"Update" and "Remove Item" buttons
2. ORDER MANAGEMENT MODULE
   2.1 Checkout Screen (CheckoutScreen)
   Purpose: Finalize order with delivery details

UI Components:

Stepper/progress indicator: Cart → Delivery → Payment → Confirm
Cart summary card (collapsed, expandable to show items)
Delivery address section:
Address input fields (street, city, state, postal code)
"Use saved address" dropdown (if available)
Map view integration (optional, for location picker)
Special instructions text field (max 500 chars)
Kitchen info card (kitchen name, preparing time estimate)
Price breakdown card (same as cart)
Payment method selector (radio buttons):
Credit Card
Debit Card
Wallet/UPI
Cash on Delivery
Terms & conditions checkbox
Fixed bottom button: "Place Order" (with loading state)
API Integration:

Dart
// Validate cart before checkout
POST /api/v1/cart/validate

// Create order from cart
POST /api/v1/orders/from-cart
Body: {
deliveryAddress,
deliveryCity,
deliveryState,
deliveryPostalCode,
specialInstructions
}

// OR create order directly
POST /api/v1/orders
Body: {
kitchenId,
deliveryAddress,
deliveryCity,
deliveryState,
deliveryPostalCode,
specialInstructions,
items: [{itemId, quantity, specialRequests}]
}
Validations:

All delivery address fields required (min 5 chars for address)
Postal code format validation
Cart must be valid before checkout
Payment method selection required
2.2 Order Confirmation Screen (OrderConfirmationScreen)
Purpose: Show order placed successfully

UI Components:

Success animation (Lottie/checkmark animation)
Order ID (large, copyable)
Estimated delivery time
Kitchen preparing status
"Track Order" button
"View Order Details" button
"Continue Shopping" button
2.3 My Orders Screen (MyOrdersScreen)
Purpose: View order history

UI Components:

AppBar with "My Orders" title
Tab bar: All | Pending | Preparing | Delivered | Cancelled
Order list (paginated, pull-to-refresh):
Order card with:
Order ID
Kitchen name
Order date/time
Status badge (color-coded)
Total amount
Item count
Primary action button (context-aware):
"Track Order" (if active)
"Reorder" (if delivered)
"Cancel Order" (if pending/confirmed)
Empty state for each tab
Filter/sort options (date, amount)
API Integration:

Dart
// Get user orders (paginated)
GET /api/v1/orders/my-orders?page={page}&size={size}

// Get order by ID
GET /api/v1/orders/{orderId}

// Cancel order
PATCH /api/v1/orders/{orderId}/cancel
State Management:

OrdersProvider/OrdersBloc with pagination
Tab-based filtering
Real-time status updates (WebSocket or polling)
2.4 Order Details Screen (OrderDetailsScreen)
Purpose: Detailed view of specific order

UI Components:

AppBar with order ID and share icon
Order status stepper/timeline:
Pending → Confirmed → Preparing → Ready → Out for Delivery → Delivered
Show checkmarks for completed stages
Current stage highlighted
Timestamps for each stage
Kitchen info card (name, phone, preparing time)
Delivery address card (with map view)
Order items list (non-editable):
Item image, name, quantity, price
Special requests (if any)
Price breakdown
Payment info card:
Payment method
Transaction ID
Payment status badge
Delivery tracking card (if active):
Delivery partner name and phone
Current location (if available)
"Track Live" button (opens tracking screen)
Action buttons:
"Cancel Order" (if pending/confirmed)
"Need Help?" (support chat/call)
"Reorder" (if delivered)
API Integration:

Dart
// Get order details
GET /api/v1/orders/{orderId}

// Cancel order
PATCH /api/v1/orders/{orderId}/cancel

// Get payment details
GET /api/v1/payments/order/{orderId}

// Get delivery details
GET /api/v1/deliveries/order/{orderId}
3. PAYMENT MODULE
   3.1 Payment Method Selection Screen (PaymentMethodScreen)
   Purpose: Choose payment method during checkout

UI Components:

List of payment methods (cards):
Credit Card (icon + label)
Debit Card
Net Banking
Wallet/UPI (with popular options: PhonePe, GooglePay, Paytm)
Cash on Delivery
Each card selectable (radio button or checkmark)
For card payments: "Add New Card" button
Saved cards section (if any)
"Proceed to Pay" button at bottom
3.2 Card Payment Screen (CardPaymentScreen)
Purpose: Enter card details (simplified UI)

UI Components:

Card preview (animated, flips on CVV entry)
Card number field (auto-formatted: XXXX XXXX XXXX XXXX)
Expiry date field (MM/YY)
CVV field (3-4 digits, password field)
Cardholder name field
"Save card for future use" checkbox
Security badges (SSL, PCI compliance icons)
"Pay RM XX.XX" button
Note: In production, use payment gateway SDK (Stripe, Razorpay, etc.)

3.3 Payment Processing Screen (PaymentProcessingScreen)
Purpose: Show payment in progress

UI Components:

Loading animation
"Processing payment..." text
"Please don't close this screen" message
Progress indicator
API Integration:

Dart
// Create payment record
POST /api/v1/payments
Body: {
orderId,
userId,
paymentAmount,
paymentMethod,
transactionId
}

// Process payment
PUT /api/v1/payments/{paymentId}/process
Body: {transactionId, paymentMethod}

// Get payment status (polling)
GET /api/v1/payments/{paymentId}
3.4 Payment Success/Failure Screen
Purpose: Show payment result

Success UI:

Success animation (Lottie checkmark)
"Payment Successful!" text
Transaction ID (copyable)
Amount paid
Payment method used
"Download Receipt" button
"Track Order" button
Failure UI:

Error animation (Lottie cross/warning)
"Payment Failed" text
Reason for failure
"Retry Payment" button
"Choose Different Method" button
"Cancel Order" button
3.5 Payment History Screen (PaymentHistoryScreen)
Purpose: View past payments

UI Components:

AppBar with "Payment History" title
Filter options: All | Completed | Pending | Failed | Refunded
Payment list (paginated):
Payment card with:
Order ID
Amount
Payment method icon + name
Transaction ID
Date/time
Status badge
"View Receipt" button
Empty state
API Integration:

Dart
// Get user payments
GET /api/v1/payments/user/{userId}?page={page}&size={size}&status={status}

// Get payment statistics
GET /api/v1/payments/stats/user/{userId}
4. DELIVERY TRACKING MODULE
   4.1 Live Delivery Tracking Screen (DeliveryTrackingScreen)
   Purpose: Real-time order tracking

UI Components:

Map view (Google Maps/Mapbox) showing:
Kitchen location (marker with kitchen icon)
Delivery partner location (marker with bike/scooter icon, animated)
Customer location (marker with home icon)
Route polyline from kitchen → customer
ETA overlay
Bottom sheet (draggable):
Order status timeline (compact)
Delivery partner card:
Profile photo
Name and rating (stars)
Phone number with "Call" button
Vehicle number
ETA countdown timer (large, prominent)
Example: "Arriving in 12 minutes"
Current status text (e.g., "Rajesh is on the way")
Order items summary (collapsed, expandable)
"Need Help?" button
API Integration:

Dart
// Get delivery details
GET /api/v1/deliveries/order/{orderId}

// Poll for location updates (every 10-15 seconds)
GET /api/v1/deliveries/{deliveryId}

// WebSocket connection for real-time updates (preferred)
ws://localhost:8086/ws/deliveries/{deliveryId}
Real-time Updates:

Use WebSocket for live location updates
Fallback to polling (every 15 seconds) if WebSocket unavailable
Update map markers smoothly (animated transitions)
Show delivery status changes with notifications
4.2 Delivery History Screen (DeliveryHistoryScreen)
Purpose: View past deliveries

UI Components:

List of completed deliveries
Each card shows:
Order ID
Kitchen name
Delivery date/time
Delivery partner name
Delivery time (actual vs estimated)
Status badge
"View Details" button
API Integration:

Dart
// Get user deliveries
GET /api/v1/deliveries/user/{userId}?page={page}&size={size}
4.3 Delivery Partner Rating Bottom Sheet
Purpose: Rate delivery partner after delivery

UI Components:

Delivery partner info (name, photo)
Star rating selector (1-5 stars)
Feedback categories (checkboxes):
On-time delivery
Friendly behavior
Proper packaging
Safe delivery
Comments text field (optional)
"Submit Rating" button
"Skip" button
TECHNICAL REQUIREMENTS
1. State Management
   Preferred: Provider + ChangeNotifier OR Bloc/Cubit

Required Providers/Blocs:

CartProvider - Cart state, CRUD operations
OrderProvider - Orders list, order details, status updates
PaymentProvider - Payment methods, transaction status
DeliveryProvider - Delivery tracking, location updates
AuthProvider - User authentication, JWT token management
CouponProvider - Available coupons, validation
2. API Service Layer
   Create service classes for each module:

Dart
// cart_service.dart
class CartService {
Future<Cart> getCart();
Future<Cart> addToCart(AddToCartRequest request);
Future<Cart> updateCartItem(int cartItemId, UpdateCartItemRequest request);
Future<void> removeCartItem(int cartItemId);
Future<void> clearCart();
Future<Cart> applyCoupon(String couponCode);
Future<Cart> removeCoupon();
Future<Cart> refreshCart();
Future<ValidationResult> validateCart();
}

// order_service.dart
class OrderService {
Future<Order> createOrder(CreateOrderRequest request);
Future<Order> createOrderFromCart(CreateOrderFromCartRequest request);
Future<Order> getOrder(int orderId);
Future<PaginatedOrders> getMyOrders(int page, int size);
Future<Order> cancelOrder(int orderId);
}

// payment_service.dart
class PaymentService {
Future<Payment> createPayment(CreatePaymentRequest request);
Future<Payment> processPayment(int paymentId, ProcessPaymentRequest request);
Future<Payment> getPayment(int paymentId);
Future<Payment> getPaymentByOrder(int orderId);
Future<PaginatedPayments> getUserPayments(int userId, int page, int size);
}

// delivery_service.dart
class DeliveryService {
Future<Delivery> getDeliveryByOrder(int orderId);
Future<Delivery> getDelivery(int deliveryId);
Future<PaginatedDeliveries> getUserDeliveries(int userId, int page, int size);
Stream<Delivery> trackDeliveryRealtime(int deliveryId); // WebSocket
}

// coupon_service.dart
class CouponService {
Future<List<Coupon>> getAvailableCoupons(int? kitchenId);
Future<CouponValidationResult> validateCoupon(ValidateCouponRequest request);
}
3. Models/DTOs
   Create Dart models matching the API responses:

Dart
// cart.dart
class Cart {
final int? cartId;
final int userId;
final int? kitchenId;
final String? kitchenName;
final List<CartItem> items;
final double subtotal;
final double deliveryFee;
final double discount;
final String? couponCode;
final double total;
final int itemCount;
final bool isValid;
final bool hasStockIssues;
final bool hasPriceChanges;
final List<String> warnings;
final DateTime? expiresAt;
final int? minutesUntilExpiry;

factory Cart.fromJson(Map<String, dynamic> json);
}

class CartItem {
final int cartItemId;
final int itemId;
final String itemName;
final String? itemDescription;
final String? imageUrl;
final int quantity;
final double unitPrice;
final double? originalPrice;
final double totalPrice;
final bool? priceChanged;
final double? priceDifference;
final String? priceChangeMessage;
final bool? inStock;
final int? availableStock;
final String? specialRequests;

factory CartItem.fromJson(Map<String, dynamic> json);
}

// Similar models for Order, Payment, Delivery, Coupon, etc.
4. Network Layer
   HTTP Client: Dio (with interceptors)

Interceptor Requirements:

Add JWT token to all requests (Authorization header)
Add X-User-Id or X-Kitchen-Id headers based on role
Handle 401 (refresh token or redirect to login)
Handle network errors globally
Log requests/responses (debug mode only)
Retry failed requests (3 attempts with exponential backoff)
Dart
class ApiClient {
final Dio dio;

ApiClient() : dio = Dio() {
dio.interceptors.add(AuthInterceptor());
dio.interceptors.add(LogInterceptor());
dio.interceptors.add(ErrorInterceptor());
}
}
5. Error Handling
   Error Display:

Use SnackBar for transient errors (network, validation)
Use AlertDialog for critical errors (payment failed, order cancelled)
Show inline error messages for form validation
Retry buttons for failed API calls
Error Model:

Dart
class ApiError {
final int statusCode;
final String message;
final List<String> errors;
final String? traceId;

factory ApiError.fromJson(Map<String, dynamic> json);
}
6. Loading States
   Shimmer Loading:

Use shimmer placeholders for cart items, order list, payment history
Skeleton screens for details pages
Loading Indicators:

CircularProgressIndicator for button actions
LinearProgressIndicator at top for page-level loading
Custom loading overlay for critical actions (payment processing)
7. Navigation
   Navigation Strategy: Named routes with arguments

Route Definitions:

Dart
class AppRoutes {
static const cart = '/cart';
static const checkout = '/checkout';
static const orderConfirmation = '/order-confirmation';
static const myOrders = '/my-orders';
static const orderDetails = '/order-details';
static const paymentMethod = '/payment-method';
static const cardPayment = '/card-payment';
static const paymentProcessing = '/payment-processing';
static const paymentResult = '/payment-result';
static const deliveryTracking = '/delivery-tracking';
static const paymentHistory = '/payment-history';
}
8. Caching Strategy
   Local Storage: shared_preferences or Hive

Cache:

Cart data (expire after 24 hours)
User's saved addresses
Recent orders (cache last 20 orders)
Available coupons (refresh daily)
Payment methods (cards)
9. Animations & Transitions
   Required Animations:

Hero animations for item images (menu → cart → order details)
Slide transitions for bottom sheets
Fade-in for list items (staggered animation)
Scale animation for success/error dialogs
Lottie animations for:
Empty cart state
Order confirmation success
Payment processing
Delivery tracking (bike animation)
10. Responsive Design
    Breakpoints:

Mobile: < 600px (single column)
Tablet: 600-900px (adaptive layout)
Desktop: > 900px (multi-column with side navigation)
Constraints:

Maximum content width: 600px (centered on tablets/desktop)
Minimum touch target size: 48x48 dp
Proper safe area handling (notches, bottom navigation)
UI/UX DESIGN GUIDELINES
Color Scheme
Dart
// Primary colors (food delivery theme)
const primaryColor = Color(0xFFFF5722); // Deep Orange
const secondaryColor = Color(0xFF4CAF50); // Green
const accentColor = Color(0xFFFFC107); // Amber

// Status colors
const pendingColor = Color(0xFFFF9800); // Orange
const confirmedColor = Color(0xFF2196F3); // Blue
const preparingColor = Color(0xFF9C27B0); // Purple
const readyColor = Color(0xFF00BCD4); // Cyan
const outForDeliveryColor = Color(0xFFFF5722); // Deep Orange
const deliveredColor = Color(0xFF4CAF50); // Green
const cancelledColor = Color(0xFFF44336); // Red
const failedColor = Color(0xFFE91E63); // Pink

// Background colors
const backgroundColor = Color(0xFFF5F5F5);
const cardColor = Colors.white;
const dividerColor = Color(0xFFE0E0E0);
Typography
Dart
// Text styles
const titleLarge = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
const titleMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
const caption = TextStyle(fontSize: 12, color: Colors.grey);
Spacing
Dart
// Consistent spacing
const spacingXS = 4.0;
const spacingS = 8.0;
const spacingM = 16.0;
const spacingL = 24.0;
const spacingXL = 32.0;

// Border radius
const radiusS = 4.0;
const radiusM = 8.0;
const radiusL = 16.0;
const radiusXL = 24.0;
Icons
Use Material Icons + Custom SVG Icons:

Cart: Icons.shopping_cart
Order: Icons.receipt_long
Payment: Icons.payment
Delivery: Icons.delivery_dining
Success: Icons.check_circle
Error: Icons.error
Warning: Icons.warning_amber
Location: Icons.location_on
TESTING REQUIREMENTS
Unit Tests
Test service layer methods
Test model serialization/deserialization
Test providers/blocs state management
Widget Tests
Test UI components in isolation
Test form validation
Test navigation flows
Integration Tests
Test cart → checkout → order flow
Test payment processing flow
Test delivery tracking flow
DELIVERABLES
Phase 1: Cart Management (Week 1)
Cart screen with CRUD operations
Coupon bottom sheet
Cart validation and warnings
Cart expiration handling
Phase 2: Order Management (Week 2)
Checkout screen with delivery details
Order confirmation screen
My orders screen with pagination
Order details screen with status timeline
Phase 3: Payment Integration (Week 3)
Payment method selection
Card payment screen
Payment processing and result screens
Payment history screen
Phase 4: Delivery Tracking (Week 4)
Live delivery tracking with map
Real-time location updates
Delivery history
Delivery partner rating
Phase 5: Polish & Testing (Week 5)
Error handling and edge cases
Loading states and animations
Unit and integration tests
Performance optimization
UI/UX refinements
EXAMPLE CODE STRUCTURE
Code
lib/
├── main.dart
├── app/
│   ├── routes.dart
│   ├── themes.dart
│   └── constants.dart
├── models/
│   ├── cart.dart
│   ├── order.dart
│   ├── payment.dart
│   ├── delivery.dart
│   └── coupon.dart
├── services/
│   ├── api_client.dart
│   ├── cart_service.dart
│   ├── order_service.dart
│   ├── payment_service.dart
│   ├── delivery_service.dart
│   └── coupon_service.dart
├── providers/
│   ├── cart_provider.dart
│   ├── order_provider.dart
│   ├── payment_provider.dart
│   └── delivery_provider.dart
├── screens/
│   ├── cart/
│   │   ├── cart_screen.dart
│   │   ├── widgets/
│   │   │   ├── cart_item_card.dart
│   │   │   ├── cart_summary.dart
│   │   │   └── coupon_bottom_sheet.dart
│   ├── order/
│   │   ├── checkout_screen.dart
│   │   ├── order_confirmation_screen.dart
│   │   ├── my_orders_screen.dart
│   │   ├── order_details_screen.dart
│   │   └── widgets/
│   │       ├── order_card.dart
│   │       ├── order_status_timeline.dart
│   │       └── address_form.dart
│   ├── payment/
│   │   ├── payment_method_screen.dart
│   │   ├── card_payment_screen.dart
│   │   ├── payment_processing_screen.dart
│   │   ├── payment_result_screen.dart
│   │   └── payment_history_screen.dart
│   └── delivery/
│       ├── delivery_tracking_screen.dart
│       ├── delivery_history_screen.dart
│       └── widgets/
│           ├── delivery_map.dart
│           ├── delivery_partner_card.dart
│           └── delivery_rating_sheet.dart
├── widgets/
│   ├── loading_indicator.dart
│   ├── error_widget.dart
│   ├── empty_state.dart
│   └── custom_button.dart
└── utils/
├── validators.dart
├── formatters.dart
└── extensions.dart
ADDITIONAL NOTES
Backend Base URLs:

Dart
const cartBaseUrl = 'http://localhost:8084/api/v1';
const orderBaseUrl = 'http://localhost:8080/api/v1';
const paymentBaseUrl = 'http://localhost:8085/api/v1';
const deliveryBaseUrl = 'http://localhost:8086/api/v1';
const couponBaseUrl = 'http://localhost:8087/api/v1';
Test Data:

Use mock item IDs: 1, 2, 3, 4, 5, 6 (from CART_API_IMPLEMENTATION.md)
Use test coupon codes: SAVE10, SAVE20, SAVE5, FREESHIP, WELCOME
Use mock kitchen IDs: 1, 2, 3, 4, 5
Use mock user ID: 1 for testing
Stock Validation:

Item ID 5 has limited stock (3 units, max order: 2)
Item ID 6 is out of stock
Show appropriate error messages from API
Cart Expiration:

Carts expire after 24 hours (configurable)
Show warning 2 hours before expiry
Use countdown timer in cart screen
Order Status Flow:

Code
PENDING → CONFIRMED → PREPARING → READY →
OUT_FOR_DELIVERY → DELIVERED

(Can cancel from PENDING or CONFIRMED)
Payment Methods:

CREDIT_CARD
DEBIT_CARD
NET_BANKING
WALLET (UPI/PayTM/PhonePe/GooglePay)
CASH_ON_DELIVERY
Delivery Status Flow:

Code
PENDING → ASSIGNED → PICKED_UP →
IN_TRANSIT → DELIVERED

(Can fail at any stage)
SUCCESS CRITERIA
✅ User can add items to cart with stock validation
✅ User can apply/remove coupons with validation
✅ Cart shows expiration warnings and price changes
✅ User can checkout with delivery details
✅ User can view order history with pagination
✅ User can track order status in real-time
✅ User can select payment method and complete payment
✅ User can track live delivery on map
✅ User can view payment history
✅ User can cancel orders (within allowed status)
✅ All API integrations working correctly
✅ Proper error handling for all edge cases
✅ Smooth animations and transitions
✅ Responsive design for mobile and tablet
✅ Loading states for all async operations
✅ Unit tests for critical business logic

Generate the Flutter UI code based on this comprehensive specification.