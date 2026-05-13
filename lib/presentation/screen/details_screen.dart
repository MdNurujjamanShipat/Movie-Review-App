import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_review_app/core/app_colors.dart';
import 'package:movie_review_app/core/app_strings.dart';
import 'package:movie_review_app/domain/entities/movie.dart';
import 'package:movie_review_app/presentation/provider/favorites_provider.dart';
import 'package:movie_review_app/presentation/provider/movie_provider.dart';
import 'package:provider/provider.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.movie});
  final Movie movie;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Map<String, dynamic>? movieDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  void _fetchMovieDetails() async {
    final details = await Provider.of<MovieProvider>(
      context,
      listen: false,
    ).fetchMovieDetails(widget.movie.id);
    if (mounted) {
      setState(() {
        movieDetails = details;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(widget.movie.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movie.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
            ),
            onPressed: () {
              favoritesProvider.toggleFavorite(widget.movie.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav ? 'Removed from favorites' : 'Added to favorites',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surface,
            expandedHeight: 300,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.movie.backdropPath != null
                  ? CachedNetworkImage(
                      imageUrl:
                          '${AppStrings.imageBaseUrl}${widget.movie.backdropPath}',
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl:
                          '${AppStrings.imageBaseUrl}${widget.movie.posterPath}',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.movie.voteAverage} • ${widget.movie.releaseDate}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 24),
                  if (movieDetails != null && movieDetails!['genres'] != null)
                    Wrap(
                      spacing: 8,
                      children: (movieDetails!['genres'] as List)
                          .map(
                            (genre) => Chip(
                              label: Text(genre['name']),
                              backgroundColor: AppColors.accent,
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
