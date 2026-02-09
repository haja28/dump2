import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/cart_model.dart';
import '../../../core/services/api_service.dart';

class CartProvider with ChangeNotifier {
  CartModel? _cart;
  bool _isLoading = false;
  String? _error;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _cart == null || _cart!.isEmpty;
  bool get isNotEmpty => _cart != null && _cart!.isNotEmpty;
  int get itemCount => _cart?.itemCount ?? 0;
  double get subtotal => _cart?.subtotal ?? 0.0;
  double get deliveryFee => _cart?.deliveryFee ?? 0.0;
  double get discount => _cart?.discountAmount ?? 0.0;
  double get total => _cart?.total ?? 0.0;
  bool get isValid => _cart?.isValid ?? true;
  bool get hasWarnings => _cart?.hasWarnings ?? false;
  List<String> get warnings => _cart?.warnings ?? [];

  // Fetch cart from API
  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getCart();
      if (response.statusCode == 200) {
        final data = response.data['data'];
        _cart = CartModel.fromJson(data);
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load cart';
      if (e.response?.statusCode == 404) {
        _cart = null; // Cart doesn't exist
        _error = null;
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<bool> addItem({
    required int itemId,
    required int quantity,
    String? specialRequests,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = AddToCartRequest(
        itemId: itemId,
        quantity: quantity,
        specialRequests: specialRequests,
      );

      final response = await ApiService.addToCart(request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        _cart = CartModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to add item to cart';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update cart item quantity
  Future<bool> updateCartItem({
    required int cartItemId,
    required int quantity,
    String? specialRequests,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = UpdateCartItemRequest(
        quantity: quantity,
        specialRequests: specialRequests,
      );

      final response = await ApiService.updateCartItem(cartItemId, request.toJson());

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _cart = CartModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to update cart item';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Remove item from cart
  Future<bool> removeItem(int cartItemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.removeCartItem(cartItemId);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          _cart = CartModel.fromJson(data);
        } else {
          _cart = null; // Cart is now empty
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to remove item';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.clearCart();

      if (response.statusCode == 200) {
        _cart = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to clear cart';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Apply coupon
  Future<bool> applyCoupon(String couponCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = ApplyCouponRequest(couponCode: couponCode);
      final response = await ApiService.applyCoupon(request.toJson());

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _cart = CartModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to apply coupon';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Remove coupon
  Future<bool> removeCoupon() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.removeCoupon();

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _cart = CartModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to remove coupon';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Refresh cart (check prices and stock)
  Future<bool> refreshCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.refreshCart();

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _cart = CartModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to refresh cart';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Validate cart before checkout
  Future<bool> validateCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.validateCart();

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _cart = CartModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return _cart?.isValid ?? false;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Cart validation failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

