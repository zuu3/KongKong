import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;

  AppDatabase._privateConstructor();

  static const _dbName = 'gongmae_jungseok.db';
  static const _dbVersion = 1;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bids(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            assetId INTEGER NOT NULL,
            assetTitle TEXT NOT NULL,
            userBid INTEGER NOT NULL,
            result TEXT NOT NULL,
            createdAt TEXT NOT NULL
          );
        ''');
      },
    );
    return _db!;
  }
}
