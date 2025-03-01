import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../utils/constants.dart';
import 'tmdb_api.dart';

class MovieProvider with ChangeNotifier {
  final TmdbApi _api = TmdbApi();
  
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _upcomingMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _watchedMovies = [];
  List<Movie> _watchlist = [];
  
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get watchedMovies => _watchedMovies;
  List<Movie> get watchlist => _watchlist;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Initialize provider and load data from local storage
  Future<void> init() async {
    await loadSavedMovies();
    await fetchInitialData();
  }
  
  // Fetch all initial movie data
  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final popular = await _api.getPopularMovies();
      final topRated = await _api.getTopRatedMovies();
      final upcoming = await _api.getUpcomingMovies();
      final nowPlaying = await _api.getNowPlayingMovies();
      
      _popularMovies = _updateMovieStatus(popular);
      _topRatedMovies = _updateMovieStatus(topRated);
      _upcomingMovies = _updateMovieStatus(upcoming);
      _nowPlayingMovies = _updateMovieStatus(nowPlaying);
      
      _isLoading = false;
      _error = '';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Search movies
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final results = await _api.searchMovies(query);
      _searchResults = _updateMovieStatus(results);
      _isLoading = false;
      _error = '';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Toggle watched status
  Future<void> toggleWatched(Movie movie) async {
    final updatedMovie = movie.copyWith(isWatched: !movie.isWatched);
    
    if (updatedMovie.isWatched) {
      if (!_watchedMovies.any((m) => m.id == movie.id)) {
        _watchedMovies.add(updatedMovie);
      }
    } else {
      _watchedMovies.removeWhere((m) => m.id == movie.id);
    }
    
    _updateAllLists(updatedMovie);
    await _saveWatchedMovies();
    notifyListeners();
  }
  
  // Toggle watchlist status
  Future<void> toggleWatchlist(Movie movie) async {
    final updatedMovie = movie.copyWith(isInWatchlist: !movie.isInWatchlist);
    
    if (updatedMovie.isInWatchlist) {
      if (!_watchlist.any((m) => m.id == movie.id)) {
        _watchlist.add(updatedMovie);
      }
    } else {
      _watchlist.removeWhere((m) => m.id == movie.id);
    }
    
    _updateAllLists(updatedMovie);
    await _saveWatchlist();
    notifyListeners();
  }
  
  // Load saved movies from SharedPreferences
  Future<void> loadSavedMovies() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load watched movies
    final watchedJson = prefs.getStringList(Constants.watchedKey) ?? [];
    _watchedMovies = watchedJson
        .map((json) => Movie.fromJson(jsonDecode(json)))
        .toList();
    
    // Load watchlist
    final watchlistJson = prefs.getStringList(Constants.watchlistKey) ?? [];
    _watchlist = watchlistJson
        .map((json) => Movie.fromJson(jsonDecode(json)))
        .toList();
    
    notifyListeners();
  }
  
  // Save watched movies to SharedPreferences
  Future<void> _saveWatchedMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final watchedJson = _watchedMovies
        .map((movie) => jsonEncode(movie.toJson()))
        .toList();
    
    await prefs.setStringList(Constants.watchedKey, watchedJson);
  }
  
  // Save watchlist to SharedPreferences
  Future<void> _saveWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlistJson = _watchlist
        .map((movie) => jsonEncode(movie.toJson()))
        .toList();
    
    await prefs.setStringList(Constants.watchlistKey, watchlistJson);
  }
  
  // Update status based on saved lists
  List<Movie> _updateMovieStatus(List<Movie> movies) {
    return movies.map((movie) {
      final isWatched = _watchedMovies.any((m) => m.id == movie.id);
      final isInWatchlist = _watchlist.any((m) => m.id == movie.id);
      
      return movie.copyWith(
        isWatched: isWatched,
        isInWatchlist: isInWatchlist,
      );
    }).toList();
  }
  
  // Update status in all lists
  void _updateAllLists(Movie updatedMovie) {
    _popularMovies = _updateMovieInList(_popularMovies, updatedMovie);
    _topRatedMovies = _updateMovieInList(_topRatedMovies, updatedMovie);
    _upcomingMovies = _updateMovieInList(_upcomingMovies, updatedMovie);
    _nowPlayingMovies = _updateMovieInList(_nowPlayingMovies, updatedMovie);
    _searchResults = _updateMovieInList(_searchResults, updatedMovie);
    _watchedMovies = _updateMovieInList(_watchedMovies, updatedMovie);
    _watchlist = _updateMovieInList(_watchlist, updatedMovie);
  }
  
  // Update a movie in a list
  List<Movie> _updateMovieInList(List<Movie> movies, Movie updatedMovie) {
    return movies.map((movie) {
      if (movie.id == updatedMovie.id) {
        return updatedMovie;
      }
      return movie;
    }).toList();
  }
}