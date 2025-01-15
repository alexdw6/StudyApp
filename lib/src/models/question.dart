class Question {
  int? id;
  String questionText;

  Question({
    this.id,
    required this.questionText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_text': questionText,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      questionText: map['question_text'],
    );
  }
}