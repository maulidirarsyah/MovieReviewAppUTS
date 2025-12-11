import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../services/movie_service.dart';

enum MovieState { initial, loading, loaded, error }

class MovieProvider with ChangeNotifier {
  final MovieService _movieService = MovieService();

  // State untuk trending movies
  MovieState _trendingState = MovieState.initial;
  List<Movie> _trendingMovies = [];
  String _trendingError = '';

  // State untuk popular movies
  MovieState _popularState = MovieState.initial;
  List<Movie> _popularMovies = [];
  String _popularError = '';

  // State untuk upcoming movies
  MovieState _upcomingState = MovieState.initial;
  List<Movie> _upcomingMovies = [];
  String _upcomingError = '';

  // State untuk search
  MovieState _searchState = MovieState.initial;
  List<Movie> _searchResults = [];
  String _searchError = '';

  // State untuk movie detail
  MovieState _detailState = MovieState.initial;
  MovieDetail? _movieDetail;
  String _detailError = '';

  // State untuk similar movies
  List<Movie> _similarMovies = [];

  // Getters
  MovieState get trendingState => _trendingState;
  List<Movie> get trendingMovies => _trendingMovies;
  String get trendingError => _trendingError;

  MovieState get popularState => _popularState;
  List<Movie> get popularMovies => _popularMovies;
  String get popularError => _popularError;

  MovieState get upcomingState => _upcomingState;
  List<Movie> get upcomingMovies => _upcomingMovies;
  String get upcomingError => _upcomingError;

  MovieState get searchState => _searchState;
  List<Movie> get searchResults => _searchResults;
  String get searchError => _searchError;

  MovieState get detailState => _detailState;
  MovieDetail? get movieDetail => _movieDetail;
  String get detailError => _detailError;

  List<Movie> get similarMovies => _similarMovies;

  // Fetch Trending Movies
  Future<void> fetchTrendingMovies() async {
    _trendingState = MovieState.loading;
    notifyListeners();

    try {
      _trendingMovies = await _movieService.getTrendingMovies();
      _trendingState = MovieState.loaded;
      _trendingError = '';
    } catch (e) {
      _trendingState = MovieState.error;
      _trendingError = e.toString();
    }
    notifyListeners();
  }

  // Fetch Popular Movies
  Future<void> fetchPopularMovies() async {
    _popularState = MovieState.loading;
    notifyListeners();

    try {
      _popularMovies = await _movieService.getPopularMovies();
      _popularState = MovieState.loaded;
      _popularError = '';
    } catch (e) {
      _popularState = MovieState.error;
      _popularError = e.toString();
    }
    notifyListeners();
  }

  // Fetch Upcoming Movies
  Future<void> fetchUpcomingMovies() async {
    _upcomingState = MovieState.loading;
    notifyListeners();

    try {
      _upcomingMovies = await _movieService.getUpcomingMovies();
      _upcomingState = MovieState.loaded;
      _upcomingError = '';
    } catch (e) {
      _upcomingState = MovieState.error;
      _upcomingError = e.toString();
    }
    notifyListeners();
  }

  // Search Movies
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchState = MovieState.initial;
      notifyListeners();
      return;
    }

    _searchState = MovieState.loading;
    notifyListeners();

    try {
      _searchResults = await _movieService.searchMovies(query);
      _searchState = MovieState.loaded;
      _searchError = '';
    } catch (e) {
      _searchState = MovieState.error;
      _searchError = e.toString();
    }
    notifyListeners();
  }

  // Fetch Movie Details
  Future<void> fetchMovieDetails(int movieId) async {
    _detailState = MovieState.loading;
    notifyListeners();

    try {
      _movieDetail = await _movieService.getMovieDetails(movieId);
      _similarMovies = await _movieService.getSimilarMovies(movieId);
      _detailState = MovieState.loaded;
      _detailError = '';
    } catch (e) {
      _detailState = MovieState.error;
      _detailError = e.toString();
    }
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchResults = [];
    _searchState = MovieState.initial;
    _searchError = '';
    notifyListeners();
  }
}
