class Question {
  int? id;
  String questionText;
  bool? isCorrect;

  Question({
    this.id,
    required this.questionText,
    this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_text': questionText,
      'is_correct': isCorrect == null ? null : (isCorrect! ? 1 : 0),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      questionText: map['question_text'],
      isCorrect: map['is_correct'] == null ? null : map['is_correct'] == 1,
    );
  }
}