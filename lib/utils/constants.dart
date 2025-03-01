class Constants {
  // API Constants
  static const String apiKey = '79886f5fe22319525690c9d2e8f419ab';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/original';

  // API Endpoints
  static const String popularMoviesEndpoint = '/movie/popular';
  static const String topRatedMoviesEndpoint = '/movie/top_rated';
  static const String upcomingMoviesEndpoint = '/movie/upcoming';
  static const String nowPlayingMoviesEndpoint = '/movie/now_playing';
  static const String searchMovieEndpoint = '/search/movie';
  static const String trendingMoviesEndpoint = '/trending/movie/week';

  // App Constants
  static const String appName = 'FlickTrek';
  static const String watchedKey = 'watched_movies';
  static const String watchlistKey = 'watchlist_movies';

  // ✅ Fix: Change genreMap to Map<String, int> for filtering
  static const Map<String, int> genreMap = {
    "All": 0, // Default option (no filter)
    "Action": 28,
    "Adventure": 12,
    "Animation": 16,
    "Comedy": 35,
    "Crime": 80,
    "Documentary": 99,
    "Drama": 18,
    "Family": 10751,
    "Fantasy": 14,
    "History": 36,
    "Horror": 27,
    "Music": 10402,
    "Mystery": 9648,
    "Romance": 10749,
    "Science Fiction": 878,
    "TV Movie": 10770,
    "Thriller": 53,
    "War": 10752,
    "Western": 37
  };
}
