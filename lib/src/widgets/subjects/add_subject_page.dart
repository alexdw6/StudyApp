import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/models/subject.dart';

import '../../dao/subject_dao.dart';

class AddSubjectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddSubjectPageState();

}

class _AddSubjectPageState extends State<AddSubjectPage> {
  final _subjectDao = GetIt.I<SubjectDao>();
  final _formKey = GlobalKey<FormState>();

  final Subject _newSubject = Subject(name: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add Subject'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject name'),
                  onSaved: (value) {
                    _newSubject.name = value!.trim();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState?.save();
                    await _subjectDao.addSubject(_newSubject);

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