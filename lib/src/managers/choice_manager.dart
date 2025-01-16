import 'package:get_it/get_it.dart';

import '../dao/choice_dao.dart';

class ChoiceManager {
  final ChoiceDao _choiceDao = GetIt.I<ChoiceDao>();

  void deleteChoice(int id) async {
    await _choiceDao.deleteChoice(id);
  }

  void deleteAllWithQuestionId(int questionId) async {
    await _choiceDao.deleteAllWithQuestionId(questionId);
  }
}