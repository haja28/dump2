import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/coupon_model.dart';
import '../../../core/services/api_service.dart';

class CouponProvider with ChangeNotifier {
  List<CouponModel> _coupons = [];
  List<CouponModel> _filteredCoupons = [];
  bool _isLoading = false;
  String? _error;
  int? _currentKitchenId;

  List<CouponModel> get coupons => _filteredCoupons.isEmpty ? _coupons : _filteredCoupons;
  List<CouponModel> get allCoupons => _coupons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCoupons => _coupons.isNotEmpty;
  int get couponCount => _coupons.length;

  // Fetch available coupons from API
  Future<void> fetchAvailableCoupons({int? kitchenId, bool forceRefresh = false}) async {
    // Don't fetch again if we already have coupons and not forcing refresh
    if (_coupons.isNotEmpty && !forceRefresh && _currentKitchenId == kitchenId) {
      return;
    }

    _isLoading = true;
    _error = null;
    _currentKitchenId = kitchenId;
    notifyListeners();

    try {
      final response = await ApiService.getAvailableCoupons(
        kitchenId: kitchenId,
        active: true,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data is List) {
          _coupons = data
              .map((json) => CouponModel.fromJson(json))
              .where((coupon) => coupon.isValid)
              .toList();

          // Sort by discount value (highest first)
          _coupons.sort((a, b) {
            if (a.type == CouponType.FREE_DELIVERY) return -1;
            if (b.type == CouponType.FREE_DELIVERY) return 1;
            return b.discountValue.compareTo(a.discountValue);
          });

          _filteredCoupons = [];
        } else {
          _coupons = [];
        }
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load coupons';
      _coupons = [];
    } catch (e) {
      _error = 'An unexpected error occurred';
      _coupons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get specific coupon by code
  Future<CouponModel?> getCouponByCode(String code) async {
    try {
      final response = await ApiService.getCouponByCode(code);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return CouponModel.fromJson(data);
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Coupon not found';
    } catch (e) {
      _error = 'An unexpected error occurred';
    }

    notifyListeners();
    return null;
  }

  // Validate coupon
  Future<ValidateCouponResponse?> validateCoupon({
    required String code,
    int? kitchenId,
    double? orderAmount,
  }) async {
    try {
      final request = ValidateCouponRequest(
        code: code,
        kitchenId: kitchenId,
        orderAmount: orderAmount,
      );

      final response = await ApiService.validateCoupon(request.toJson());

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return ValidateCouponResponse.fromJson(data);
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Coupon validation failed';
    } catch (e) {
      _error = 'An unexpected error occurred';
    }

    notifyListeners();
    return null;
  }

  // Filter coupons by kitchen
  void filterByKitchen(int? kitchenId) {
    if (kitchenId == null) {
      _filteredCoupons = [];
    } else {
      _filteredCoupons = _coupons
          .where((coupon) => coupon.isApplicableToKitchen(kitchenId))
          .toList();
    }
    notifyListeners();
  }

  // Search coupons by code or description
  void searchCoupons(String query) {
    if (query.isEmpty) {
      _filteredCoupons = [];
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredCoupons = _coupons
          .where((coupon) =>
              coupon.code.toLowerCase().contains(lowerQuery) ||
              coupon.description.toLowerCase().contains(lowerQuery))
          .toList();
    }
    notifyListeners();
  }

  // Get coupons by type
  List<CouponModel> getCouponsByType(CouponType type) {
    return _coupons.where((coupon) => coupon.type == type).toList();
  }

  // Get active coupons only
  List<CouponModel> getActiveCoupons() {
    return _coupons.where((coupon) => coupon.isValid).toList();
  }

  // Check if a specific coupon code exists
  bool hasCouponCode(String code) {
    return _coupons.any((coupon) =>
      coupon.code.toUpperCase() == code.toUpperCase()
    );
  }

  // Refresh coupons (force refresh)
  Future<void> refresh({int? kitchenId}) async {
    await fetchAvailableCoupons(kitchenId: kitchenId, forceRefresh: true);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data
  void clear() {
    _coupons = [];
    _filteredCoupons = [];
    _error = null;
    _currentKitchenId = null;
    notifyListeners();
  }
}

