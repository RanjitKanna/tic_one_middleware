import 'package:tic_one_middleware/database.dart';

Future<void> main() async {
  final connection = await openDatabaseConnection();

  try {
    final result = await connection.execute(
      'SELECT id, movie_code, title, language, genre, rating, badge_text, match_percent, is_filling_fast, image_url FROM movies ORDER BY id ASC',
    );

    print('==================================================');
    print('TOTAL MOVIES IN DATABASE: ${result.length}');
    print('==================================================');

    final languageCounts = <String, int>{};

    for (final row in result) {
      final id = row[0];
      final code = row[1];
      final title = row[2];
      final lang = row[3] as String;
      final rating = row[5];
      final badge = row[6];
      final match = row[7];
      final filling = row[8];

      languageCounts[lang] = (languageCounts[lang] ?? 0) + 1;

      print('[$id] $title ($code) | Lang: $lang | Rating: $rating | Badge: $badge | Match: $match | FillingFast: $filling');
    }

    print('\n--- Breakdown by Language ---');
    languageCounts.forEach((lang, count) {
      print('• $lang: $count movies');
    });

  } finally {
    await connection.close();
  }
}
