import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/answer_dao.dart';
import 'package:study_app/src/dao/choice_dao.dart';
import 'package:study_app/src/dao/question_dao.dart';
import 'package:study_app/src/models/answer.dart';
import 'package:study_app/src/models/choice.dart';
import 'package:study_app/src/models/question_data.dart';

import '../models/question.dart';

class QuestionManager {
  final QuestionDao _questionDao = GetIt.I<QuestionDao>();
  final ChoiceDao _choiceDao = GetIt.I<ChoiceDao>();
  final AnswerDao _answerDao = GetIt.I<AnswerDao>();

  void deleteQuestion(int id) async {
    await _answerDao.deleteAnswerWithQuestionId(id);
    await _choiceDao.deleteAllWithQuestionId(id);
    await _questionDao.deleteQuestion(id);
  }

  Future<int> createQuestion(QuestionData questionData) async {
    int questionId = await _questionDao.createQuestion(questionData.question);

    for (var choice in questionData.choices) {
      choice.questionId = questionId;
    }

    await _choiceDao.createChoises(questionData.choices);

    questionData.answer.questionId = questionId;
    await _answerDao.createAnswer(questionData.answer);

    return questionId;
  }

  Future<Question> getQuestion(int id) async {
    return await _questionDao.getQuestion(id);
  }

  Future<QuestionData> getQuestionWithChoicesAndAnswer(int id) async {
    Question question = await _questionDao.getQuestion(id);
    List<Choice> choices = await _choiceDao.getAllChoicesWithQuestionId(id);
    Answer answer = await _answerDao.getAnswerFromQuestionId(id);

    return QuestionData(question: question, choices: choices, answer: answer);
  }
}