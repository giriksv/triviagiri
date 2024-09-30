import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/single_player_quiz_model.dart';

class LocalDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'quiz.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE quizzes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT,
            optionA TEXT,
            optionB TEXT,
            optionC TEXT,
            optionD TEXT,
            correctAnswer TEXT,
            category TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertQuiz(QuizModel quiz) async {
    final db = await database;
    await db.insert('quizzes', quiz.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<QuizModel>> getQuizzesByCategory(String category) async {
    final db = await database;
    final maps =
        await db.query('quizzes', where: 'category = ?', whereArgs: [category]);
    return List.generate(maps.length, (i) {
      return QuizModel.fromMap(maps[i]);
    });
  }

  Future<void> clearAndCreateDb(List<QuizModel> quizzes) async {
    final db = await database;
    // Clear existing quizzes
    await db.execute('DROP TABLE IF EXISTS quizzes');
    // Create a new table
    await db.execute('''
      CREATE TABLE quizzes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        optionA TEXT,
        optionB TEXT,
        optionC TEXT,
        optionD TEXT,
        correctAnswer TEXT,
        category TEXT
      )
    ''');
    // Insert new quizzes
    for (var quiz in quizzes) {
      await insertQuiz(quiz);
    }
  }
}
