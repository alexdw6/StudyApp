class Choice {
  int? id;
  int? questionId;
  String choiceText;
  bool isCorrect;
  String? explanation;

  Choice({
    this.id,
    this.questionId,
    required this.choiceText,
    required this.isCorrect,
    this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'choice_text': choiceText,
      'is_correct': isCorrect ? 1 : 0,
      'explanation': explanation,
    };
  }

  factory Choice.fromMap(Map<String, dynamic> map) {
    return Choice(
      id: map['id'],
      questionId: map['question_id'],
      choiceText: map['choice_text'],
      isCorrect: map['is_correct'] == 1,
      explanation: map['explanation'],
    );
  }
}