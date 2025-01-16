import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../dao/group_dao.dart';
import '../../models/group.dart';

class AddGroupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddGroupPageState();

}

class _AddGroupPageState extends State<AddGroupPage> {
  final _groupDao = GetIt.I<GroupDao>();
  final _formKey = GlobalKey<FormState>();

  Group _newGroup = Group(name: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add group'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Group name'),
                  onSaved: (value) {
                    _newGroup.name = value!.trim();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState?.save();
                    await _groupDao.addGroup(_newGroup);

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