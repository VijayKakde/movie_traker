import 'package:flutter/material.dart';
import '../services/tmdb_api.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> movies = [];
  Set<int> watchedMovies = {};

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _loadWatchedMovies();
  }

  Future<void> _loadMovies() async {
    final fetchedMovies = await TMDBApi.fetchPopularMovies();
    setState(() {
      movies = fetchedMovies;
    });
  }

  Future<void> _loadWatchedMovies() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      watchedMovies = prefs.getStringList("watchedMovies")?.map(int.parse).toSet() ?? {};
    });
  }

  Future<void> _toggleWatched(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (watchedMovies.contains(movieId)) {
        watchedMovies.remove(movieId);
      } else {
        watchedMovies.add(movieId);
      }
      prefs.setStringList("watchedMovies", watchedMovies.map((e) => e.toString()).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Movie Tracker")),
      body: movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  leading: movie.posterPath.isNotEmpty
                      ? Image.network("https://image.tmdb.org/t/p/w200${movie.posterPath}")
                      : Icon(Icons.movie),
                  title: Text(movie.title),
                  trailing: Checkbox(
                    value: watchedMovies.contains(movie.id),
                    onChanged: (value) => _toggleWatched(movie.id),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie)),
                  ),
                );
              },
            ),
    );
  }
}
