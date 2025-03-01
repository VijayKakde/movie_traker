import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: Column(
        children: [
          movie.posterPath.isNotEmpty
              ? Image.network("https://image.tmdb.org/t/p/w500${movie.posterPath}")
              : Icon(Icons.movie, size: 100),
          SizedBox(height: 10),
          Text(movie.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
