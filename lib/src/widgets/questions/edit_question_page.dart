import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/managers/choice_manager.dart';
import 'package:study_app/src/managers/question_manager.dart';

import '../../dao/question_dao.dart';
import '../../models/choice.dart';
import '../../models/question.dart';
import '../../models/question_data.dart';
import '../choices/expandable_choices_list.dart';

class EditQuestionPage extends StatefulWidget {
  final Question question;

  const EditQuestionPage({super.key, required this.question});

  @override
  State<StatefulWidget> createState() => _EditQuestionPageState();

}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final _questionDao = GetIt.I<QuestionDao>();
  final _formKey = GlobalKey<FormState>();
  final _questionManager = GetIt.I<QuestionManager>();
  final _choiceManager = GetIt.I<ChoiceManager>();

  late List<Choice> _initialChoices = [];
  List<Choice> _choices = [];
  bool _isLoading = true;

  QuestionData _editedQuestionData = QuestionData(
      question: Question(questionText: ''), choices: []);

  @override
  void initState() {
    super.initState();
    _loadChoices(widget.question.id!);
  }

  Future<void> _loadChoices(int id) async {
    _initialChoices = await _choiceManager.getAllChoicesFromQuestionId(id);

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit question'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: widget.question.questionText,
                    decoration: const InputDecoration(labelText: 'Question'),
                    onSaved: (value) {
                      widget.question.questionText = value!.trim();
                    },
                  ),
                  Expanded(
                    child: ExpandableChoicesList(
                      initialChoices: _initialChoices,
                      onChoicesChanged: (choices) {
                        _choices = choices;
                      }
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _formKey.currentState?.save();
                      _editedQuestionData.question = widget.question;
                      _editedQuestionData.choices = _choices;
                      await _questionManager.updateQuestionAndChoices(_editedQuestionData);
                      Navigator.pop(context, true);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            )
      ),
    );
  }

}