import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'movie_detail_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';
import 'profile_screen.dart'; // ✅ Import Profile Screen
import '../services/tmdb_api.dart';
import '../models/movie.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Movie> popularMovies = [];
  List<Movie> nowPlayingMovies = [];
  List<Movie> upcomingMovies = [];
  List<Movie> topRatedMovies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final tmdbApi = TmdbApi();
    try {
      final popMovies = await tmdbApi.getPopularMovies();
      final nowPlaying = await tmdbApi.getNowPlayingMovies();
      final upcoming = await tmdbApi.getUpcomingMovies();
      final topRated = await tmdbApi.getTopRatedMovies();

      setState(() {
        popularMovies = popMovies;
        nowPlayingMovies = nowPlaying;
        upcomingMovies = upcoming;
        topRatedMovies = topRated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(Constants.appName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                    ),
                  ),
                  child: Center(child: Icon(Icons.movie_outlined, size: 80, color: Colors.white.withOpacity(0.8))),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WatchlistScreen())),
                ),
                IconButton( // ✅ Add Profile Icon Button
                  icon: Icon(Icons.person), 
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: "Popular"),
                  Tab(text: "Now Playing"),
                  Tab(text: "Upcoming"),
                  Tab(text: "Top Rated"),
                ],
              ),
            ),
          ];
        },
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildMovieGrid(popularMovies),
                  _buildMovieGrid(nowPlayingMovies),
                  _buildMovieGrid(upcomingMovies),
                  _buildMovieGrid(topRatedMovies),
                ],
              ),
      ),
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (ctx, i) => _buildMovieCard(movies[i]),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie)),
      ),
      child: Hero(
        tag: 'movie-${movie.id}',
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: movie.posterPath != null
                    ? Image.network(
                        '${Constants.imageBaseUrl}${movie.posterPath}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(child: Icon(Icons.image_not_supported, size: 50)),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Center(child: Icon(Icons.image_not_supported, size: 50)),
                      ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(movie.voteAverage.toStringAsFixed(1), style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
