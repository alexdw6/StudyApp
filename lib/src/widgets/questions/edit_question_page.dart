import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../dao/question_dao.dart';
import '../../models/question.dart';

class EditQuestionPage extends StatefulWidget {
  final Question question;

  const EditQuestionPage({super.key, required this.question});

  @override
  State<StatefulWidget> createState() => _EditQuestionPageState();

}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final _questionDao = GetIt.I<QuestionDao>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit question'),
      ),
      body: Padding(
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
                ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState?.save();
                    await _questionDao.updateQuestion(widget.question);

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