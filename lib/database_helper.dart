import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tictactoe.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE games(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      winner TEXT
    )
    ''');
  }

  Future<int> insertGame(String winner) async {
    final db = await instance.database;

    final data = {'winner': winner};
    return await db.insert('games', data);
  }

  Future<List<Map<String, dynamic>>> fetchGames() async {
    final db = await instance.database;

    return await db.query('games');
  }
}