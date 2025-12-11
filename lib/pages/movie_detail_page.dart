import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie_detail.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/info_card.dart';
import '../routes/app_routes.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(
        context,
        listen: false,
      ).fetchMovieDetails(widget.movieId);
    });
  }

  Future<void> _launchTrailer(String? youtubeUrl) async {
    if (youtubeUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No trailer available')));
      return;
    }

    final Uri url = Uri.parse(youtubeUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch trailer')),
        );
      }
    }
  }

  void _showFavoriteNotification(bool wasRemoved) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, -20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: wasRemoved ? Colors.red.shade700 : Colors.green.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    wasRemoved ? Icons.heart_broken : Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      wasRemoved
                          ? 'Removed from favorites'
                          : 'Added to favorites',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          // Loading State
          if (provider.detailState == MovieState.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFB800)),
            );
          }

          // Error State
          if (provider.detailState == MovieState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load movie details',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.detailError,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchMovieDetails(widget.movieId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB800),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Success State
          final MovieDetail? movie = provider.movieDetail;
          if (movie == null) {
            return const Center(
              child: Text(
                'No movie data',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with backdrop and favorite button
                  _buildHeader(movie),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        // Tagline
                        if (movie.tagline != null && movie.tagline!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '"${movie.tagline}"',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),

                        // Genres
                        Wrap(
                          spacing: 8,
                          children: movie.genres.map((genre) {
                            return Chip(
                              label: Text(genre.name),
                              backgroundColor: const Color(0xFF1A2942),
                              labelStyle: const TextStyle(color: Colors.white),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Duration & Status
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${movie.runtime} min',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: movie.status == 'Released'
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: movie.status == 'Released'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              child: Text(
                                movie.status,
                                style: TextStyle(
                                  color: movie.status == 'Released'
                                      ? Colors.green
                                      : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Info Cards
                        Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                label: 'Rating',
                                value: movie.rating.toStringAsFixed(1),
                                icon: Icons.star,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InfoCard(
                                label: 'Release',
                                value: movie.releaseDate.split('-')[0],
                                icon: Icons.calendar_today,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                label: 'Budget',
                                value: movie.budget > 0
                                    ? '\$${(movie.budget / 1000000).toStringAsFixed(0)}M'
                                    : 'N/A',
                                icon: Icons.attach_money,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InfoCard(
                                label: 'Revenue',
                                value: movie.revenue > 0
                                    ? '\$${(movie.revenue / 1000000).toStringAsFixed(0)}M'
                                    : 'N/A',
                                icon: Icons.trending_up,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Description
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview.isNotEmpty
                              ? movie.overview
                              : 'No overview available.',
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Similar Movies Section
                        _buildSimilarMovies(provider.similarMovies),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(MovieDetail movie) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(movie.id);

        return Stack(
          children: [
            // Backdrop Image
            Container(
              height: 400,
              width: double.infinity,
              color: Colors.grey[800],
              child: movie.fullBackdropPath != null
                  ? Image.network(
                      movie.fullBackdropPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return movie.fullPosterPath != null
                            ? Image.network(
                                movie.fullPosterPath!,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.movie,
                                size: 120,
                                color: Colors.grey[600],
                              );
                      },
                    )
                  : Icon(Icons.movie, size: 120, color: Colors.grey[600]),
            ),

            // Gradient overlay
            Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Favorite Button
            Positioned(
              top: 10,
              right: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    // Convert MovieDetail to Movie for favorites
                    final movieForFavorite = Movie(
                      id: movie.id,
                      title: movie.title,
                      posterPath: movie.posterPath,
                      backdropPath: movie.backdropPath,
                      rating: movie.rating,
                      releaseDate: movie.releaseDate,
                      genreIds: movie.genres.map((g) => g.id).toList(),
                      overview: movie.overview,
                      popularity: 0,
                    );

                    final wasRemoved =
                        isFavorite; // Simpan state sebelum toggle
                    favoriteProvider.toggleFavorite(movieForFavorite);

                    // Panggil custom notification
                    _showFavoriteNotification(wasRemoved);
                  },
                ),
              ),
            ),

            // Share Button
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // Implement share functionality
                  },
                ),
              ),
            ),

            // Watch Trailer Button
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _launchTrailer(movie.youtubeTrailer?.youtubeUrl);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('WATCH TRAILER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB800),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSimilarMovies(List<Movie> similarMovies) {
    if (similarMovies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar Movies',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarMovies.length > 10 ? 10 : similarMovies.length,
            itemBuilder: (context, index) {
              final movie = similarMovies[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to detail page of similar movie
                  Navigator.pushNamed(
                    context,
                    AppRoutes.movieDetail,
                    arguments: movie.id,
                  );
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF1A2942),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Container(
                          height: 150,
                          width: 120,
                          color: Colors.grey[800],
                          child: movie.fullPosterPath != null
                              ? Image.network(
                                  movie.fullPosterPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.movie,
                                      size: 40,
                                      color: Colors.grey[600],
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.movie,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
