/// TVMaze API Endpoints constants (Public & Free)
class ApiEndpoints {
  ApiEndpoints._();

  /// Endpoint for paginated list of all shows/movies
  static const String popularShows = '/shows';

  /// Endpoint for searching shows by query string: `/search/shows?q=:query`
  static const String searchShows = '/search/shows';

  /// Endpoint for show details by ID: `/shows/:id`
  static String showDetails(int id) => '/shows/$id';
}
