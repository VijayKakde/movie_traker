import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../utils/constants.dart';

class TmdbApi {
  final String apiKey = Constants.apiKey;
  final String baseUrl = Constants.baseUrl;

  Future<Map<String, dynamic>> _get(String endpoint, {Map<String, String>? params}) async {
    Map<String, String> queryParameters = {
      'api_key': apiKey,
    };
    
    if (params != null) {
      queryParameters.addAll(params);
    }
    
    Uri uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParameters);
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final data = await _get(Constants.popularMoviesEndpoint, params: {'page': page.toString()});
    return _parseMovieList(data);
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final data = await _get(Constants.topRatedMoviesEndpoint, params: {'page': page.toString()});
    return _parseMovieList(data);
  }

  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    final data = await _get(Constants.upcomingMoviesEndpoint, params: {'page': page.toString()});
    return _parseMovieList(data);
  }

  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    final data = await _get(Constants.nowPlayingMoviesEndpoint, params: {'page': page.toString()});
    return _parseMovieList(data);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return [];
    
    final data = await _get(
      Constants.searchMovieEndpoint,
      params: {'query': query, 'page': page.toString()}
    );
    
    return _parseMovieList(data);
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    return await _get('/movie/$movieId', params: {'append_to_response': 'credits,videos,similar'});
  }

  List<Movie> _parseMovieList(Map<String, dynamic> data) {
    List<dynamic> results = data['results'];
    return results.map((movieData) => Movie.fromJson(movieData)).toList();
  }
}