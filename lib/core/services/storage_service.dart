import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const _secureStorage = FlutterSecureStorage();
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Secure storage for tokens
  static Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: token);
  }
  
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConfig.accessTokenKey);
  }
  
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: token);
  }
  
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConfig.refreshTokenKey);
  }
  
  static Future<void> clearAuth() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    await _prefs.remove(AppConfig.userIdKey);
    await _prefs.remove(AppConfig.userDataKey);
    await _prefs.remove(AppConfig.userRoleKey);
  }
  
  // User Data
  static Future<void> saveUserId(int userId) async {
    await _prefs.setInt(AppConfig.userIdKey, userId);
  }
  
  static int? getUserId() {
    return _prefs.getInt(AppConfig.userIdKey);
  }
  
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(AppConfig.userDataKey, jsonEncode(userData));
  }
  
  static Map<String, dynamic>? getUserData() {
    final data = _prefs.getString(AppConfig.userDataKey);
    return data != null ? jsonDecode(data) : null;
  }
  
  static Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConfig.userRoleKey, role);
  }
  
  static String? getUserRole() {
    return _prefs.getString(AppConfig.userRoleKey);
  }
  
  // Cart Data
  static Future<void> saveCart(Map<String, dynamic> cart) async {
    await _prefs.setString(AppConfig.cartDataKey, jsonEncode(cart));
  }
  
  static Map<String, dynamic>? getCart() {
    final data = _prefs.getString(AppConfig.cartDataKey);
    return data != null ? jsonDecode(data) : null;
  }
  
  static Future<void> clearCart() async {
    await _prefs.remove(AppConfig.cartDataKey);
  }
  
  // Recent Searches
  static Future<void> saveRecentSearches(List<String> searches) async {
    await _prefs.setStringList(AppConfig.recentSearchesKey, searches);
  }
  
  static List<String> getRecentSearches() {
    return _prefs.getStringList(AppConfig.recentSearchesKey) ?? [];
  }
  
  static Future<void> addRecentSearch(String search) async {
    final searches = getRecentSearches();
    
    // Remove if already exists
    searches.remove(search);
    
    // Add to beginning
    searches.insert(0, search);
    
    // Keep only max items
    if (searches.length > AppConfig.maxRecentSearches) {
      searches.removeLast();
    }
    
    await saveRecentSearches(searches);
  }
  
  static Future<void> clearRecentSearches() async {
    await _prefs.remove(AppConfig.recentSearchesKey);
  }
  
  // Favorites
  static Future<void> saveFavoriteKitchens(List<int> kitchenIds) async {
    await _prefs.setStringList(
      AppConfig.favoriteKitchensKey,
      kitchenIds.map((e) => e.toString()).toList(),
    );
  }
  
  static List<int> getFavoriteKitchens() {
    final data = _prefs.getStringList(AppConfig.favoriteKitchensKey) ?? [];
    return data.map((e) => int.parse(e)).toList();
  }
  
  static Future<void> toggleFavoriteKitchen(int kitchenId) async {
    final favorites = getFavoriteKitchens();
    
    if (favorites.contains(kitchenId)) {
      favorites.remove(kitchenId);
    } else {
      favorites.add(kitchenId);
    }
    
    await saveFavoriteKitchens(favorites);
  }
  
  static bool isFavoriteKitchen(int kitchenId) {
    return getFavoriteKitchens().contains(kitchenId);
  }
  
  static Future<void> saveFavoriteItems(List<int> itemIds) async {
    await _prefs.setStringList(
      AppConfig.favoriteItemsKey,
      itemIds.map((e) => e.toString()).toList(),
    );
  }
  
  static List<int> getFavoriteItems() {
    final data = _prefs.getStringList(AppConfig.favoriteItemsKey) ?? [];
    return data.map((e) => int.parse(e)).toList();
  }
  
  static Future<void> toggleFavoriteItem(int itemId) async {
    final favorites = getFavoriteItems();
    
    if (favorites.contains(itemId)) {
      favorites.remove(itemId);
    } else {
      favorites.add(itemId);
    }
    
    await saveFavoriteItems(favorites);
  }
  
  static bool isFavoriteItem(int itemId) {
    return getFavoriteItems().contains(itemId);
  }
  
  // General methods
  static Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}
