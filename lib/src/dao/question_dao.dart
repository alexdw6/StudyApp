import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:study_app/src/models/question.dart';

import '../services/database_manager.dart';

class QuestionDao {
  final Database _database = GetIt.I<DatabaseManager>().database;
  static const String tableName = "questions";

  QuestionDao();

  static const String selectQuestionsFromGroup = '''
    SELECT * FROM $tableName
    LEFT JOIN group_questions ON questions.id = group_questions.question_id
    WHERE group_questions.group_id = ?;
  ''';



  // GET ALL QUESTIONS WITHOUT CHOICES
  Future<List<Question>> getQuestions() async {
    final List<Map<String, dynamic>> results = await _database.query(tableName);
    return results.map((map) => Question.fromMap(map)).toList();
  }

  // GET QUESTION WITHOUT CHOICES
  Future<Question> getQuestion(int id) async {
    List<Map<String, dynamic>> results = await _database.query(tableName, where: "id = ?", whereArgs: [id]);
    return Question.fromMap(results.first);
  }

  Future<List<Question>> getQuestionsFromGroup(int groupId) async {
    List<Map<String, dynamic>> wordMaps = await _database.rawQuery(selectQuestionsFromGroup, [groupId]);
    return wordMaps.map((map) => Question.fromMap(map)).toList();
  }

  Future<List<Question>> getQuestionsFromListOfIds(List<int> ids) async {
    if (ids.isEmpty) {
      return [];
    }

    final placeholders = List.filled(ids.length, '?').join(', ');

    final List<Map<String, dynamic>> results = await _database.query(
      tableName,
      where: "id IN ($placeholders)",
      whereArgs: ids,
    );

    return results.map((map) => Question.fromMap(map)).toList();
  }

  Future<List<Question>> getCorrectQuestion(bool isCorrect) async {
    final List<Map<String, dynamic>> results = await _database.query(tableName, where: "got_correct = ?", whereArgs: [isCorrect ? 1 : 0]);
    return results.map((map) => Question.fromMap(map)).toList();
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

  Future<void> updateGotCorrectInBatch(List<Question> questions) async {
    Batch batch = _database.batch();

    for (var question in questions) {
      batch.update(
        'questions',
        {'got_correct': question.gotCorrect == null ? null : (question.gotCorrect! ? 1 : 0)},
        where: 'id = ?',
        whereArgs: [question.id],
      );
    }

    await batch.commit(noResult: true); // `noResult: true` for faster execution if you don't need the results.
  }
}
