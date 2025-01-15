import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:study_app/src/models/question.dart';

import '../models/group.dart';
import '../services/database_manager.dart';

class GroupDao {
  final Database _database = GetIt.I<DatabaseManager>().database;
  static const String tableName = "groups";
  static const String groupQuestionTableName = "group_questions";

  static const String selectGroupsWithQuestions = '''
    SELECT groups.id AS group_id, groups.name AS group_name, questions.id AS question_id, questions.question_text FROM groups
    LEFT JOIN group_questions ON groups.id = group_questions.group_id
    LEFT JOIN questions ON group_questions.question_id = questions.id
    WHERE groups.id = ?;
  ''';

  GroupDao();

  Future<List<Group>> getGroups() async {
    final List<Map<String, dynamic>> conjugationMaps = await _database.query(tableName);
    return conjugationMaps.map((map) => Group.fromMap(map)).toList();
  }

  Future<Group> getGroup(int id) async {
    List<Map<String, dynamic>> results = await _database.query(tableName, where: "id = ?", whereArgs: [id]);
    return Group.fromMap(results.first);
  }

  Future<Group> getGroupWithQuestions(int groupId) async {
    List<Map<String, dynamic>> results = await _database.rawQuery(selectGroupsWithQuestions, [groupId]);

    if (results.isNotEmpty) {
      // Use the first result since the group information is the same for all rows
      Map<String, dynamic> groupData = results[0];

      // Extract the group information
      Group group = Group.fromMap({
        'id': groupData['group_id'],
        'name': groupData['group_name'],
      });

      // Extract and add associated words
      group.questions = results
          .where((result) => result['question_id'] != null)
          .map((result) => Question.fromMap({
        'id': result['question_id'],
        'question_text': result['question_text'],
      })).toList();

      return group;
    } else {
      // Handle the case where the group with the specified ID is not found
      throw Exception('Group not found');
    }
  }

  Future<void> deleteGroup(int id) async {
    Batch batch = _database.batch();

    batch.delete(groupQuestionTableName, where: 'group_id = ?', whereArgs: [id]);;
    batch.delete(tableName, where: 'id = ?', whereArgs: [id]);

    await batch.commit();
  }

  Future<void> addGroup(Group group) async {
    await _database.insert(tableName, group.toMap());
  }

  Future<void> updateGroup(Group group) async {
    await _database.update(tableName, group.toMap(), where: 'id = ?', whereArgs: [group.id]);
  }

  Future<void> addQuestionsToGroup(int groupId, List<int> questionIds) async {
    Batch batch = _database.batch();

    for (int questionId in questionIds) {
      batch.insert(groupQuestionTableName, {'group_id': groupId, 'question_id': questionId});
    }

    await batch.commit();
  }

  Future<void> deleteQuestionFromGroup(int groupId, int questionId) async {
    await _database.delete(groupQuestionTableName, where: 'group_id = ? AND question_id = ?', whereArgs: [groupId, questionId]);
  }

  Future<void> deleteAllQuestionsFromGroup(int groupId) async {
    await _database.delete(groupQuestionTableName, where: 'group_id = ?', whereArgs: [groupId]);
  }
}