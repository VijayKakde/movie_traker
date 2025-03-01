class Movie {
  final int id;
  final String title;
  final String posterPath;
  final bool watched;

  Movie({required this.id, required this.title, required this.posterPath, this.watched = false});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] ?? '',
    );
  }
}
