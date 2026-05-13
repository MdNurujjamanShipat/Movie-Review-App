import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:movie_review_app/core/app_strings.dart';
import 'package:movie_review_app/data/model/movie_model.dart';
import 'package:movie_review_app/domain/entities/movie.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<Movie>> getTrendingMovies() async {
    final url = Uri.parse('${AppStrings.baseUrl}/trending/all/week');
    debugPrint('GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': AppStrings.authorizationToken,
        'accept': 'application/json',
      },
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    final url = Uri.parse('${AppStrings.baseUrl}/movie/popular');
    debugPrint('GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': AppStrings.authorizationToken,
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final url = Uri.parse('${AppStrings.baseUrl}/movie/upcoming');
    debugPrint('GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': AppStrings.authorizationToken,
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse('${AppStrings.baseUrl}/search/movie?query=$query');
    debugPrint('GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': AppStrings.authorizationToken,
        'accept': 'application/json',
      },
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final url = Uri.parse('${AppStrings.baseUrl}/movie/$movieId');
    debugPrint('GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': AppStrings.authorizationToken,
        'accept': 'application/json',
      },
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<bool> rateMovie(int movieId, double rating) async {
    final url = Uri.parse('${AppStrings.baseUrl}/movie/$movieId/rating');
    debugPrint('POST $url');

    final response = await http.post(
      url,
      headers: {
        'Authorization': AppStrings.authorizationToken,
        'accept': 'application/json',
        'Content-Type': 'application/json;charset=utf-8',
      },
      body: jsonEncode({'value': rating}),
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['status_message'] ?? 'Failed to rate movie');
    }
  }

  Future<bool> deleteRating(int movieId) async {
    final url = Uri.parse('${AppStrings.baseUrl}/movie/$movieId/rating');
    debugPrint('DELETE $url');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': AppStrings.authorizationToken,
        'accept': 'application/json',
      },
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['status_message'] ?? 'Failed to delete rating');
    }
  }
}
