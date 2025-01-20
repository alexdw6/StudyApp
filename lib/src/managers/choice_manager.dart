import 'package:get_it/get_it.dart';

import '../dao/choice_dao.dart';
import '../models/choice.dart';

class ChoiceManager {
  final ChoiceDao _choiceDao = GetIt.I<ChoiceDao>();

  Future<List<Choice>> getAllChoicesFromQuestionId(int questionId) {
    return _choiceDao.getAllChoicesWithQuestionId(questionId);
  }

  void deleteChoice(int id) async {
    await _choiceDao.deleteChoice(id);
  }

  void deleteAllWithQuestionId(int questionId) async {
    await _choiceDao.deleteAllWithQuestionId(questionId);
  }
}