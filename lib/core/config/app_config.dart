class AppConfig {
  // App Information
  static const String appName = 'Makan For You';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://192.168.1.6:8080';
  static const String apiVersion = 'v1';

  static const String apiBasePath = '/api/$apiVersion';
  
  // Service URLs
  static const String authServiceUrl = 'http://192.168.1.6:8081';
  static const String kitchenServiceUrl = 'http://192.168.1.6:8082';
  static const String menuServiceUrl = 'http://192.168.1.6:8083';
  static const String orderServiceUrl = 'http://192.168.1.6:8084';
  static const String paymentServiceUrl = 'http://192.168.1.6:8085';
  static const String deliveryServiceUrl = 'http://192.168.1.6:8086';
  static const String chatServiceUrl = 'http://192.168.1.6:8086';
  static const String chatWsUrl = 'http://192.168.1.6:8086/ws/chat';

  // Gateway URL (All requests go through this)
  static const String gatewayUrl = baseUrl + apiBasePath;
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String kitchensEndpoint = '/kitchens';
  static const String menuItemsEndpoint = '/menu-items';
  static const String ordersEndpoint = '/orders';
  static const String cartEndpoint = '/cart';
  static const String paymentsEndpoint = '/payments';
  static const String deliveriesEndpoint = '/deliveries';
  static const String menuLabelsEndpoint = '/menu-labels';
  static const String conversationsEndpoint = '/conversations';
  static const String notificationsEndpoint = '/notifications';
  static const String couponsEndpoint = '/coupons';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String kitchenIdKey = 'kitchen_id';
  static const String cartDataKey = 'cart_data';
  static const String recentSearchesKey = 'recent_searches';
  static const String favoriteKitchensKey = 'favorite_kitchens';
  static const String favoriteItemsKey = 'favorite_items';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int searchPageSize = 10;
  static const int maxPageSize = 50;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Image Configuration
  static const int maxImageSizeKB = 2048;
  static const int imageQuality = 85;
  
  // Map Configuration
  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 77.5946;
  static const double defaultZoom = 14.0;
  
  // Orders
  static const int orderHistoryDays = 90;
  static const Duration orderRefreshInterval = Duration(seconds: 30);
  
  // Search
  static const int maxRecentSearches = 10;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  
  // Rating
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  
  // Price Range
  static const double minPrice = 0.0;
  static const double maxPrice = 1000.0;
  
  // Spicy Level
  static const int minSpicyLevel = 1;
  static const int maxSpicyLevel = 5;
  
  // Delivery
  static const double deliveryChargePerKm = 2.0;
  static const double minDeliveryCharge = 5.0;
  static const double freeDeliveryAbove = 50.0;
  
  // Tax and Service
  static const double taxPercentage = 0.05; // 5%
  static const double serviceChargePercentage = 0.02; // 2%
  
  // Environment
  static const bool isProduction = false;
  static const bool enableLogging = true;
  static const bool enablePrettyJson = true;
}
