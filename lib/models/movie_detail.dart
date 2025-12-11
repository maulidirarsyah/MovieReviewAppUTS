class MovieDetail {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double rating;
  final String releaseDate;
  final List<Genre> genres;
  final String overview;
  final int runtime;
  final int budget;
  final int revenue;
  final String status;
  final String? tagline;
  final List<Video>? videos; // Tambahan untuk trailer

  MovieDetail({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.rating,
    required this.releaseDate,
    required this.genres,
    required this.overview,
    required this.runtime,
    required this.budget,
    required this.revenue,
    required this.status,
    this.tagline,
    this.videos,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      rating: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genres:
          (json['genres'] as List?)?.map((g) => Genre.fromJson(g)).toList() ??
          [],
      overview: json['overview'] ?? '',
      runtime: json['runtime'] ?? 0,
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      status: json['status'] ?? '',
      tagline: json['tagline'],
      videos: json['videos'] != null
          ? (json['videos']['results'] as List?)
                ?.map((v) => Video.fromJson(v))
                .toList()
          : null,
    );
  }

  String? get fullPosterPath {
    if (posterPath == null) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String? get fullBackdropPath {
    if (backdropPath == null) return null;
    return 'https://image.tmdb.org/t/p/w500$backdropPath';
  }

  // Get YouTube trailer
  Video? get youtubeTrailer {
    if (videos == null || videos!.isEmpty) return null;
    try {
      return videos!.firstWhere(
        (video) =>
            video.site.toLowerCase() == 'youtube' &&
            video.type.toLowerCase() == 'trailer',
      );
    } catch (e) {
      // Jika tidak ada trailer, ambil video pertama
      return videos!.isNotEmpty ? videos!.first : null;
    }
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      site: json['site'] ?? '',
      type: json['type'] ?? '',
    );
  }

  // Get YouTube URL
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
}
