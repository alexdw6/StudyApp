import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/widgets/subjects/subject_details_page.dart';

import '../../dao/subject_dao.dart';
import '../../models/subject.dart';
import 'add_subject_page.dart';

class SubjectListPage extends StatefulWidget {
  const SubjectListPage({super.key});

  @override
  State<StatefulWidget> createState() => _SubjectListPageState();

}

class _SubjectListPageState extends State<SubjectListPage> {
  final SubjectDao _subjectDao = GetIt.I<SubjectDao>();
  late List<Subject> _subjects;

  bool _isRefreshing = false;


  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshSubjectList() async {
    await _subjectDao.getSubjects().then((groups) {
      setState(() {
        _subjects = groups;
        // _selectedList = List.filled(_verbs.length, false);
        _isRefreshing = false;
      });
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _refreshSubjectList();
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Subjects"),
          actions: [
            IconButton(
              onPressed: () async {
                bool result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddSubjectPage(),
                ));

                if (result) {
                  _handleRefresh();
                }
              },
              icon: Icon(Icons.add),
            ),
            // TextButton(
            //     onPressed: () async {
            //       Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => QuestionListPage(),
            //       ));
            //     },
            //     child: const Text("questions"))
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: _isRefreshing
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: _subjects.length,
            itemBuilder: (BuildContext context, int index) {
              Subject subject = _subjects[index];
              return Card(
                child: ListTile(
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SubjectDetailsPage(subjectId: subject.id!),
                      ));

                      _handleRefresh();
                    },
                    title: Text(subject.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children:
                      <Widget>[
                        IconButton(
                          onPressed: () async {
                            await _showAlertDialog(context, "Are you sure you want to delete this group?").then((value) async {
                              if (value) {
                                await _subjectDao.deleteSubject(subject.id!);
                                _handleRefresh();
                              }
                            });
                          },
                          icon: Icon(Icons.delete, color: Colors.red,),
                        ),
                      ],
                    )
                ),
              );
            },
          ),
        )
    );
  }
}