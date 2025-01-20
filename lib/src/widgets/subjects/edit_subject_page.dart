import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../dao/subject_dao.dart';
import '../../models/subject.dart';

class EditSubjectPage extends StatefulWidget {
  final Subject subject;

  EditSubjectPage({required this.subject});

  @override
  State<StatefulWidget> createState() => _EditSubjectPageState();
}

class _EditSubjectPageState extends State<EditSubjectPage> {
  final _subjectDao = GetIt.I<SubjectDao>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit subject'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.subject.name,
                  decoration: const InputDecoration(labelText: 'Subject name'),
                  onSaved: (value) {
                    widget.subject.name = value!.trim();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState?.save();
                    await _subjectDao.updateSubject(widget.subject);

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
