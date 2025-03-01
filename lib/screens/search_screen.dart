import 'package:flutter/material.dart';
import '../services/tmdb_api.dart';
import '../models/movie.dart';
import '../utils/constants.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;

  void searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tmdbApi = TmdbApi();
      final results = await tmdbApi.searchMovies(query);

      setState(() {
        searchResults = results;
        _isSearching = true;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search for movies...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                searchMovies('');
              },
            ),
          ),
          onChanged: searchMovies,
          autofocus: true,
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 100, color: Colors.grey.withOpacity(0.5)),
            SizedBox(height: 16),
            Text("Search for your favorite movies", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    if (_isLoading) return Center(child: CircularProgressIndicator());

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, size: 80, color: Colors.grey.withOpacity(0.5)), // FIXED: Changed from movie_off
            SizedBox(height: 16),
            Text("No movies found", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final movie = searchResults[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListTile(
            leading: movie.posterPath != null
                ? Image.network(
                    '${Constants.imageBaseUrl}${movie.posterPath}',
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                  )
                : Container(width: 60, height: 90, color: Colors.grey[300], child: Icon(Icons.image_not_supported)),
            title: Text(movie.title),
            subtitle: Text(movie.releaseDate.isNotEmpty ? movie.releaseDate : 'Unknown'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie)));
            },
          ),
        );
      },
    );
  }
}
