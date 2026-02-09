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
  
  // Menu endpoints
  static Future<Response> createMenuItem(Map<String, dynamic> data) {
    return _dio.post(AppConfig.menuItemsEndpoint, data: data);
  }
  
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
  
  static Future<Response> getKitchenMenu(int kitchenId, {int page = 0}) {
    return _dio.get(
      '${AppConfig.menuItemsEndpoint}/kitchen/$kitchenId',
      queryParameters: {'page': page},
    );
  }
  
  static Future<Response> getMenuLabels() {
    return _dio.get(AppConfig.menuLabelsEndpoint);
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
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    if (userId != null) {
      options.headers['X-User-Id'] = userId;
    }
    
    handler.next(options);
  }
}

// Error Interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshToken = await StorageService.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          final response = await ApiService.refreshToken(refreshToken);
          
          if (response.statusCode == 200) {
            final data = response.data['data'];
            await StorageService.saveAccessToken(data['accessToken']);
            await StorageService.saveRefreshToken(data['refreshToken']);
            
            // Retry the original request
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${data['accessToken']}';
            
            final retryResponse = await ApiService.dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed, logout user
          await StorageService.clearAuth();
        }
      }
    }
    
    handler.next(err);
  }
}
