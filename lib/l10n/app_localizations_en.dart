// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchTitle => 'Search Movies';

  @override
  String get searchHint => 'Search by movie title...';

  @override
  String get searchEmptyTitle => 'Explore Movies';

  @override
  String get searchEmptyBody =>
      'Type a title above to search through thousands of movies.';

  @override
  String get searchLoading => 'Searching movies...';

  @override
  String get searchNoResultsTitle => 'No Results Found';

  @override
  String searchNoResultsBody(String query) {
    return 'We couldn\'t find any movies matching \"$query\".';
  }
}
