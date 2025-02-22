import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/group_dao.dart';
import 'package:study_app/src/models/question.dart';
import 'package:study_app/src/widgets/exercises/exercise_page.dart';
import 'package:study_app/src/widgets/exercises/exercise_start_page.dart';
import 'package:study_app/src/widgets/groups/questions/question_select_page.dart';

import '../../models/group.dart';
import 'edit_group_page.dart';

class GroupDetailsPage extends StatefulWidget {
  final int groupId;

  const GroupDetailsPage({required this.groupId});

  @override
  State<StatefulWidget> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final GroupDao _groupDao = GetIt.I<GroupDao>();
  late Group _group;

  bool _isRefreshing = false;


  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshGroupList() async {
    await _groupDao.getGroupWithQuestions(widget.groupId).then((group) {
      setState(() {
        _group = group;
        _group.questions ??= [];
        _isRefreshing = false;
      });
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _refreshGroupList();
  }

  Future<bool> _showAlertDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Do you want to continue?"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Continue"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group details"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExerciseStartPage(groupId: _group.id, isRandomized: false,)));
              },
              icon: const Icon(Icons.menu_book)
          ),
          IconButton(
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExerciseStartPage(groupId:  _group.id, isRandomized: true,)));
              },
              icon: const Icon(Icons.shuffle)
          ),
          IconButton(
            onPressed: () async {
              bool result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditGroupPage(group: _group),
              ));

              if (result) {
                _handleRefresh();
              }
            },
            icon: Icon(Icons.edit,),
          ),
          IconButton(
            onPressed: () async {
              bool result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => QuestionSelectPage(groupId: widget.groupId,),
              ));

              if (result) {
                _handleRefresh();
              }
            },
            icon: Icon(Icons.add,),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isRefreshing
          ? Center(child: CircularProgressIndicator())
          : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 30, top: 16),
              child: Text(
                _group.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _group.questions?.length,
                itemBuilder: (BuildContext context, int index) {
                  Question question = _group.questions![index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(question.questionText, style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              await _showAlertDialog(context, "Are you sure you want to delete this question from the group?").then((value) async {
                                if (value) {
                                  await _groupDao.deleteQuestionFromGroup(widget.groupId, question.id!);
                                  _handleRefresh();
                                }
                              });
                            },
                            icon: Icon(Icons.delete, color: Colors.red,),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}