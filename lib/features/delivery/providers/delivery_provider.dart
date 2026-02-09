import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/delivery_model.dart';
import '../../../core/services/api_service.dart';

class DeliveryProvider with ChangeNotifier {
  List<Delivery> _deliveries = [];
  Delivery? _selectedDelivery;
  bool _isLoading = false;
  String? _error;

  List<Delivery> get deliveries => _deliveries;
  Delivery? get selectedDelivery => _selectedDelivery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDeliveryByOrderId(int orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getDeliveryByOrderId(orderId);

      if (response.statusCode == 200) {
        _selectedDelivery = Delivery.fromJson(response.data['data']);
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load delivery';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDelivery(Map<String, dynamic> deliveryData) async {
    try {
      final response = await ApiService.createDelivery(deliveryData);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to create delivery';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
