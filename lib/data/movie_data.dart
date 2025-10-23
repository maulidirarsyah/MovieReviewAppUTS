import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/movie.dart';

class MovieData {
  static Future<Map<String, List<Movie>>> loadMovies() async {
    final String response = await rootBundle.loadString(
      'assets/data/movies.json',
    );
    final Map<String, dynamic> data = json.decode(response);

    return {
      'trending': (data['trending'] as List)
          .map((json) => Movie.fromJson(json))
          .toList(),
      'popular': (data['popular'] as List)
          .map((json) => Movie.fromJson(json))
          .toList(),
      'upcoming': (data['upcoming'] as List)
          .map((json) => Movie.fromJson(json))
          .toList(),
    };
  }
}
