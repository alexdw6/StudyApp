import 'package:study_app/src/models/choice.dart';
import 'package:study_app/src/models/question.dart';

class QuestionData {
  Question question;
  List<Choice> choices;

  QuestionData({
    required this.question,
    required this.choices,
  });

  factory QuestionData.fromDatabaseResult(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      throw Exception("No question data found");
    }

    Map<String, dynamic> questionData = results.first;

    // Map the first result to the Question object
    Question question = Question.fromMap({
      'id': questionData['question_id'],
      'questionText': questionData['question_text'],
    });

    // Map the choices from the results
    List<Choice> choices = results.where((result) => result['choice_id'] != null).map((result) => Choice.fromMap({
      'id': result['choice_id'],
      'questionId': result['question_id'],
      'choiceText': result['choice_text'],
      'isCorrect' : result['is_correct'],
    })).toList();


    return QuestionData(
      question: question,
      choices: choices,
    );
  }
}