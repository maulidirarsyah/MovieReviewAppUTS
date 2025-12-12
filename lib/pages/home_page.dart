import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      provider.fetchTrendingMovies();
      provider.fetchPopularMovies();
      provider.fetchUpcomingMovies();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header - Fixed di atas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Movie Review',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Tabs - Fixed di atas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A2942),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: BorderRadius.circular(26),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Trending'),
                  Tab(text: 'Popular'),
                  Tab(text: 'Upcoming'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Content - Scrollable penuh
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMovieSection(MovieListType.trending),
                _buildMovieSection(MovieListType.popular),
                _buildMovieSection(MovieListType.upcoming),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieSection(MovieListType type) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        MovieState state;
        List movies;
        String error;

        // Pilih state berdasarkan tipe
        switch (type) {
          case MovieListType.trending:
            state = provider.trendingState;
            movies = provider.trendingMovies;
            error = provider.trendingError;
            break;
          case MovieListType.popular:
            state = provider.popularState;
            movies = provider.popularMovies;
            error = provider.popularError;
            break;
          case MovieListType.upcoming:
            state = provider.upcomingState;
            movies = provider.upcomingMovies;
            error = provider.upcomingError;
            break;
        }

        // Loading State
        if (state == MovieState.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFB800)),
          );
        }

        // Error State
        if (state == MovieState.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Retry fetch
                      switch (type) {
                        case MovieListType.trending:
                          provider.fetchTrendingMovies();
                          break;
                        case MovieListType.popular:
                          provider.fetchPopularMovies();
                          break;
                        case MovieListType.upcoming:
                          provider.fetchUpcomingMovies();
                          break;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB800),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Success State - Empty
        if (movies.isEmpty) {
          return Center(
            child: Text(
              'No movies found',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          );
        }

        // Success State - Loaded dengan GridView yang bisa full scroll
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return MovieCard(movie: movies[index]);
          },
        );
      },
    );
  }
}

enum MovieListType { trending, popular, upcoming }
