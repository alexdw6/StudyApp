import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../dao/question_dao.dart';
import '../../models/question.dart';

class AddQuestionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _questionDao = GetIt.I<QuestionDao>();
  final _formKey = GlobalKey<FormState>();

  Question _newQuestion = Question(questionText: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add question'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Question'),
                  onSaved: (value) {
                    _newQuestion.questionText = value!.trim();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState?.save();
                    await _questionDao.createQuestion(_newQuestion);

                    Navigator.pop(context, true);
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          )
      ),
    );
  }

}
