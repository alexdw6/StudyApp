import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static const int _version = 3;
  static const String _dbName = 'questions.db';

  late Database database;

  Future<void> initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE questions (
              id INTEGER PRIMARY KEY,
              question_text TEXT NOT NULL,
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              got_correct INTEGER NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE choices (
              id INTEGER PRIMARY KEY,
              question_id INT REFERENCES questions(id) ON DELETE CASCADE,
              choice_text TEXT NOT NULL,
              is_correct INTEGER DEFAULT 0
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
            FOREIGN KEY (question_id) REFERENCES questions (id)
          ) 
        ''');

        await db.execute('''
          CREATE TABLE subjects (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE subject_groups (
            subject_id INTEGER,
            group_id INTEGER,
            PRIMARY KEY (subject_id, group_id),
            FOREIGN KEY (subject_id) REFERENCES subjects (id),
            FOREIGN KEY (group_id) REFERENCES groups (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if(oldVersion < newVersion) {
          await db.execute('''
            ALTER TABLE choices ADD COLUMN explanation TEXT
          ''');
        }
      },
      version: _version,
    );
  }
}