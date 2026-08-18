import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/movie.dart';
import 'cached_image.dart';
import 'rating_badge.dart';

/// Reusable horizontal movie tile widget for search results and favorites list.
class MovieListTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const MovieListTile({
    super.key,
    required this.movie,
    required this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster thumbnail
            CachedImage(
              imageUrl: movie.posterUrl,
              width: 80,
              height: 120,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 14),

            // Movie Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: AppTypography.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBadge(
                        rating: movie.voteAverage,
                        compact: true,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormatter.formatYear(movie.releaseDate),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : 'No description available.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Optional favorite action button
            if (onFavoriteToggle != null)
              IconButton(
                iconSize: 22,
                icon: Icon(
                  movie.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: movie.isFavorite ? AppColors.primary : AppColors.textMuted,
                ),
                onPressed: onFavoriteToggle,
              ),
          ],
        ),
      ),
    );
  }
}
