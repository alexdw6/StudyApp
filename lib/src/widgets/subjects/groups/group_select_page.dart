import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/question_dao.dart';
import 'package:study_app/src/models/question.dart';

import '../../../dao/group_dao.dart';
import '../../../dao/subject_dao.dart';
import '../../../models/group.dart';

class GroupSelectPage extends StatefulWidget {
  final int subjectId;

  const GroupSelectPage({required this.subjectId});

  @override
  State<StatefulWidget> createState() => _GroupSelectPageState();
}

class _GroupSelectPageState extends State<GroupSelectPage> {
  final _subjectDao = GetIt.I<SubjectDao>();
  final _groupDao = GetIt.I<GroupDao>();

  late List<Group> _groups;
  List<bool> _selectedList = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshWordList() async {
    await _groupDao.getGroups().then((questions) {
      setState(() {
        _groups = questions;
        _selectedList = List.filled(_groups.length, false);
        _isRefreshing = false;
      });
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _refreshWordList();
  }

  void toggleSelection(int index) {
    setState(() {
      _selectedList[index] = !_selectedList[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a question"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedList.any((element) => element))
            TextButton(
                onPressed: () async {
                  List<int> ids = [];
                  for (var i = 0; i < _selectedList.length; i++) {
                    if (_selectedList[i]) {
                      ids.add(_groups[i].id!);
                    }
                  }
                  await _subjectDao.addGroupsToSubject(widget.subjectId, ids);

                  Navigator.pop(context, true);
                },
                child: Text("save")
            )
        ],
      ),
      body: ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          Group group = _groups[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.all(8),
            child: ListTile(
              onTap: () {
                toggleSelection(index);
              },
              leading: _selectedList[index]
                  ? Icon(Icons.radio_button_checked, color: Colors.blue,)
                  : Icon(Icons.radio_button_off, color: Colors.blue,),
              title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}