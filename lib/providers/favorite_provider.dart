import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/movie.dart';

class FavoriteProvider with ChangeNotifier {
  List<Movie> _favorites = [];
  static const String _favoritesKey = 'favorites';

  List<Movie> get favorites => _favorites;

  FavoriteProvider() {
    loadFavorites();
  }

  // Load favorites dari SharedPreferences
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((item) => Movie.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Save favorites ke SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _favorites.map((movie) => movie.toJson()).toList(),
      );
      await prefs.setString(_favoritesKey, encoded);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Check if movie is favorite
  bool isFavorite(int movieId) {
    return _favorites.any((movie) => movie.id == movieId);
  }

  // Toggle favorite
  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      _favorites.add(movie);
    }
    await _saveFavorites();
    notifyListeners();
  }

  // Add to favorites
  Future<void> addToFavorites(Movie movie) async {
    if (!isFavorite(movie.id)) {
      _favorites.add(movie);
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(int movieId) async {
    _favorites.removeWhere((movie) => movie.id == movieId);
    await _saveFavorites();
    notifyListeners();
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();
  }
}
