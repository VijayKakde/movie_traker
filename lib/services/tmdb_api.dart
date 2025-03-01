import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../utils/constants.dart';

class TMDBApi {
  static Future<List<Movie>> fetchPopularMovies() async {
    final url = "$BASE_URL/movie/popular?api_key=$TMDB_API_KEY";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Movie> movies = (data['results'] as List).map((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      throw Exception("Failed to load movies");
    }
  }
}
