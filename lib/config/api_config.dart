class ApiConfig {
  // API Key TMDB Anda
  static const String apiKey = '423e914d6769722db7738a734fb34f69';

  // Base URL
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Endpoints
  static const String trendingMovies = '/trending/movie/week';
  static const String popularMovies = '/movie/popular';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovies = '/search/movie';
  static const String movieDetails = '/movie';

  // Helper method untuk build URL dengan API key
  static String getUrl(String endpoint, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    final params = {'api_key': apiKey, 'language': 'en-US', ...?queryParams};
    return uri.replace(queryParameters: params).toString();
  }
}
