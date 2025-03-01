import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/tmdb_api.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> allMovies = [];
  List<Movie> filteredMovies = [];
  List<Movie> suggestedMovies = [];
  List<int> watchedMovieIds = []; // ✅ Store watched movie IDs
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int currentPage = 1;
  String selectedGenre = "All";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadWatchedMovies(); // ✅ Load watched movies before fetching new movies
    _scrollController.addListener(_loadMoreMovies);
  }

  /// ✅ **Load Watched Movies from SharedPreferences**
  Future<void> loadWatchedMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchedMovies = prefs.getStringList(Constants.watchedKey) ?? [];
    setState(() {
      watchedMovieIds = watchedMovies.map((id) => int.tryParse(id) ?? 0).toList();
    });
    fetchMovies();
  }

  /// ✅ **Fetch Movies & Remove Watched Movies from Recommendations**
  Future<void> fetchMovies({bool loadMore = false}) async {
    if (_isLoadingMore) return; // ✅ Prevent multiple calls

    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    final tmdbApi = TmdbApi();
    try {
      final newMovies = await tmdbApi.getPopularMovies(page: currentPage);
      final newSuggestions = await tmdbApi.getTrendingMovies(page: currentPage);

      setState(() {
        if (loadMore) {
          allMovies.addAll(newMovies.where((m) => !allMovies.contains(m))); 
          filteredMovies = List.from(allMovies);
          suggestedMovies.addAll(newSuggestions.where((m) => !suggestedMovies.contains(m))); 
          currentPage++; 
        } else {
          allMovies = newMovies;
          filteredMovies = List.from(newMovies);
          suggestedMovies = newSuggestions.where((movie) => !watchedMovieIds.contains(movie.id)).take(5).toList(); // ✅ Remove watched movies
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      print("⚠️ Error fetching movies: $e");
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadMoreMovies() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      fetchMovies(loadMore: true);
    }
  }

  void filterMovies(String genre) {
    setState(() {
      selectedGenre = genre;
      if (genre == "All") {
        filteredMovies = allMovies.where((movie) => !watchedMovieIds.contains(movie.id)).toList(); // ✅ Remove watched movies from filtered list
        return;
      }
      int? genreId = Constants.genreMap[genre];
      if (genreId == null) return;
      filteredMovies = allMovies.where((movie) => movie.genreIds.contains(genreId) && !watchedMovieIds.contains(movie.id)).toList(); // ✅ Remove watched movies
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildFilterDropdown(),
            _buildSuggestedMovies(),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildMovieGrid(filteredMovies),
            ),
            if (_isLoadingMore) Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(Constants.appName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(icon: Icon(Icons.search), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()))),
              IconButton(icon: Icon(Icons.bookmark), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WatchlistScreen()))),
              IconButton(icon: Icon(Icons.person), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text("Filter by Genre:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: selectedGenre,
            onChanged: (value) => filterMovies(value!),
            items: Constants.genreMap.keys
                .map((genre) => DropdownMenuItem(value: genre, child: Text(genre)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedMovies() {
    return suggestedMovies.isEmpty
        ? SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🔥 Suggested for You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = suggestedMovies[index];
                      return _buildMovieCard(movie);
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return GridView.builder(
      controller: _scrollController,
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie))),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('${Constants.imageBaseUrl}${movie.posterPath}', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
