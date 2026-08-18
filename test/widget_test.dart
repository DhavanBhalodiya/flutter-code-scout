import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_code_scout/data/models/movie_model.dart';

void main() {
  group('MovieModel', () {
    test('should parse TVMaze show json correctly and strip HTML tags', () {
      final json = {
        'id': 1,
        'name': 'Under the Dome',
        'summary': '<p><b>Under the Dome</b> is the story of a small town...</p>',
        'image': {
          'medium': 'https://static.tvmaze.com/uploads/images/medium_portrait/81/202627.jpg',
          'original': 'https://static.tvmaze.com/uploads/images/original_untouched/81/202627.jpg'
        },
        'rating': {'average': 6.5},
        'premiered': '2013-06-24',
        'weight': 97,
      };

      final movie = MovieModel.fromJson(json);

      expect(movie.id, 1);
      expect(movie.title, 'Under the Dome');
      expect(movie.overview, 'Under the Dome is the story of a small town...');
      expect(movie.posterPath, 'https://static.tvmaze.com/uploads/images/medium_portrait/81/202627.jpg');
      expect(movie.backdropPath, 'https://static.tvmaze.com/uploads/images/original_untouched/81/202627.jpg');
      expect(movie.voteAverage, 6.5);
      expect(movie.releaseDate, '2013-06-24');
    });
  });
}
