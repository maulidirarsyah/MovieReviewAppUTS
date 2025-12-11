import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../config/api_config.dart';

class MovieService {
  // GET Trending Movies
  Future<List<Movie>> getTrendingMovies() async {
    try {
      final url = ApiConfig.getUrl(ApiConfig.trendingMovies);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // GET Popular Movies
  Future<List<Movie>> getPopularMovies() async {
    try {
      final url = ApiConfig.getUrl(ApiConfig.popularMovies);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // GET Upcoming Movies
  Future<List<Movie>> getUpcomingMovies() async {
    try {
      final url = ApiConfig.getUrl(ApiConfig.upcomingMovies);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load upcoming movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // GET Movie Details (dengan videos untuk trailer)
  Future<MovieDetail> getMovieDetails(int movieId) async {
    try {
      final url = ApiConfig.getUrl(
        '${ApiConfig.movieDetails}/$movieId',
        queryParams: {'append_to_response': 'videos'}, // Tambahkan videos
      );
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MovieDetail.fromJson(data);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // SEARCH Movies (untuk fitur pencarian)
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final url = ApiConfig.getUrl(
        ApiConfig.searchMovies,
        queryParams: {'query': query},
      );
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // GET Similar Movies
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final url = ApiConfig.getUrl(
        '${ApiConfig.movieDetails}/$movieId/similar',
      );
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load similar movies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
  