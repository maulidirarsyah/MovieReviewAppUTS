class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final double rating;
  final String releaseDate;
  final int duration;
  final List<String> genres;
  final String description;
  final int budget;
  final int revenue;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.releaseDate,
    required this.duration,
    required this.genres,
    required this.description,
    required this.budget,
    required this.revenue,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterUrl: json['posterUrl'],
      rating: json['rating'].toDouble(),
      releaseDate: json['releaseDate'],
      duration: json['duration'],
      genres: List<String>.from(json['genres']),
      description: json['description'],
      budget: json['budget'],
      revenue: json['revenue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterUrl': posterUrl,
      'rating': rating,
      'releaseDate': releaseDate,
      'duration': duration,
      'genres': genres,
      'description': description,
      'budget': budget,
      'revenue': revenue,
    };
  }
}
