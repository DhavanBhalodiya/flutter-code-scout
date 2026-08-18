import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable cached image widget with shimmer placeholder and graceful fallback.
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => Container(
              width: width,
              height: height,
              color: AppColors.shimmerBase,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.shimmerHighlight),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          )
        : _buildPlaceholder();

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceElevated,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.textMuted,
          size: 32,
        ),
      ),
    );
  }
}
