import 'package:study_app/src/models/group.dart';

class Subject {
  int? id;
  String name;
  List<Group>? groups;

  Subject({
    this.id,
    required this.name,
    this.groups,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
    );
  }
}