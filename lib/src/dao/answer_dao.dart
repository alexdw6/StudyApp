import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:study_app/src/models/answer.dart';

import '../services/database_manager.dart';

class AnswerDao {
  final Database _database = GetIt.I<DatabaseManager>().database;
  static const String tableName = "answers";

  AnswerDao();

  Future<Answer> getAnswer(int id) async {
    List<Map<String, dynamic>> results = await _database.query(tableName, where: "id = ?", whereArgs: [id]);
    return Answer.fromMap(results.first);
  }

  Future<Answer> getAnswerFromQuestionId(int questionId) async {
    List<Map<String, dynamic>> results = await _database.query(tableName, where: "question_id = ?", whereArgs: [questionId]);
    return Answer.fromMap(results.first);
  }

  Future<void> updateAnswer(Answer answer) async {
    await _database.update(tableName, answer.toMap(), where: 'id = ?', whereArgs: [answer.id]);
  }

  Future<void> deleteAnswer(int id) async {
    await _database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAnswerWithQuestionId(int questionId) async {
    await _database.delete(tableName, where: 'question_id = ?', whereArgs: [questionId]);
  }

  Future<int> createAnswer(Answer answer) async {
    return await _database.insert(tableName, answer.toMap());
  }
}