import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../models/choice.dart';
import '../services/database_manager.dart';

class ChoiceDao {
  final Database _database = GetIt.I<DatabaseManager>().database;
  static const String tableName = "choices";

  ChoiceDao();
  
  Future<void> createChoises(List<Choice> choices) async {
    Batch batch = _database.batch();
    for (var choice in choices) {
      batch.insert(tableName, choice.toMap());
    }
    await batch.commit(noResult: true);
  }
  
  Future<Choice> getChoice(int id) async {
    List<Map<String, dynamic>> results = await _database.query(tableName, where: "id = ?", whereArgs: [id]);
    return Choice.fromMap(results.first);
  }

  Future<List<Choice>> getAllChoicesWithQuestionId(int questionId) async {
    List<Map<String, dynamic>> results = await _database.query(tableName, where: "question_id = ?", whereArgs: [questionId]);
    return results.map((map) => Choice.fromMap(map)).toList();
  }

  Future<void> updateChoice(Choice choice) async {
    await _database.update(tableName, choice.toMap(), where: 'id = ?', whereArgs: [choice.id]);
  }

  Future<void> deleteChoice(int id) async {
    await _database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllWithQuestionId(int questionId) async {
    await _database.delete(tableName, where: 'question_id = ?', whereArgs: [questionId]);
  }
}