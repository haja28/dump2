import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await StorageService.getAccessToken();
    final userData = StorageService.getUserData();
    
    if (token != null && userData != null) {
      _currentUser = User.fromJson(userData);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.register({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'role': role,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final authResponse = AuthResponse.fromJson(data);
        
        // Save tokens and user data
        await StorageService.saveAccessToken(authResponse.accessToken);
        await StorageService.saveRefreshToken(authResponse.refreshToken);
        await StorageService.saveUserId(authResponse.user.id);
        await StorageService.saveUserData(authResponse.user.toJson());
        await StorageService.saveUserRole(authResponse.user.role);
        
        _currentUser = authResponse.user;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        
        return true;
      }
      
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.login({
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final authResponse = AuthResponse.fromJson(data);
        
        // Save tokens and user data
        await StorageService.saveAccessToken(authResponse.accessToken);
        await StorageService.saveRefreshToken(authResponse.refreshToken);
        await StorageService.saveUserId(authResponse.user.id);
        await StorageService.saveUserData(authResponse.user.toJson());
        await StorageService.saveUserRole(authResponse.user.role);
        
        _currentUser = authResponse.user;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        
        return true;
      }
      
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final response = await ApiService.getCurrentUser();
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        _currentUser = User.fromJson(data);
        await StorageService.saveUserData(_currentUser!.toJson());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
    await StorageService.clearCart();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
