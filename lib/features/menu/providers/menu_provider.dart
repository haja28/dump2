import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/menu_model.dart';
import '../../../core/services/api_service.dart';

class MenuProvider with ChangeNotifier {
  List<MenuItem> _menuItems = [];
  List<MenuLabel> _labels = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  List<MenuItem> get menuItems => _menuItems;
  List<MenuLabel> get labels => _labels;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> searchMenuItems({
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
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
    }
    
    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.searchMenuItems(
        query: query,
        kitchenId: kitchenId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        veg: veg,
        halal: halal,
        minSpicyLevel: minSpicyLevel,
        maxSpicyLevel: maxSpicyLevel,
        labels: labels,
        sort: sort,
        page: _currentPage,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data != null) {
          final List<MenuItem> newItems = (data['content'] as List?)
              ?.map((json) => MenuItem.fromJson(json))
              .toList() ?? [];

          if (refresh) {
            _menuItems = newItems;
          } else {
            _menuItems.addAll(newItems);
          }

          // Handle null 'last' field - default to true (no more items) if null
          _hasMore = !(data['last'] ?? true);
          _currentPage++;
        } else {
          // No data returned
          if (refresh) {
            _menuItems = [];
          }
          _hasMore = false;
        }
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load menu items';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching menu items: $e');
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchKitchenMenu(int kitchenId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
    }
    
    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getKitchenMenu(
        kitchenId,
        page: _currentPage,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data != null) {
          final List<MenuItem> newItems = (data['content'] as List?)
              ?.map((json) => MenuItem.fromJson(json))
              .toList() ?? [];

          if (refresh) {
            _menuItems = newItems;
          } else {
            _menuItems.addAll(newItems);
          }

          // Handle null 'last' field - default to true (no more items) if null
          _hasMore = !(data['last'] ?? true);
          _currentPage++;
        } else {
          // No data returned
          if (refresh) {
            _menuItems = [];
          }
          _hasMore = false;
        }
      }

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to load menu';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching kitchen menu: $e');
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLabels() async {
    try {
      final response = await ApiService.getMenuLabels();

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data is List) {
          _labels = data
              .map((json) => MenuLabel.fromJson(json))
              .toList();
        } else {
          _labels = [];
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching labels: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
