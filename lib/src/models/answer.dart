class Answer {
  int? id;
  int questionId;
  int choiceId;

  Answer({
    this.id,
    required this.questionId,
    required this.choiceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'choice_id': choiceId,
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      questionId: map['question_id'],
      choiceId: map['choice_id'],
    );
  }
}