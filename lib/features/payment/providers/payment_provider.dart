import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  Payment? _selectedPayment;
  PaymentStats? _stats;
  bool _isLoading = false;
  String? _error;

  List<Payment> get payments => _payments;
  Payment? get selectedPayment => _selectedPayment;
  PaymentStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createPayment(Map<String, dynamic> paymentData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.createPayment(paymentData);

      _isLoading = false;
      notifyListeners();

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to create payment';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPaymentByOrderId(int orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getPaymentByOrderId(orderId);

      if (response.statusCode == 200) {
        _selectedPayment = Payment.fromJson(response.data['data']);
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load payment';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processPayment(
    int paymentId,
    String transactionId,
    String paymentMethod,
  ) async {
    try {
      final response = await ApiService.processPayment(paymentId, {
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
      });

      return response.statusCode == 200;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to process payment';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
