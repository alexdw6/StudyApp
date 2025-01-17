import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/managers/question_manager.dart';

import '../../models/question.dart';
import 'edit_question_page.dart';

class QuestionDetailsPage extends StatefulWidget {
  final int questionId;

  const QuestionDetailsPage({super.key, required this.questionId});

  @override
  State<StatefulWidget> createState() => _QuestionDetailsPageState();
}

class _QuestionDetailsPageState extends State<QuestionDetailsPage> {
  final QuestionManager _questionManager = GetIt.I<QuestionManager>();
  late Question _question;

  bool _isRefreshing = false;


  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshQuestionList() async {
    await _questionManager.getQuestion(widget.questionId).then((question) {
      setState(() {
        _question = question;
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
        title: Text("Question details"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditQuestionPage(question: _question),
              ));

              if (result) {
                _handleRefresh();
              }
            },
            icon: Icon(Icons.edit,),
          ),
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
                _question.questionText,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // !!! REWORK FOR CHOICES !!!
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: _question.words?.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       Word word = _question.words![index];
            //       return Card(
            //         elevation: 3,
            //         margin: EdgeInsets.all(8),
            //         child: ListTile(
            //           title: Text(word.word, style: TextStyle(fontWeight: FontWeight.bold)),
            //           subtitle: Text(word.meaning),
            //           trailing: Row(
            //             mainAxisSize: MainAxisSize.min,
            //             children: <Widget>[
            //               IconButton(
            //                 onPressed: () async {
            //                   await _showAlertDialog(context, "Are you sure you want to delete this word?").then((value) async {
            //                     if (value) {
            //                       await _questionDao.deleteWordFromQuestion(widget.questionId, word.id!);
            //                       _handleRefresh();
            //                     }
            //                   });
            //                 },
            //                 icon: Icon(Icons.delete, color: Colors.red,),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

}