import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../utils/constants.dart';
import 'dart:convert';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isWatched = false;

  @override
  void initState() {
    super.initState();
    _loadWatchedStatus();
  }

  Future<void> _loadWatchedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchedMovies = prefs.getStringList("watched_movies") ?? [];

    setState(() {
      isWatched = watchedMovies.contains(widget.movie.id.toString());
    });
  }

  Future<void> _toggleWatched() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchedMovies = prefs.getStringList("watched_movies") ?? [];

    setState(() {
      if (isWatched) {
        watchedMovies.remove(widget.movie.id.toString());
      } else {
        watchedMovies.add(widget.movie.id.toString());
      }
      isWatched = !isWatched;
    });

    await prefs.setStringList("watched_movies", watchedMovies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.movie.posterPath != null
                ? Image.network(
                    "${Constants.imageBaseUrl}${widget.movie.posterPath}",
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                  )
                : Container(height: 400, color: const Color.fromARGB(255, 224, 224, 224), child: Icon(Icons.image_not_supported, size: 100)),

            SizedBox(height: 16),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.movie.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),

            SizedBox(height: 8),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(widget.movie.releaseDate.isNotEmpty ? widget.movie.releaseDate : "Unknown",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Spacer(),
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(widget.movie.voteAverage.toStringAsFixed(1), style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),

            SizedBox(height: 16),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),

            SizedBox(height: 8),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.movie.overview.isNotEmpty ? widget.movie.overview : "No description available.",
                  style: TextStyle(fontSize: 16)),
            ),

            SizedBox(height: 16),

            if (widget.movie.genreIds.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: widget.movie.genreIds.map((id) {
                    return Chip(
                      label: Text(Genre.getGenreName(id)),
                      backgroundColor: Colors.deepPurple[100],
                    );
                  }).toList(),
                ),
              ),

            SizedBox(height: 16),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _toggleWatched,
                icon: Icon(isWatched ? Icons.check_circle : Icons.check_circle_outline),
                label: Text(isWatched ? "Marked as Watched" : "Mark as Watched"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWatched ? Colors.green : Colors.blue,
                ),
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
