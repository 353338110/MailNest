import '../../core/database/app_database.dart';

class LocalSearchRepository {
  const LocalSearchRepository({required this.database});

  final AppDatabase database;

  Future<List<LocalMailSearchResult>> search(String query) {
    return database.searchLocalMail(query);
  }
}
