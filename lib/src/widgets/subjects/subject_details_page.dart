import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/subject_dao.dart';
import 'package:study_app/src/models/group.dart';
import 'package:study_app/src/models/subject.dart';

import '../groups/group_details_page.dart';
import 'edit_subject_page.dart';
import 'groups/group_select_page.dart';

class SubjectDetailsPage extends StatefulWidget {
  final int subjectId;

  const SubjectDetailsPage({required this.subjectId});

  @override
  State<StatefulWidget> createState() => _SubjectDetailsPageState();
}

class _SubjectDetailsPageState extends State<SubjectDetailsPage> {
  final SubjectDao _subjectDao = GetIt.I<SubjectDao>();
  late Subject _subject;

  bool _isRefreshing = false;


  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshGroupList() async {
    await _subjectDao.getSubjectWithGroups(widget.subjectId).then((group) {
      setState(() {
        _subject = group;
        _subject.groups ??= [];
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
        title: Text("Subject details"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditSubjectPage(subject: _subject),
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
                builder: (context) => GroupSelectPage(subjectId: widget.subjectId,),
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
                _subject.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _subject.groups?.length,
                itemBuilder: (BuildContext context, int index) {
                  Group group = _subject.groups![index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => GroupDetailsPage(groupId: group.id!),
                        ));

                        _handleRefresh();
                      },
                      title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold)),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              await _showAlertDialog(context, "Are you sure you want to delete this group from the subject?").then((value) async {
                                if (value) {
                                  await _subjectDao.deleteGroupFromSubject(widget.subjectId, group.id!);
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