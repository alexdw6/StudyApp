import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/managers/question_manager.dart';
import 'package:study_app/src/models/choice.dart';
import 'package:study_app/src/models/question_data.dart';
import 'package:study_app/src/widgets/choices/expandable_choices_list.dart';

import '../../models/question.dart';

class AddQuestionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _questionManager = GetIt.I<QuestionManager>();
  final _formKey = GlobalKey<FormState>();

  Question _newQuestion = Question(questionText: '');
  QuestionData _newQuestionData = QuestionData(
      question: Question(questionText: ''), choices: []);
  List<Choice> _choices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text('Add question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Question'),
                      onSaved: (value) {
                        if (value != null)
                          _newQuestion.questionText = value.trim();
                      },
                    ),
                    Expanded(
                      child: ExpandableChoicesList(
                          onChoicesChanged: (choices) {
                            _choices = choices;
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                _formKey.currentState?.save();
                _newQuestionData.question = _newQuestion;
                _newQuestionData.choices = _choices;
                await _questionManager.createQuestion(_newQuestionData);
                Navigator.pop(context, true);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
