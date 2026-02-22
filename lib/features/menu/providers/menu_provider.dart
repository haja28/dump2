import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/models/menu_model.dart';
import '../../../core/services/api_service.dart';

class MenuProvider with ChangeNotifier {
  List<MenuItem> _menuItems = [];
  List<MenuLabel> _labels = [];
  MenuItem? _selectedMenuItem;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  List<MenuItem> get menuItems => _menuItems;
  List<MenuLabel> get labels => _labels;
  MenuItem? get selectedMenuItem => _selectedMenuItem;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Kitchen-specific menu management
  List<MenuItem> _kitchenMenuItems = [];
  List<MenuItem> get kitchenMenuItems => _kitchenMenuItems;

  /// Get menu item by ID
  Future<MenuItem?> getMenuItemById(int itemId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.getMenuItemById(itemId);

      _isLoading = false;
      if (response.statusCode == 200 && response.data['success'] == true) {
        final item = MenuItem.fromJson(response.data['data']);
        _selectedMenuItem = item;
        notifyListeners();
        return item;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting menu item: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

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

  void clearSelectedMenuItem() {
    _selectedMenuItem = null;
    notifyListeners();
  }

  /// Fetch kitchen menu items with pagination
  Future<void> fetchKitchenMenuItems(int kitchenId, {int page = 0, int size = 20}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getKitchenMenu(kitchenId, page: page, size: size);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          _kitchenMenuItems = (data['content'] as List?)
              ?.map((json) => MenuItem.fromJson(json))
              .toList() ?? [];
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching kitchen menu items: $e');
      _error = 'Failed to load menu items';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update menu item quantity availability
  Future<bool> updateQuantityAvailability(int itemId, int quantity) async {
    try {
      final response = await ApiService.updateMenuItemAvailability(itemId, quantity);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update local state from response
        final data = response.data['data'];
        if (data != null) {
          final updatedItem = MenuItem.fromJson(data);
          final index = _kitchenMenuItems.indexWhere((item) => item.id == itemId);
          if (index >= 0) {
            _kitchenMenuItems[index] = updatedItem;
          }
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating item availability: $e');
      return false;
    }
  }

  /// Toggle item availability (convenience method using quantity)
  Future<bool> toggleItemAvailability(int itemId, bool isAvailable) async {
    try {
      // Get current item to determine quantity
      final index = _kitchenMenuItems.indexWhere((item) => item.id == itemId);
      if (index < 0) return false;

      final currentItem = _kitchenMenuItems[index];

      // If enabling, restore to previous quantity or set to 1
      // If disabling, set quantity to 0
      final newQuantity = isAvailable ? (currentItem.quantityAvailable ?? 1) : 0;

      // Use deactivate endpoint if disabling, or update quantity if enabling
      if (!isAvailable) {
        final response = await ApiService.deactivateMenuItem(itemId);
        if (response.statusCode == 200 && response.data['success'] == true) {
          _kitchenMenuItems[index] = currentItem.copyWith(isActive: false);
          notifyListeners();
          return true;
        }
        return false;
      } else {
        // To reactivate, update the item with quantity > 0
        return updateQuantityAvailability(itemId, newQuantity > 0 ? newQuantity : 1);
      }
    } catch (e) {
      debugPrint('Error toggling item availability: $e');
      return false;
    }
  }

  /// Mark item as out of stock
  Future<bool> markOutOfStock(int itemId) async {
    return updateQuantityAvailability(itemId, 0);
  }

  /// Restock item
  Future<bool> restockItem(int itemId, int quantity) async {
    return updateQuantityAvailability(itemId, quantity);
  }

  /// Deactivate menu item (soft delete)
  Future<bool> deactivateMenuItem(int itemId) async {
    try {
      final response = await ApiService.deactivateMenuItem(itemId);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final index = _kitchenMenuItems.indexWhere((item) => item.id == itemId);
        if (index >= 0) {
          _kitchenMenuItems[index] = _kitchenMenuItems[index].copyWith(isActive: false);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deactivating menu item: $e');
      return false;
    }
  }

  /// Delete menu item (hard delete)
  Future<bool> deleteMenuItem(int itemId) async {
    try {
      final response = await ApiService.deleteMenuItem(itemId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _kitchenMenuItems.removeWhere((item) => item.id == itemId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      return false;
    }
  }

  /// Add a new menu item
  Future<bool> addMenuItem(Map<String, dynamic> data, {int? kitchenId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.createMenuItem(data, kitchenId: kitchenId);

      _isLoading = false;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true && response.data['data'] != null) {
          final newItem = MenuItem.fromJson(response.data['data']);
          _kitchenMenuItems.add(newItem);
        }
        notifyListeners();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to add menu item';
      notifyListeners();
      return false;
    } on DioException catch (e) {
      debugPrint('Error adding menu item: $e');
      _error = e.response?.data['message'] ?? 'Failed to add menu item';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error adding menu item: $e');
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing menu item
  Future<bool> updateMenuItem(int itemId, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.updateMenuItem(itemId, data);

      _isLoading = false;
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          final updatedItem = MenuItem.fromJson(response.data['data']);
          final index = _kitchenMenuItems.indexWhere((item) => item.id == itemId);
          if (index >= 0) {
            _kitchenMenuItems[index] = updatedItem;
          }
          _selectedMenuItem = updatedItem;
        }
        notifyListeners();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to update menu item';
      notifyListeners();
      return false;
    } on DioException catch (e) {
      debugPrint('Error updating menu item: $e');
      _error = e.response?.data['message'] ?? 'Failed to update menu item';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error updating menu item: $e');
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ Label Management ============

  /// Create a new menu label
  Future<MenuLabel?> createLabel(String name, {String? description}) async {
    try {
      final response = await ApiService.createMenuLabel(name, description: description);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true && response.data['data'] != null) {
          final newLabel = MenuLabel.fromJson(response.data['data']);
          _labels.add(newLabel);
          notifyListeners();
          return newLabel;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating label: $e');
      return null;
    }
  }

  /// Update an existing label
  Future<bool> updateLabel(int labelId, String name, {String? description}) async {
    try {
      final response = await ApiService.updateMenuLabel(labelId, name, description: description);

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['data'] != null) {
          final updatedLabel = MenuLabel.fromJson(response.data['data']);
          final index = _labels.indexWhere((label) => label.id == labelId);
          if (index >= 0) {
            _labels[index] = updatedLabel;
          }
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating label: $e');
      return false;
    }
  }

  /// Deactivate a label
  Future<bool> deactivateLabel(int labelId) async {
    try {
      final response = await ApiService.deactivateMenuLabel(labelId);

      if (response.statusCode == 200 && response.data['success'] == true) {
        _labels.removeWhere((label) => label.id == labelId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deactivating label: $e');
      return false;
    }
  }

  /// Get label by ID
  Future<MenuLabel?> getLabelById(int labelId) async {
    try {
      final response = await ApiService.getMenuLabelById(labelId);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return MenuLabel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting label: $e');
      return null;
    }
  }

  /// Check menu item availability
  Future<Map<String, dynamic>?> checkItemAvailability(int itemId) async {
    try {
      final response = await ApiService.getMenuItemAvailability(itemId);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'available': data['isActive'] == true && (data['quantityAvailable'] ?? 0) > 0,
          'quantity': data['quantityAvailable'] ?? 0,
          'preparationTime': data['preparationTimeMinutes'] ?? 30,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error checking item availability: $e');
      return null;
    }
  }
}
