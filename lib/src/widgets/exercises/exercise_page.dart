import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/managers/question_manager.dart';
import 'package:study_app/src/models/question_data.dart';

import '../../dao/question_dao.dart';
import '../../models/question.dart';


class QuestionExercisePage extends StatefulWidget {
  final int listSize;
  final int? groupId;

  QuestionExercisePage({required this.listSize, this.groupId});

  @override
  State<StatefulWidget> createState() => _QuestionExercisePageState();
}

class _QuestionExercisePageState extends State<QuestionExercisePage> {
  final QuestionDao _questionDao = GetIt.I<QuestionDao>();
  final QuestionManager _questionManager = GetIt.I<QuestionManager>();
  List<QuestionData> _questions = [];
  int currentPageIndex = 0;
  List<int?> userAnswers = [];
  TextEditingController meaningController = TextEditingController();
  int? selectedChoiceId;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    int listSize = widget.listSize;
    int? groupId = widget.groupId;

    List<QuestionData> questions = [];

    if (groupId != null) {
      questions = await _questionManager.getQuestionDataFromGroup(groupId);
    } else {
      questions = [];
    }

    setState(() {
      _questions = questions;
    });
  }

  Future<bool> _showAlertDialog(BuildContext context, String message) async {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Do you want to continue?"),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return result ?? false;
  }

  void _checkAnswerAndMoveToNext() {
    if (selectedChoiceId != null) {
      userAnswers.add(selectedChoiceId);

      if (currentPageIndex < _questions.length - 1) {
        setState(() {
          currentPageIndex++;
          selectedChoiceId = null; // Reset for next question
          meaningController.clear();
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryPage(questions: _questions, userAnswers: userAnswers),
          ),
        );
      }
    } else {
      // Handle case where no choice is selected
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an answer before proceeding.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _questions[currentPageIndex].question.questionText,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _questions[currentPageIndex].choices.length,
                    itemBuilder: (context, index) {
                      final choice = _questions[currentPageIndex].choices[index];
                      return CheckboxListTile(
                        title: Text(choice.choiceText),
                        value: selectedChoiceId == choice.id,
                        onChanged: (value) {
                          setState(() {
                            selectedChoiceId = value! ? choice.id : null;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _checkAnswerAndMoveToNext();
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          String message = "Are you sure you want to quit the exercise?";
          return await _showAlertDialog(context, message);
        }
    );
  }
}

class SummaryPage extends StatelessWidget {
  final List<QuestionData> questions;
  final List<int?> userAnswers;
  String _score = "";

  SummaryPage({super.key, required this.questions, required this.userAnswers});

  @override
  Widget build(BuildContext context) {
    _calculateResult();

    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Summary'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'YOUR SCORE: $_score',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder:(context, index) {
                  return Card(
                    child: _checkAnswer(index),
                  );
                },
              )
          )
        ],
      ),
    );
  }

  ListTile _checkAnswer(int index) {
    // if (userAnswers[index] == questions[index].word) {
    //   return ListTile(
    //     title: Text(
    //       "CORRECT: ${questions[index].meaning} is ${userAnswers[index]}",
    //       style: const TextStyle(color: Colors.green),
    //     ),
    //   );
    // } else {
    //   return ListTile(
    //     title: Text(
    //       "WRONG: ${questions[index].meaning} is ${questions[index].word}",
    //       style: const TextStyle(color: Colors.red),
    //     ),
    //     subtitle: Text("YOU WROTE: ${userAnswers[index]}"),
    //   );
    // }
    if (questions[index].choices[userAnswers[index]!].isCorrect){
      return ListTile(
          title: Text(
            "CORRECT: The correct answer is ${questions[index].choices[userAnswers[index]!].choiceText}",
            style: const TextStyle(color: Colors.green),
          ),
        );
      } else {
        return ListTile(
          title: Text(
            "WRONG: The correct answer is ${questions[index].choices[userAnswers[index]!].choiceText}",
            style: const TextStyle(color: Colors.red),
          ),
          subtitle: Text("YOU WROTE: ${userAnswers[index]}"),
        );
    }
  }

  void _calculateResult() {
    int result = 0;
    for (int i = 0; i < questions.length;i++) {
      int choiceIndex = userAnswers[i]!;
      QuestionData currentQuestion = questions[i];
      if (currentQuestion.choices[choiceIndex].isCorrect) {
        result++;
        currentQuestion.question.gotCorrect = true;
      } else {
        currentQuestion.question.gotCorrect = false;
      }
    }
    _score = "$result/${questions.length}";
  }
}
