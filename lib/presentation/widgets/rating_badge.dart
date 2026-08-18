import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable badge displaying the movie rating with a star icon.
class RatingBadge extends StatelessWidget {
  final double rating;
  final bool compact;

  const RatingBadge({
    super.key,
    required this.rating,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(216),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(
          color: AppColors.secondary.withAlpha(77),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 13 : 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 3),
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : 'N/A',
            style: (compact ? AppTypography.bodySmall : AppTypography.labelMedium)
                .copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
