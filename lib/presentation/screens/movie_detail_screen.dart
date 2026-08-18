import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/favorites/favorites_event.dart';
import '../blocs/movie_detail/movie_detail_bloc.dart';
import '../blocs/movie_detail/movie_detail_event.dart';
import '../blocs/movie_detail/movie_detail_state.dart';
import '../blocs/movie_search/movie_search_bloc.dart';
import '../blocs/movie_search/movie_search_event.dart';
import '../blocs/popular_movies/popular_movies_bloc.dart';
import '../blocs/popular_movies/popular_movies_event.dart';
import '../widgets/cached_image.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/rating_badge.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;
  final String? initialTitle;
  final String? initialPosterUrl;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    this.initialTitle,
    this.initialPosterUrl,
  });

  static Route<void> route({
    required int movieId,
    String? initialTitle,
    String? initialPosterUrl,
  }) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => sl<MovieDetailBloc>()..add(FetchMovieDetail(movieId)),
        child: MovieDetailScreen(
          movieId: movieId,
          initialTitle: initialTitle,
          initialPosterUrl: initialPosterUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<MovieDetailBloc, MovieDetailState>(
        listener: (context, state) {
          if (state is MovieDetailLoaded) {
            // Synchronize with global favorite and popular blocs
            context.read<PopularMoviesBloc>().add(
                  UpdateMovieFavoriteStatus(
                    movieId: state.movieDetail.id,
                    isFavorite: state.movieDetail.isFavorite,
                  ),
                );
            context.read<MovieSearchBloc>().add(
                  UpdateSearchMovieFavoriteStatus(
                    movieId: state.movieDetail.id,
                    isFavorite: state.movieDetail.isFavorite,
                  ),
                );
          }
        },
        builder: (context, state) {
          if (state is MovieDetailLoading) {
            return const LoadingIndicator(message: 'Loading movie details...');
          } else if (state is MovieDetailError) {
            return Scaffold(
              appBar: AppBar(),
              body: ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<MovieDetailBloc>()
                    .add(FetchMovieDetail(movieId)),
              ),
            );
          } else if (state is MovieDetailLoaded) {
            return _buildDetailContent(context, state.movieDetail);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, MovieDetail detail) {
    return CustomScrollView(
      slivers: [
        // Collapsible App Bar with Backdrop
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.background,
          actions: [
            IconButton(
              icon: Icon(
                detail.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: detail.isFavorite ? AppColors.primary : Colors.white,
              ),
              onPressed: () {
                context
                    .read<MovieDetailBloc>()
                    .add(ToggleMovieDetailFavorite(detail));

                // Also trigger update on FavoritesBloc
                final movie = Movie(
                  id: detail.id,
                  title: detail.title,
                  overview: detail.overview,
                  posterPath: detail.posterPath,
                  backdropPath: detail.backdropPath,
                  voteAverage: detail.voteAverage,
                  voteCount: detail.voteCount,
                  releaseDate: detail.releaseDate,
                  isFavorite: detail.isFavorite,
                );
                context.read<FavoritesBloc>().add(ToggleFavoriteMovie(movie));
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedImage(
                  imageUrl: detail.backdropUrl ?? detail.posterUrl,
                  fit: BoxFit.cover,
                ),
                // Gradient for top and bottom shading
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        AppColors.background.withAlpha(204),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.4, 0.8, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Movie Detail Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Release Year
                Text(
                  detail.title,
                  style: AppTypography.displayLarge.copyWith(fontSize: 24),
                ),
                if (detail.tagline != null && detail.tagline!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${detail.tagline}"',
                    style: AppTypography.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Meta row: Rating, Runtime, Release Date
                Row(
                  children: [
                    RatingBadge(rating: detail.voteAverage),
                    const SizedBox(width: 8),
                    Text(
                      '(${detail.voteCount} votes)',
                      style: AppTypography.bodySmall,
                    ),
                    const Spacer(),
                    if (detail.runtime != null) ...[
                      const Icon(Icons.timer_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatRuntime(detail.runtime),
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatYear(detail.releaseDate),
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Genre chips
                if (detail.genres.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: detail.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          genre,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Overview Section
                const Text(
                  'Overview',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  detail.overview.isNotEmpty
                      ? detail.overview
                      : 'No synopsis is available for this title.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Additional Info (Release Date, Status, Budget/Revenue)
                const Text(
                  'Information',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Release Date', DateFormatter.formatFullDate(detail.releaseDate)),
                if (detail.status != null && detail.status!.isNotEmpty)
                  _buildInfoRow('Status', detail.status!),
                if (detail.budget != null && detail.budget! > 0)
                  _buildInfoRow('Budget', '\$${_formatNumber(detail.budget!)}'),
                if (detail.revenue != null && detail.revenue! > 0)
                  _buildInfoRow('Revenue', '\$${_formatNumber(detail.revenue!)}'),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
