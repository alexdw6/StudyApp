import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static const int _version = 1;
  static const String _dbName = 'questions.db';

  late Database database;

  Future<void> initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE questions (
              id SERIAL PRIMARY KEY,
              question_text TEXT NOT NULL,
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              is_correct INTEGER NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE choices (
              id SERIAL PRIMARY KEY,
              question_id INT REFERENCES questions(id) ON DELETE CASCADE,
              choice_text TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE answers (
              id SERIAL PRIMARY KEY,
              question_id INT REFERENCES questions(id) ON DELETE CASCADE,
              choice_id INT REFERENCES choices(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE groups (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE group_questions (
            group_id INTEGER,
            question_id INTEGER,
            PRIMARY KEY (group_id, question_id),
            FOREIGN KEY (group_id) REFERENCES groups (id),
            FOREIGN KEY (word_id) REFERENCES questions (id)
          ) 
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if(oldVersion < newVersion) {
          await db.execute('''
            CREATE TABLE questions (
              id SERIAL PRIMARY KEY,
              question_text TEXT NOT NULL,
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              is_correct INTEGER NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE choices (
              id SERIAL PRIMARY KEY,
              question_id INT REFERENCES questions(id) ON DELETE CASCADE,
              choice_text TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE answers (
              id SERIAL PRIMARY KEY,
              question_id INT REFERENCES questions(id) ON DELETE CASCADE,
              choice_id INT REFERENCES choices(id) ON DELETE CASCADE
            )
          ''');

          await db.execute('''
            CREATE TABLE groups (
              id INTEGER PRIMARY KEY,
              name TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE group_questions (
              group_id INTEGER,
              question_id INTEGER,
              PRIMARY KEY (group_id, question_id),
              FOREIGN KEY (group_id) REFERENCES groups (id),
              FOREIGN KEY (word_id) REFERENCES questions (id)
            ) 
          ''');
        }
      },
      version: _version,
    );
  }
}