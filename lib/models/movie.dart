class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double rating;
  final String releaseDate;
  final List<int> genreIds;
  final String overview;
  final double popularity;
  final int? voteCount;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.rating,
    required this.releaseDate,
    required this.genreIds,
    required this.overview,
    required this.popularity,
    this.voteCount,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      rating: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      voteCount: json['vote_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': rating,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'overview': overview,
      'popularity': popularity,
      'vote_count': voteCount,
    };
  }

  String? get fullPosterPath {
    if (posterPath == null) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String? get fullBackdropPath {
    if (backdropPath == null) return null;
    return 'https://image.tmdb.org/t/p/w500$backdropPath';
  }

  String get year {
    if (releaseDate.isEmpty) return '';
    return releaseDate.split('-')[0];
  }
}
