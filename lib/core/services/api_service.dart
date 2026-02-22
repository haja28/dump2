import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static late Dio _dio;
  
  static Dio get dio => _dio;
  
  static Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.gatewayUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    
    if (AppConfig.enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: !AppConfig.enablePrettyJson,
        ),
      );
    }
    
    // Error interceptor
    _dio.interceptors.add(_ErrorInterceptor());
  }
  
  // Auth endpoints
  static Future<Response> register(Map<String, dynamic> data) {
    return _dio.post('${AppConfig.authEndpoint}/register', data: data);
  }
  
  static Future<Response> login(Map<String, dynamic> data) {
    return _dio.post('${AppConfig.authEndpoint}/login', data: data);
  }
  
  static Future<Response> refreshToken(String refreshToken) {
    return _dio.post(
      '${AppConfig.authEndpoint}/refresh',
      data: {'refreshToken': refreshToken},
    );
  }
  
  static Future<Response> getCurrentUser() {
    return _dio.get('${AppConfig.authEndpoint}/me');
  }
  
  // Kitchen endpoints
  static Future<Response> registerKitchen(Map<String, dynamic> data) {
    return _dio.post('${AppConfig.kitchensEndpoint}/register', data: data);
  }
  
  static Future<Response> getKitchens({
    int page = 0,
    int size = 20,
    bool? approved,
  }) {
    return _dio.get(
      AppConfig.kitchensEndpoint,
      queryParameters: {
        'page': page,
        'size': size,
        if (approved != null) 'approved': approved,
      },
    );
  }
  
  static Future<Response> getKitchenById(int id) {
    return _dio.get('${AppConfig.kitchensEndpoint}/$id');
  }
  
  static Future<Response> searchKitchens(String query, {int page = 0}) {
    return _dio.get(
      '${AppConfig.kitchensEndpoint}/search',
      queryParameters: {
        'query': query,
        'page': page,
      },
    );
  }
  
  static Future<Response> approveKitchen(int id) {
    return _dio.patch('${AppConfig.kitchensEndpoint}/$id/approve');
  }

  static Future<Response> getMyKitchen() {
    return _dio.get('${AppConfig.kitchensEndpoint}/my-kitchen');
  }

  static Future<Response> updateKitchenStatus(int id, bool isActive) {
    return _dio.patch(
      '${AppConfig.kitchensEndpoint}/$id/status',
      queryParameters: {'active': isActive ? 1 : 0},
    );
  }

  static Future<Response> updateKitchen(int id, Map<String, dynamic> data) {
    return _dio.put('${AppConfig.kitchensEndpoint}/$id', data: data);
  }

  // Menu endpoints

  /// Create a new menu item (Kitchen Owner only)
  /// Requires X-Kitchen-Id header
  static Future<Response> createMenuItem(Map<String, dynamic> data, {int? kitchenId}) {
    return _dio.post(
      AppConfig.menuItemsEndpoint,
      data: data,
      options: kitchenId != null ? Options(headers: {'X-Kitchen-Id': kitchenId}) : null,
    );
  }

  /// Get menu item by ID
  static Future<Response> getMenuItemById(int itemId) {
    return _dio.get('${AppConfig.menuItemsEndpoint}/$itemId');
  }

  /// Search menu items with filters
  static Future<Response> searchMenuItems({
    String? query,
    int? kitchenId,
    double? minPrice,
    double? maxPrice,
    bool? veg,
    bool? halal,
    int? minSpicyLevel,
    int? maxSpicyLevel,
    List<String>? labels,
    String? sort,
    int page = 0,
    int size = 20,
  }) {
    return _dio.get(
      '${AppConfig.menuItemsEndpoint}/search',
      queryParameters: {
        if (query != null) 'query': query,
        if (kitchenId != null) 'kitchenId': kitchenId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (veg != null) 'veg': veg,
        if (halal != null) 'halal': halal,
        if (minSpicyLevel != null) 'minSpicyLevel': minSpicyLevel,
        if (maxSpicyLevel != null) 'maxSpicyLevel': maxSpicyLevel,
        if (labels != null && labels.isNotEmpty) 'labels': labels.join(','),
        if (sort != null) 'sort': sort,
        'page': page,
        'size': size,
      },
    );
  }
  
  /// Get kitchen menu with pagination
  static Future<Response> getKitchenMenu(int kitchenId, {int page = 0, int size = 10}) {
    return _dio.get(
      '${AppConfig.menuItemsEndpoint}/kitchen/$kitchenId',
      queryParameters: {'page': page, 'size': size},
    );
  }
  
  /// Get all menu labels
  static Future<Response> getMenuLabels() {
    return _dio.get(AppConfig.menuLabelsEndpoint);
  }

  /// Get menu label by ID
  static Future<Response> getMenuLabelById(int labelId) {
    return _dio.get('${AppConfig.menuLabelsEndpoint}/$labelId');
  }

  /// Create a new menu label (Admin only)
  static Future<Response> createMenuLabel(String name, {String? description}) {
    return _dio.post(
      AppConfig.menuLabelsEndpoint,
      queryParameters: {
        'name': name,
        if (description != null) 'description': description,
      },
    );
  }

  /// Update a menu label (Admin only)
  static Future<Response> updateMenuLabel(int labelId, String name, {String? description}) {
    return _dio.put(
      '${AppConfig.menuLabelsEndpoint}/$labelId',
      queryParameters: {
        'name': name,
        if (description != null) 'description': description,
      },
    );
  }

  /// Deactivate a menu label (Admin only)
  static Future<Response> deactivateMenuLabel(int labelId) {
    return _dio.patch('${AppConfig.menuLabelsEndpoint}/$labelId/deactivate');
  }

  /// Update menu item
  static Future<Response> updateMenuItem(int id, Map<String, dynamic> data) {
    return _dio.put('${AppConfig.menuItemsEndpoint}/$id', data: data);
  }

  /// Deactivate menu item (soft delete)
  static Future<Response> deactivateMenuItem(int id) {
    return _dio.patch('${AppConfig.menuItemsEndpoint}/$id/deactivate');
  }

  /// Delete menu item (hard delete - if available)
  static Future<Response> deleteMenuItem(int id) {
    return _dio.delete('${AppConfig.menuItemsEndpoint}/$id');
  }

  /// Get menu item availability
  static Future<Response> getMenuItemAvailability(int id) {
    return _dio.get('${AppConfig.menuItemsEndpoint}/$id/availability');
  }

  /// Update menu item availability (quantity)
  static Future<Response> updateMenuItemAvailability(int id, int quantityAvailable) {
    return _dio.patch(
      '${AppConfig.menuItemsEndpoint}/$id/availability',
      queryParameters: {'quantityAvailable': quantityAvailable},
    );
  }

  // Order endpoints
  static Future<Response> createOrder(Map<String, dynamic> data) {
    return _dio.post(AppConfig.ordersEndpoint, data: data);
  }
  
  static Future<Response> getMyOrders({int page = 0, int size = 20}) {
    return _dio.get(
      '${AppConfig.ordersEndpoint}/my-orders',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }
  
  static Future<Response> getKitchenOrders(int kitchenId, {int page = 0}) {
    return _dio.get(
      '${AppConfig.ordersEndpoint}/kitchen/$kitchenId',
      queryParameters: {'page': page},
    );
  }

  // Get orders for the currently logged in kitchen owner
  static Future<Response> getMyKitchenOrders({int page = 0}) {
    return _dio.get(
      '${AppConfig.ordersEndpoint}/kitchen/my-orders',
      queryParameters: {'page': page},
    );
  }

  static Future<Response> getPendingOrders(int kitchenId) {
    return _dio.get('${AppConfig.ordersEndpoint}/kitchen/$kitchenId/pending');
  }
  
  static Future<Response> acceptOrder(int orderId) {
    return _dio.patch('${AppConfig.ordersEndpoint}/$orderId/accept');
  }
  
  static Future<Response> updateOrderStatus(int orderId, String status) {
    return _dio.patch(
      '${AppConfig.ordersEndpoint}/$orderId/status',
      queryParameters: {'status': status},
    );
  }
  
  static Future<Response> cancelOrder(int orderId) {
    return _dio.patch('${AppConfig.ordersEndpoint}/$orderId/cancel');
  }
  
  // Payment endpoints
  static Future<Response> createPayment(Map<String, dynamic> data) {
    return _dio.post(AppConfig.paymentsEndpoint, data: data);
  }
  
  static Future<Response> getPaymentById(int id) {
    return _dio.get('${AppConfig.paymentsEndpoint}/$id');
  }
  
  static Future<Response> getPaymentByOrderId(int orderId) {
    return _dio.get('${AppConfig.paymentsEndpoint}/order/$orderId');
  }
  
  static Future<Response> processPayment(
    int paymentId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('${AppConfig.paymentsEndpoint}/$paymentId/process', data: data);
  }
  
  static Future<Response> refundPayment(
    int paymentId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('${AppConfig.paymentsEndpoint}/$paymentId/refund', data: data);
  }
  
  static Future<Response> getUserPayments(int userId, {int page = 0}) {
    return _dio.get(
      '${AppConfig.paymentsEndpoint}/user/$userId',
      queryParameters: {'page': page},
    );
  }
  
  static Future<Response> getPaymentStats(int userId) {
    return _dio.get('${AppConfig.paymentsEndpoint}/stats/user/$userId');
  }
  
  // Delivery endpoints
  static Future<Response> createDelivery(Map<String, dynamic> data) {
    return _dio.post(AppConfig.deliveriesEndpoint, data: data);
  }
  
  static Future<Response> getDeliveryById(int id) {
    return _dio.get('${AppConfig.deliveriesEndpoint}/$id');
  }
  
  static Future<Response> getDeliveryByOrderId(int orderId) {
    return _dio.get('${AppConfig.deliveriesEndpoint}/order/$orderId');
  }
  
  static Future<Response> assignDeliveryPartner(
    int deliveryId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('${AppConfig.deliveriesEndpoint}/$deliveryId/assign', data: data);
  }
  
  static Future<Response> updatePickupStatus(
    int deliveryId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('${AppConfig.deliveriesEndpoint}/$deliveryId/pickup', data: data);
  }
  
  static Future<Response> updateInTransitStatus(
    int deliveryId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('${AppConfig.deliveriesEndpoint}/$deliveryId/in-transit', data: data);
  }
  
  static Future<Response> completeDelivery(
    int deliveryId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('${AppConfig.deliveriesEndpoint}/$deliveryId/complete', data: data);
  }
  
  static Future<Response> markDeliveryFailed(
    int deliveryId,
    Map<String, dynamic> data,
  ) {
    return _dio.put('${AppConfig.deliveriesEndpoint}/$deliveryId/failed', data: data);
  }
  
  static Future<Response> getKitchenDeliveries(
    int kitchenId, {
    int page = 0,
    String? status,
  }) {
    return _dio.get(
      '${AppConfig.deliveriesEndpoint}/kitchen/$kitchenId',
      queryParameters: {
        'page': page,
        if (status != null) 'status': status,
      },
    );
  }
  
  static Future<Response> getUserDeliveries(int userId, {int page = 0}) {
    return _dio.get(
      '${AppConfig.deliveriesEndpoint}/user/$userId',
      queryParameters: {'page': page},
    );
  }

  // Cart endpoints
  static Future<Response> getCart() {
    return _dio.get(AppConfig.cartEndpoint);
  }

  static Future<Response> addToCart(Map<String, dynamic> data) {
    return _dio.post('${AppConfig.cartEndpoint}/items', data: data);
  }

  static Future<Response> updateCartItem(int cartItemId, Map<String, dynamic> data) {
    return _dio.put('${AppConfig.cartEndpoint}/items/$cartItemId', data: data);
  }

  static Future<Response> removeCartItem(int cartItemId) {
    return _dio.delete('${AppConfig.cartEndpoint}/items/$cartItemId');
  }

  static Future<Response> clearCart() {
    return _dio.delete(AppConfig.cartEndpoint);
  }

  static Future<Response> applyCoupon(Map<String, dynamic> data) {
    return _dio.post('${AppConfig.cartEndpoint}/coupon', data: data);
  }

  static Future<Response> removeCoupon() {
    return _dio.delete('${AppConfig.cartEndpoint}/coupon');
  }

  static Future<Response> refreshCart() {
    return _dio.post('${AppConfig.cartEndpoint}/refresh');
  }

  static Future<Response> validateCart() {
    return _dio.post('${AppConfig.cartEndpoint}/validate');
  }

  static Future<Response> createOrderFromCart(Map<String, dynamic> data) {
    return _dio.post('${AppConfig.ordersEndpoint}/from-cart', data: data);
  }

  // Coupon endpoints
  static Future<Response> getAvailableCoupons({
    int? kitchenId,
    bool? active,
    int page = 0,
    int size = 20,
  }) {
    return _dio.get(
      AppConfig.couponsEndpoint,
      queryParameters: {
        if (kitchenId != null) 'kitchenId': kitchenId,
        if (active != null) 'active': active,
        'page': page,
        'size': size,
      },
    );
  }

  static Future<Response> getCouponByCode(String code) {
    return _dio.get('${AppConfig.couponsEndpoint}/$code');
  }

  static Future<Response> validateCoupon(Map<String, dynamic> data) {
    return _dio.post('${AppConfig.couponsEndpoint}/validate', data: data);
  }
}

// Auth Interceptor to add token to requests
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.getAccessToken();
    final userId = await StorageService.getUserId();
    final kitchenId = StorageService.getKitchenId();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    if (userId != null) {
      options.headers['X-User-Id'] = userId;
    }

    if (kitchenId != null) {
      options.headers['X-Kitchen-Id'] = kitchenId;
    }

    handler.next(options);
  }
}

// Error Interceptor with token refresh lock to prevent race conditions
class _ErrorInterceptor extends Interceptor {
  // Lock to prevent multiple simultaneous refresh attempts
  static bool _isRefreshing = false;
  // Completer to allow waiting requests to get the new token
  static Future<String?>? _refreshFuture;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Skip refresh logic for refresh endpoint itself to avoid infinite loop
      if (err.requestOptions.path.contains('/auth/refresh')) {
        return handler.next(err);
      }

      // Token expired, try to refresh
      final refreshToken = await StorageService.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          String? newAccessToken;

          // Check if a refresh is already in progress
          if (_isRefreshing) {
            // Wait for the existing refresh to complete
            newAccessToken = await _refreshFuture;
          } else {
            // Start a new refresh
            _isRefreshing = true;
            _refreshFuture = _performTokenRefresh(refreshToken);
            newAccessToken = await _refreshFuture;
            _isRefreshing = false;
            _refreshFuture = null;
          }

          if (newAccessToken != null) {
            // Retry the original request with new token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await ApiService.dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed, reset state
          _isRefreshing = false;
          _refreshFuture = null;
          // Logout user
          await StorageService.clearAuth();
        }
      }
    }

    handler.next(err);
  }

  // Performs the actual token refresh and returns the new access token
  static Future<String?> _performTokenRefresh(String refreshToken) async {
    try {
      final response = await ApiService.refreshToken(refreshToken);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'] as String;
        await StorageService.saveAccessToken(newAccessToken);
        await StorageService.saveRefreshToken(data['refreshToken']);
        return newAccessToken;
      }
    } catch (e) {
      // Refresh failed, logout user
      await StorageService.clearAuth();
    }
    return null;
  }
}
