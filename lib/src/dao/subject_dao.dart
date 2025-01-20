import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../models/group.dart';
import '../models/subject.dart';
import '../services/database_manager.dart';

class SubjectDao {
  final Database _database = GetIt.I<DatabaseManager>().database;
  static const String tableName = "subjects";
  static const String groupQuestionTableName = "subject_groups";

  static const String selectSubjectsWithGroups = '''
    SELECT subjects.id AS subject_id, subjects.name AS subject_name, groups.id AS group_id, groups.name AS group_name FROM subjects
    LEFT JOIN subject_groups ON subjects.id = subject_groups.subject_id
    LEFT JOIN groups ON subject_groups.group_id = groups.id
    WHERE subjects.id = ?;
  ''';

  SubjectDao();

  Future<List<Subject>> getSubjects() async {
    final List<Map<String, dynamic>> conjugationMaps = await _database.query(tableName);
    return conjugationMaps.map((map) => Subject.fromMap(map)).toList();
  }

  Future<Subject> getSubject(int id) async {
    List<Map<String, dynamic>> results = await _database.query(tableName, where: "id = ?", whereArgs: [id]);
    return Subject.fromMap(results.first);
  }

  Future<Subject> getSubjectWithGroups(int groupId) async {
    List<Map<String, dynamic>> results = await _database.rawQuery(selectSubjectsWithGroups, [groupId]);

    if (results.isNotEmpty) {
      // Use the first result since the group information is the same for all rows
      Map<String, dynamic> subjectData = results[0];

      // Extract the group information
      Subject subject = Subject.fromMap({
        'id': subjectData['subject_id'],
        'name': subjectData['subject_name'],
      });

      subject.groups = results
          .where((result) => result['group_id'] != null)
          .map((result) => Group.fromMap({
        'id': result['group_id'],
        'name': result['group_name'],
      })).toList();

      return subject;
    } else {
      // Handle the case where the group with the specified ID is not found
      throw Exception('Subject not found');
    }
  }

  Future<void> deleteSubject(int id) async {
    Batch batch = _database.batch();

    batch.delete(groupQuestionTableName, where: 'subject_id = ?', whereArgs: [id]);;
    batch.delete(tableName, where: 'id = ?', whereArgs: [id]);

    await batch.commit();
  }

  Future<void> addSubject(Subject group) async {
    await _database.insert(tableName, group.toMap());
  }

  Future<void> updateSubject(Subject group) async {
    await _database.update(tableName, group.toMap(), where: 'id = ?', whereArgs: [group.id]);
  }

  Future<void> addGroupsToSubject(int groupId, List<int> questionIds) async {
    Batch batch = _database.batch();

    for (int questionId in questionIds) {
      batch.insert(groupQuestionTableName, {'subject_id': groupId, 'group_id': questionId});
    }

    await batch.commit();
  }

  Future<void> deleteGroupFromSubject(int subjectId, int groupId) async {
    await _database.delete(groupQuestionTableName, where: 'subject_id = ? AND group_id = ?', whereArgs: [subjectId, groupId]);
  }

  Future<void> deleteAllGroupsFromSubject(int subjectId) async {
    await _database.delete(groupQuestionTableName, where: 'subject_id = ?', whereArgs: [subjectId]);
  }
}