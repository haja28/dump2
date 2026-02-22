/// Defines the type of application flavor
enum AppType {
  customer,
  kitchen,
}

/// Global app type configuration
class AppTypeConfig {
  static AppType _appType = AppType.customer;

  static AppType get appType => _appType;

  static void setAppType(AppType type) {
    _appType = type;
  }

  static bool get isCustomerApp => _appType == AppType.customer;
  static bool get isKitchenApp => _appType == AppType.kitchen;

  static String get appName {
    switch (_appType) {
      case AppType.customer:
        return 'Makan For You';
      case AppType.kitchen:
        return 'Makan Kitchen';
    }
  }
}

