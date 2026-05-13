import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<int> _favoriteIds = {};

  Set<int> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      final List<int> ids = List<int>.from(jsonDecode(favoritesJson));
      _favoriteIds = ids.toSet();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> idsList = _favoriteIds.toList();
    await prefs.setString('favorites', jsonEncode(idsList));
  }

  void addFavorite(int movieId) {
    _favoriteIds.add(movieId);
    _saveFavorites();
    notifyListeners();
  }

  void removeFavorite(int movieId) {
    _favoriteIds.remove(movieId);
    _saveFavorites();
    notifyListeners();
  }

  void toggleFavorite(int movieId) {
    if (_favoriteIds.contains(movieId)) {
      removeFavorite(movieId);
    } else {
      addFavorite(movieId);
    }
  }

  bool isFavorite(int movieId) => _favoriteIds.contains(movieId);
}
