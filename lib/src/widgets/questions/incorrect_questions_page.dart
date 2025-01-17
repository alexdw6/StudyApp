import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/widgets/questions/question_details_page.dart';

import '../../dao/question_dao.dart';
import '../../managers/question_manager.dart';
import '../../models/question.dart';
import '../exercises/exercise_page.dart';

class IncorrectQuestionsPage extends StatefulWidget {
  const IncorrectQuestionsPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuestionListPageState();

}

class _QuestionListPageState extends State<IncorrectQuestionsPage> {
  final QuestionDao _questionDao = GetIt.I<QuestionDao>();
  final QuestionManager _questionManager = GetIt.I<QuestionManager>();

  late List<Question> _questions;
  late List<Question> _filteredQuestions = _questions;
  bool _isRefreshing = false;
  bool _inSelectionMode = false;

  List<bool> _selectedList = [];

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshQuestionList() async {
    await _questionManager.getCorrectQuestions(false).then((questions) {
      setState(() {
        _questions = questions;
        _filteredQuestions = questions;
        _selectedList = List.filled(_questions.length, false);
        _isRefreshing = false;
      });
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _refreshQuestionList();
  }

  void toggleSelectionMode(bool status) {
    setState(() {
      _inSelectionMode = status;
    });
  }

  void toggleSelection(int index) {
    setState(() {
      _selectedList[index] = !_selectedList[index];
    });
  }

  Future<void> _deleteSelection(List<int> ids) async {
    _questionDao.deleteSelection(ids);
    _handleRefresh().then((value) => toggleSelectionMode(false));
  }

  // void _search() {
  //   if(_query.isEmpty) {
  //     setState(() {
  //       _filteredQuestions = _questions;
  //     });
  //   } else {
  //     switch (_searchTerm) {
  //       case SearchTerm.WORD:
  //         setState(() {
  //           _filteredQuestions = _questions.where((e) => e.question.toLowerCase().contains(_query.toLowerCase())).toList();
  //         });
  //         break;
  //       case SearchTerm.MEANING:
  //         setState(() {
  //           _filteredQuestions = _questions.where((e) => e.meaning.toLowerCase().contains(_query.toLowerCase())).toList();
  //         });
  //         break;
  //     }
  //   }
  // }

  Future<bool> _showAlertDialog(BuildContext context, String message) async {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Do you want to continue?"),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text('Incorrect questions'),
              actions: [
                IconButton(
                    onPressed: () async {
                      bool? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuestionExercisePage(listSize: 0, isCorrect: false,)));
                      _handleRefresh();
                    },
                    icon: const Icon(Icons.menu_book)
                ),
                if (_inSelectionMode && _selectedList.any((element) => element))
                  IconButton(
                      onPressed: () {
                        List<int> ids = [];
                        for (var i = 0; i < _selectedList.length; i++) {
                          if (_selectedList[i]) {
                            ids.add(_questions[i].id!);
                          }
                        }
                        _deleteSelection(ids);
                      },
                      icon: Icon(Icons.delete)
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _isRefreshing
                  ? Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          Question question = _filteredQuestions[index];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              onLongPress: () {
                                toggleSelectionMode(true);
                              },
                              onTap: () async {
                                if (_inSelectionMode) {
                                  toggleSelection(index);
                                } else {
                                  bool? result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => QuestionExercisePage(isCorrect: false, listSize: 0,),
                                    ),
                                  );

                                  if (result == true) {
                                    // The user pressed "Finish" — trigger refresh or other actions.
                                    _handleRefresh();
                                  }
                                }
                              },
                              leading: _inSelectionMode
                                  ? _selectedList[index]
                                  ? Icon(Icons.radio_button_checked, color: Colors.blue,)
                                  : Icon(Icons.radio_button_off, color: Colors.blue,)
                                  : null,
                              title: Text(question.questionText, style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                        childCount: _filteredQuestions.length,
                      )
                  ),
                ],
              ),
            )
        ),
        onWillPop: () async {
          if (_inSelectionMode) {
            toggleSelectionMode(false);
            for (var i = 0; i < _selectedList.length; i++) {
              _selectedList[i] = false;
            }
            return false;
          }
          return true;
        });
  }
}