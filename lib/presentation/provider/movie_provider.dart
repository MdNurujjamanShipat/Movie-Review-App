import 'package:flutter/material.dart';
import 'package:movie_review_app/data/service/api_service.dart';
import 'package:movie_review_app/domain/entities/movie.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> _trendingMovies = [];
  List<Movie> get trendingMovies => _trendingMovies;

  List<Movie> _popularMovies = [];
  List<Movie> get popularMovies => _popularMovies;

  List<Movie> _upcomingMovies = [];
  List<Movie> get upcomingMovies => _upcomingMovies;

  List<Movie> _searchResults = [];
  List<Movie> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isRating = false;
  bool get isRating => _isRating;

  bool _isDeletingRating = false;
  bool get isDeletingRating => _isDeletingRating;

  List<Movie> get allMovies => [
    ..._trendingMovies,
    ..._popularMovies,
    ..._upcomingMovies,
  ];

  Future<void> fetchAllMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getTrendingMovies(),
        _apiService.getPopularMovies(),
        _apiService.getUpcomingMovies(),
      ]);
      _trendingMovies = results[0];
      _popularMovies = results[1];
      _upcomingMovies = results[2];
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMovies(query);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final details = await _apiService.getMovieDetails(movieId);
      _errorMessage = '';
      return details;
    } catch (e) {
      _errorMessage = e.toString();
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rateMovie(int movieId, double rating) async {
    _isRating = true;
    notifyListeners();

    try {
      final success = await _apiService.rateMovie(movieId, rating);
      _errorMessage = '';
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isRating = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRating(int movieId) async {
    _isDeletingRating = true;
    notifyListeners();

    try {
      final success = await _apiService.deleteRating(movieId);
      _errorMessage = '';
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isDeletingRating = false;
      notifyListeners();
    }
  }
}
