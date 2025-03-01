import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../utils/constants.dart';
import '../services/tmdb_api.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? movieDetails;
  List<dynamic> castList = [];
  bool _isLoading = true;
  bool isWatched = false;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
    checkIfWatched();
  }

  Future<void> fetchMovieDetails() async {
    final tmdbApi = TmdbApi();
    try {
      final details = await tmdbApi.getMovieDetails(widget.movie.id);
      setState(() {
        movieDetails = details;
        castList = details['credits']['cast'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print("⚠️ Error fetching movie details: $e");
      setState(() => _isLoading = false);
    }
  }

  /// ✅ Check if movie is already marked as watched
  Future<void> checkIfWatched() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchedMovies = prefs.getStringList(Constants.watchedKey) ?? [];
    setState(() {
      isWatched = watchedMovies.contains(widget.movie.id.toString());
    });
  }

  /// ✅ Toggle "Mark as Watched" and save to SharedPreferences
  Future<void> toggleWatchedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> watchedMovies = prefs.getStringList(Constants.watchedKey) ?? [];

    setState(() {
      if (isWatched) {
        watchedMovies.remove(widget.movie.id.toString());
      } else {
        watchedMovies.add(widget.movie.id.toString());
      }
      isWatched = !isWatched;
    });

    await prefs.setStringList(Constants.watchedKey, watchedMovies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieHeader(),
                  _buildMovieInfo(),
                  _buildMovieDescription(),
                  _buildMarkAsWatchedButton(), // ✅ Mark as Watched Button
                  _buildCastSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildMovieHeader() {
    return Stack(
      children: [
        Image.network(
          '${Constants.backdropBaseUrl}${widget.movie.backdropPath}',
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 30,
          left: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieInfo() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              '${Constants.imageBaseUrl}${widget.movie.posterPath}',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.movie.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Release Date: ${widget.movie.releaseDate}", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    SizedBox(width: 5),
                    Text(widget.movie.voteAverage.toString(), style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieDescription() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        movieDetails?['overview'] ?? "No description available.",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.justify,
      ),
    );
  }

  /// ✅ "Mark as Watched" Button
  Widget _buildMarkAsWatchedButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: toggleWatchedStatus,
        icon: Icon(isWatched ? Icons.check_circle : Icons.add_circle, color: Colors.white),
        label: Text(isWatched ? "Marked as Watched" : "Mark as Watched"),
        style: ElevatedButton.styleFrom(
          backgroundColor: isWatched ? Colors.green : Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCastSection() {
    return castList.isEmpty
        ? SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🎭 Cast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: castList.length,
                    itemBuilder: (context, index) {
                      final actor = castList[index];
                      return _buildActorCard(actor);
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildActorCard(dynamic actor) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: actor['profile_path'] != null
                ? Image.network(
                    '${Constants.imageBaseUrl}${actor['profile_path']}',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
          ),
          SizedBox(height: 5),
          Text(
            actor['name'] ?? "Unknown",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
