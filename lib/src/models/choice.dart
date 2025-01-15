class Choice {
  int? id;
  int questionId;
  String choiceText;

  Choice({
    this.id,
    required this.questionId,
    required this.choiceText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'choice_text': choiceText,
    };
  }

  factory Choice.fromMap(Map<String, dynamic> map) {
    return Choice(
      id: map['id'],
      questionId: map['question_id'],
      choiceText: map['choice_text'],
    );
  }
}