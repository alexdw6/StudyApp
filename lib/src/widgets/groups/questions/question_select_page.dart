import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/question_dao.dart';
import 'package:study_app/src/models/question.dart';

import '../../../dao/group_dao.dart';

class QuestionSelectPage extends StatefulWidget {
  final int groupId;

  const QuestionSelectPage({required this.groupId});

  @override
  State<StatefulWidget> createState() => _questionselectPageState();
}

class _questionselectPageState extends State<QuestionSelectPage> {
  final _questionDao = GetIt.I<QuestionDao>();
  final _groupDao = GetIt.I<GroupDao>();

  late List<Question> _questions;
  List<bool> _selectedList = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshWordList() async {
    await _questionDao.getQuestions().then((questions) {
      setState(() {
        _questions = questions;
        _selectedList = List.filled(_questions.length, false);
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
        title: Text("Select a word"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedList.any((element) => element))
            TextButton(
                onPressed: () async {
                  List<int> ids = [];
                  for (var i = 0; i < _selectedList.length; i++) {
                    if (_selectedList[i]) {
                      ids.add(_questions[i].id!);
                    }
                  }
                  await _groupDao.addQuestionsToGroup(widget.groupId, ids);

                  Navigator.pop(context, true);
                },
                child: Text("save")
            )
        ],
      ),
      body: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          Question question = _questions[index];
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
                title: Text(question.questionText, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

}