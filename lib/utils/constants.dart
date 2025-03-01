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
  
  // App Constants
  static const String appName = 'FlickTrek';
  static const String watchedKey = 'watched_movies';
  static const String watchlistKey = 'watchlist_movies';
}