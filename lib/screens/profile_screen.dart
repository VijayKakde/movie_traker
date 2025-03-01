import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tmdb_api.dart';
import '../models/movie.dart';
import '../utils/constants.dart';
import 'movie_detail_screen.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Movie> watchedMovies = [];

  @override
  void initState() {
    super.initState();
    _loadWatchedMovies();
  }

  Future<void> _loadWatchedMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchedMovieIds = prefs.getStringList("watched_movies") ?? [];

    List<Movie> movies = [];
    final tmdbApi = TmdbApi();
    for (String id in watchedMovieIds) {
      final movieData = await tmdbApi.getMovieDetails(int.parse(id));
      movies.add(Movie.fromJson(movieData));
    }

    setState(() {
      watchedMovies = movies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text("Total Watched Movies", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("${watchedMovies.length}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),

          SizedBox(height: 20),

          Expanded(
            child: watchedMovies.isEmpty
                ? Center(child: Text("No watched movies yet!", style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
                    itemCount: watchedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = watchedMovies[index];
                      return ListTile(
                        leading: Image.network("${Constants.imageBaseUrl}${movie.posterPath}", width: 50, height: 75, fit: BoxFit.cover),
                        title: Text(movie.title),
                        subtitle: Text(movie.releaseDate),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie)));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
