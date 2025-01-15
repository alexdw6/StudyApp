import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../dao/question_dao.dart';
import '../../models/question.dart';
import 'add_question_page.dart';
import 'edit_question_page.dart';

class QuestionListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QuestionListPageState();

}

class _QuestionListPageState extends State<QuestionListPage> {
  final QuestionDao _questionDao = GetIt.I<QuestionDao>();

  late List<Question> _questions;
  late List<Question> _filteredQuestions = _questions;
  bool _isRefreshing = false;
  bool _inSelectionMode = false;
  SearchTerm _searchTerm = SearchTerm.WORD;
  String _query = "";

  List<bool> _selectedList = [];

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshQuestionList() async {
    await _questionDao.getQuestions().then((questions) {
      setState(() {
        _questions = questions;
        _filteredQuestions = questions;
        // _search();
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
              title: Text('Dictionary'),
              actions: [
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
                if (!_inSelectionMode)
                  IconButton(
                    onPressed: () async {
                      bool result = await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddQuestionPage(),
                      ));

                      if (result) {
                        _handleRefresh();
                      }
                    },
                    icon: Icon(Icons.add),
                  )
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _isRefreshing
                  ? Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                slivers: [
                  // SliverToBoxAdapter(
                  //   child: QuestionSearchBox(
                  //     onTermSelected: (SearchTerm term) {
                  //       _searchTerm = term;
                  //       _search();
                  //     },
                  //     onSearch: (String query) {
                  //       _query = query;
                  //       _search();
                  //     },
                  //   ),
                  // ),
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
                                onTap: () {
                                  if (_inSelectionMode) {
                                    toggleSelection(index);
                                  }
                                },
                                leading: _inSelectionMode
                                    ? _selectedList[index]
                                    ? Icon(Icons.radio_button_checked, color: Colors.blue,)
                                    : Icon(Icons.radio_button_off, color: Colors.blue,)
                                    : null,
                                title: Text(question.questionText, style: TextStyle(fontWeight: FontWeight.bold)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                  <Widget>[
                                    if (!_inSelectionMode)
                                      IconButton(
                                        onPressed: () async {
                                          bool result = await Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => EditQuestionPage(question: question),
                                          ));

                                          if (result) {
                                            _handleRefresh();
                                          }
                                        },
                                        icon: Icon(Icons.edit,),
                                      ),
                                    if (!_inSelectionMode)
                                      IconButton(
                                        onPressed: () async {
                                          await _showAlertDialog(context, "Are you sure you want to delete this question?").then((value) async {
                                            if (value) {
                                              await _questionDao.deleteQuestion(question.id!);
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

enum SearchTerm {
  WORD("question"),
  MEANING("meaning");

  const SearchTerm(this.value);
  final String value;
}

class QuestionSearchBox extends StatefulWidget {
  final void Function(SearchTerm selectedTerm) onTermSelected;
  final void Function(String query) onSearch;

  QuestionSearchBox({required this.onTermSelected, required this.onSearch});

  @override
  State<StatefulWidget> createState() => _QuestionSearchBoxState();

}

class _QuestionSearchBoxState extends State<QuestionSearchBox> {
  SearchTerm selectedTerm = SearchTerm.WORD;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(25.0)
      ),
      child: Row(
        children: [
          // Left side with DropdownButton
          Expanded(
            child: DropdownButton<SearchTerm>(
              value: selectedTerm,
              underline: Container(),
              items: SearchTerm.values.map((SearchTerm searchTerm) {
                return DropdownMenuItem<SearchTerm>(
                  value: searchTerm,
                  child: Text(searchTerm.value),
                );
              }).toList(),
              onChanged: (SearchTerm? newValue) {
                setState(() {
                  selectedTerm = newValue!;
                  widget.onTermSelected(selectedTerm);
                });
              },
              hint: Text('Select an option'),
            ),
          ),
          VerticalDivider(
            color: Colors.grey,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter text',
                border: InputBorder.none,
              ),
              onChanged: (text) {
                widget.onSearch(text);
              },
            ),
          ),
        ],
      ),
    );
  }
}