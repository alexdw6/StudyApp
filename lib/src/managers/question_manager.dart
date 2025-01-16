import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/choice_dao.dart';
import 'package:study_app/src/dao/question_dao.dart';
import 'package:study_app/src/models/choice.dart';
import 'package:study_app/src/models/question_data.dart';

import '../models/question.dart';

class QuestionManager {
  final QuestionDao _questionDao = GetIt.I<QuestionDao>();
  final ChoiceDao _choiceDao = GetIt.I<ChoiceDao>();

  Future<List<Question>> getQuestions() async {
    return await _questionDao.getQuestions();
  }

  Future<Question> getQuestion(int id) async {
    return await _questionDao.getQuestion(id);
  }

  Future<QuestionData> getQuestionWithChoicesAndAnswer(int id) async {
    Question question = await _questionDao.getQuestion(id);
    List<Choice> choices = await _choiceDao.getAllChoicesWithQuestionId(id);

    return QuestionData(question: question, choices: choices);
  }

  Future<List<Question>> getQuestionsFromGroup(int groupId) async {
    List<Question> questions = await _questionDao.getQuestionsFromGroup(groupId);
    return questions;
  }

  Future<List<QuestionData>> getQuestionDataFromGroup(int groupId) async {
    List<Question> questions = await getQuestionsFromGroup(groupId);

    List<int> questionIds = questions.map((question) => question.id).whereType<int>().toList();

    List<Choice> choices = await _choiceDao.getAllChoicesFromMultipleQuestions(questionIds);

    List<QuestionData> questionData = [];

    for (var question in questions) {
      List<Choice> questionChoices = choices.where((choice) => choice.questionId == question.id).toList();
      questionData.add(QuestionData(question: question, choices: questionChoices));
    }

    return questionData;
  }

  void deleteQuestion(int id) async {
    await _choiceDao.deleteAllWithQuestionId(id);
    await _questionDao.deleteQuestion(id);
  }

  Future<int> createQuestion(QuestionData questionData) async {
    int questionId = await _questionDao.createQuestion(questionData.question);

    for (var choice in questionData.choices) {
      choice.questionId = questionId;
    }

    await _choiceDao.createChoises(questionData.choices);

    return questionId;
  }
}