import 'package:study_app/src/models/question.dart';

class Group {
  int? id;
  String name;
  List<Question>? questions;

  Group({
    this.id,
    required this.name,
    this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
    );
  }
}