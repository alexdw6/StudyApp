import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:study_app/src/models/question.dart';
import 'package:study_app/src/models/question_data.dart';

import '../services/database_manager.dart';

class QuestionDao {
  final Database _database = GetIt.I<DatabaseManager>().database;
  static const String tableName = "questions";

  QuestionDao();

  static const String selectQuestionWithChoicesAndAnswer = ''' 
    SELECT 
        q.id AS question_id,
        q.question_text,
        c.id AS choice_id,
        c.choice_text,
        ca.id AS answer_id,
    FROM 
        questions q
    LEFT JOIN 
        choices c ON q.id = c.question_id
    LEFT JOIN 
        correct_answers ca ON q.id = ca.question_id
    WHERE 
        q.id = ?;
  ''';

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

  // ADDS QUESTION WITH ANSWERS
  // Future<int> addQuestion({
  //   required String questionText,
  //   required List<String> choices,
  //   required int correctChoiceIndex,
  // }) async {
  //   return await _database.transaction<int>((txn) async {
  //     final int questionId = await txn.insert('questions', {
  //       'question_text': questionText,
  //     });
  //
  //     int correctChoiceId = -1;
  //
  //     for (int i = 0; i < choices.length; i++) {
  //       final int choiceId = await txn.insert('choices', {
  //         'question_id': questionId,
  //         'choice_text': choices[i],
  //       });
  //
  //       if (i == correctChoiceIndex) {
  //         correctChoiceId = choiceId;
  //       }
  //     }
  //
  //     if (correctChoiceId == -1) {
  //       throw Exception("Invalid correctChoiceIndex: No choice was marked as correct.");
  //     }
  //
  //     await txn.insert('correct_answers', {
  //       'question_id': questionId,
  //       'choice_id': correctChoiceId,
  //     });
  //
  //     return questionId;
  //   });
  // }
  
  // GET QUESTION WITH CHOICES AND ANSWER
  Future<QuestionData> getQuestionWithChoicesAndAnswer(int id) async {
    final List<Map<String, dynamic>> results = await _database.rawQuery(selectQuestionWithChoicesAndAnswer, [id]);
    return QuestionData.fromDatabaseResult(results);
  }

  Future<void> deleteQuestion(int id) async {
    await _database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
