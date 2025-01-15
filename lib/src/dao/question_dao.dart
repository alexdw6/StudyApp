import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:study_app/src/models/question.dart';

import '../services/database_manager.dart';

class QuestionDao {
  final Database _database = GetIt.I<DatabaseManager>().database;
  static const String tableName = "questions";

  QuestionDao();

  // GET ALL QUESTIONS WITHOUT CHOICES
  Future<List<Question>> getQuestions() async {
    final List<Map<String, dynamic>> questionMaps = await _database.query(tableName);
    return questionMaps.map((map) => Question.fromMap(map)).toList();
  }

  // GET QUESTION WITHOUT CHOICES
  Future<Question> getQuestion(int id) async {
    return Question.fromMap(await _database.query(tableName, where: "id: ?", whereArgs: [id]) as Map<String, dynamic>);
  }

  Future<int> createQuestion(Question question) async {
    return await _database.insert(tableName, question.toMap());
  }

  Future<void> deleteQuestion(int id) async {
    await _database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSelection(List<int> ids) async {
    await _database.delete(tableName, where: 'id in (${ids.join(',')})');
  }

  Future<void> updateQuestion(Question question) async {
    await _database.update(tableName, question.toMap(), where: 'id = ?', whereArgs: [question.id]);
  }
}
