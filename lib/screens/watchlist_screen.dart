import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../utils/constants.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Movie> watchlist = [];
  List<Movie> watchedMovies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Movies'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.bookmark), text: "Watchlist"),
            Tab(icon: Icon(Icons.check_circle), text: "Watched"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMovieList(watchlist, "No movies in your watchlist"),
          _buildMovieList(watchedMovies, "No movies marked as watched"),
        ],
      ),
    );
  }

  Widget _buildMovieList(List<Movie> movies, String emptyMessage) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, size: 80, color: Colors.grey.withOpacity(0.5)),
            SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
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
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  movies.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${movie.title} removed")));
              },
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie)));
            },
          ),
        );
      },
    );
  }
}
