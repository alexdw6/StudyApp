import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/group_dao.dart';
import 'package:study_app/src/models/group.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  EditGroupPage({required this.group});

  @override
  State<StatefulWidget> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final _groupDao = GetIt.I<GroupDao>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit group'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.group.name,
                  decoration: const InputDecoration(labelText: 'Word'),
                  onSaved: (value) {
                    widget.group.name = value!.trim();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState?.save();
                    await _groupDao.updateGroup(widget.group);

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
