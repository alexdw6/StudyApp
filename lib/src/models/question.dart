class Question {
  int? id;
  String questionText;
  bool? gotCorrect;

  Question({
    this.id,
    required this.questionText,
    this.gotCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_text': questionText,
      'got_correct': gotCorrect == null ? null : (gotCorrect! ? 1 : 0),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      questionText: map['question_text'],
      gotCorrect: map['got_correct'] == null ? null : map['got_correct'] == 1,
    );
  }

  @override
  String toString() {
    return 'Question{id: $id, questionText: $questionText}';
  }
}