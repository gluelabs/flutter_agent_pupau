class NativeDatabaseRegistryService {
  static final Map<int, String> _namesById = <int, String>{};

  static void upsertDatabaseName({
    required int databaseId,
    required String databaseName,
  }) {
    final int id = databaseId;
    final String name = databaseName.trim();
    if (id <= 0 || name.isEmpty) return;
    _namesById[id] = name;
  }

  static String? getDatabaseName(int databaseId) => _namesById[databaseId];
}

