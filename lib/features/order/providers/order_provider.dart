import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  List<Order> get activeOrders =>
      _orders.where((order) => order.isActive).toList();
  List<Order> get completedOrders =>
      _orders.where((order) => order.isCompleted).toList();

  Future<void> fetchMyOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
    }
    
    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getMyOrders(page: _currentPage);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List<Order> newOrders = (data['content'] as List)
            .map((json) => Order.fromJson(json))
            .toList();

        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        _hasMore = !data['last'];
        _currentPage++;
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load orders';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.createOrder(orderData);

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyOrders(refresh: true);
        return true;
      }

      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to create order';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await ApiService.cancelOrder(orderId);

      if (response.statusCode == 200) {
        await fetchMyOrders(refresh: true);
        return true;
      }

      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to cancel order';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
