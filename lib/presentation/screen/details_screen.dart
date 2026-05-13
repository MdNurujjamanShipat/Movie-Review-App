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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMovieDetails();
    });
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

  void _showRatingDialog() {
    double tempRating = 5.0;
    final screenContext = context;

    showDialog(
      context: screenContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Rate this movie',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.surface,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rating: ${tempRating.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  Slider(
                    value: tempRating,
                    min: 0.5,
                    max: 10.0,
                    divisions: 19,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.textSecondary,
                    label: tempRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setStateDialog(() {
                        tempRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap a star to rate quickly',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(10, (index) {
                        int starValue = index + 1;
                        return IconButton(
                          icon: Icon(
                            tempRating >= starValue
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              tempRating = starValue.toDouble();
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    final provider = Provider.of<MovieProvider>(
                      screenContext,
                      listen: false,
                    );
                    final success = await provider.rateMovie(
                      widget.movie.id,
                      tempRating,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Rating submitted!'
                                : provider.errorMessage,
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    final provider = Provider.of<MovieProvider>(
                      screenContext,
                      listen: false,
                    );
                    final success = await provider.deleteRating(
                      widget.movie.id,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? 'Rating removed!' : provider.errorMessage,
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remove Rating',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(widget.movie.id);
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movie.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rate, color: Colors.amber),
            onPressed: movieProvider.isRating || movieProvider.isDeletingRating
                ? null
                : _showRatingDialog,
            tooltip: 'Rate or remove rating',
          ),
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
                      Expanded(
                        child: Text(
                          '${widget.movie.voteAverage} • ${widget.movie.releaseDate}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
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
