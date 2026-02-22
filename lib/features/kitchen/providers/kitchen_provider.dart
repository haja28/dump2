import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/kitchen_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

class KitchenProvider with ChangeNotifier {
  List<Kitchen> _kitchens = [];
  Kitchen? _selectedKitchen;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  List<Kitchen> get kitchens => _kitchens;
  Kitchen? get selectedKitchen => _selectedKitchen;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchKitchens({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
    }
    
    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getKitchens(
        page: _currentPage,
        approved: true,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List<Kitchen> newKitchens = (data['content'] as List)
            .map((json) => Kitchen.fromJson(json))
            .toList();

        if (refresh) {
          _kitchens = newKitchens;
        } else {
          _kitchens.addAll(newKitchens);
        }

        _hasMore = data['pagination']['hasNext'] ?? false;
        _currentPage++;
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load kitchens';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchKitchenById(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getKitchenById(id);

      if (response.statusCode == 200) {
        _selectedKitchen = Kitchen.fromJson(response.data['data']);
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load kitchen';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Kitchen>> searchKitchens(String query) async {
    try {
      final response = await ApiService.searchKitchens(query);

      if (response.statusCode == 200) {
        return (response.data['data']['content'] as List)
            .map((json) => Kitchen.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error searching kitchens: $e');
      return [];
    }
  }

  Future<bool> registerKitchen(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.registerKitchen(data);

      _isLoading = false;
      notifyListeners();

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to register kitchen';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Kitchen owner's own kitchen
  Kitchen? _myKitchen;
  Kitchen? get myKitchen => _myKitchen;

  Future<void> fetchMyKitchen() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getMyKitchen();

      if (response.statusCode == 200) {
        _myKitchen = Kitchen.fromJson(response.data['data']);
        // Save kitchen ID for API header usage
        await StorageService.saveKitchenId(_myKitchen!.id);
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load kitchen';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleKitchenStatus(bool isActive) async {
    try {
      if (_myKitchen == null) return false;

      final response = await ApiService.updateKitchenStatus(_myKitchen!.id, isActive);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Parse updated kitchen from response data
        final kitchenData = response.data['data'];
        if (kitchenData != null) {
          _myKitchen = Kitchen.fromJson(kitchenData);
        } else {
          // Fallback: update locally if data is not in response
          _myKitchen = _myKitchen!.copyWith(isOpen: isActive);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling kitchen status: $e');
      return false;
    }
  }

  Future<bool> updateKitchenProfile(Map<String, dynamic> data) async {
    try {
      if (_myKitchen == null) return false;

      _isLoading = true;
      notifyListeners();

      final response = await ApiService.updateKitchen(_myKitchen!.id, data);

      if (response.statusCode == 200) {
        _myKitchen = Kitchen.fromJson(response.data['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to update kitchen';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
