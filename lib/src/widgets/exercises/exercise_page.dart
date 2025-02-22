import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/managers/question_manager.dart';
import 'package:study_app/src/models/choice.dart';
import 'package:study_app/src/models/question_data.dart';

import '../../dao/question_dao.dart';
import '../../models/question.dart';


class QuestionExercisePage extends StatefulWidget {
  final int listSize;
  final int? groupId;
  final bool? isCorrect;
  final bool? isRandomized;

  QuestionExercisePage({required this.listSize, this.groupId, this.isCorrect, this.isRandomized});

  @override
  State<StatefulWidget> createState() => _QuestionExercisePageState();
}

class _QuestionExercisePageState extends State<QuestionExercisePage> {
  final QuestionDao _questionDao = GetIt.I<QuestionDao>();
  final QuestionManager _questionManager = GetIt.I<QuestionManager>();
  List<QuestionData> _questionData = [];
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
    bool? isCorrect = widget.isCorrect;

    List<QuestionData> questionData = [];

    if (groupId != null) {
      questionData = await _questionManager.getQuestionDataFromGroup(groupId);
    } else if (isCorrect != null) {
      List<Question> questions = await _questionManager.getCorrectQuestions(isCorrect);
      for (var question in questions) {
        questionData.add(await _questionManager.getQuestionWithChoicesAndAnswer(question.id!));
      }
    } else {
      questionData = [];
    }

    if (widget.isRandomized != null && widget.isRandomized!) {
      questionData.shuffle();
    }

    if (listSize != null && listSize != 0 && questionData.length > listSize) {
      questionData.length = listSize;
    }

    setState(() {
      _questionData = questionData;
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

      if (currentPageIndex < _questionData.length - 1) {
        setState(() {
          currentPageIndex++;
          selectedChoiceId = null; // Reset for next question
          meaningController.clear();
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryPage(
              questionData: _questionData,
              userAnswers: userAnswers,
            ),
          ),
        ).then((value) {
          if (value == true) {
            // Perform any action after the user finishes the summary
            Navigator.pop(context, value); // Navigate back to IncorrectQuestionsPage
          }
        });
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
          child: _questionData.isEmpty
              ? Center(child: CircularProgressIndicator()) // Show loading or empty state
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _questionData[currentPageIndex].question.questionText,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _questionData[currentPageIndex].choices.length,
                  itemBuilder: (context, index) {
                    final choice = _questionData[currentPageIndex].choices[index];
                    return CheckboxListTile(
                      title: Text(choice.choiceText),
                      controlAffinity: ListTileControlAffinity.leading,
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
        return await _showAlertDialog(context, message) ?? false;
      },
    );
  }
}

class SummaryPage extends StatelessWidget {
  final QuestionManager _questionManager = GetIt.I<QuestionManager>();

  final List<QuestionData> questionData;
  final List<int?> userAnswers;
  String _score = "";

  SummaryPage({super.key, required this.questionData, required this.userAnswers});

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
                itemCount: questionData.length,
                itemBuilder:(context, index) {
                  return Card(
                    child: _checkAnswer(index),
                  );
                },
              )
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }

  ListTile _checkAnswer(int index) {
    QuestionData currentQuestion = questionData[index];
    Choice correctAnswer = questionData[index].choices.where((choice) => choice.isCorrect == true).first;
    int correctAnswerIndex = currentQuestion.choices.indexWhere((c) => c.id == correctAnswer.id);
    Choice userAnswer = questionData[index].choices.where((choice) => choice.id == userAnswers[index]!).first;

    if (userAnswer.isCorrect){
      return ListTile(
          title: Text(
            "Question ${index + 1}) ${questionData[index].question.questionText}",
            style: const TextStyle(color: Colors.green),
          ),
          subtitle: Text("Correct answer: ${correctAnswerIndex + 1}) ${correctAnswer.choiceText}"),
        );
      } else {
        return ListTile(
          title: Text(
            "Question ${index + 1}) ${questionData[index].question.questionText}",
            style: const TextStyle(color: Colors.red),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Correct answer: ${correctAnswerIndex + 1}) ${correctAnswer.choiceText} | Your answer: ${userAnswer.choiceText}",
              ),
              const SizedBox(height: 4), // Optional spacing
              Text(
                "Explanation: ${correctAnswer.explanation}",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );
    }
  }

  void _calculateResult() async {
    int result = 0;
    for (int i = 0; i < questionData.length;i++) {
      int choiceIndex = userAnswers[i]!;
      QuestionData currentQuestion = questionData[i];
      Choice currentChoice = currentQuestion.choices.where((choice) => choice.id == choiceIndex).first;
      if (currentChoice.isCorrect) {
        result++;
        currentQuestion.question.gotCorrect = true;
      } else {
        currentQuestion.question.gotCorrect = false;
      }
    }

    _score = "$result/${questionData.length}";

    await _questionManager.updateGotCorrectInBatch(questionData.map((questionData) => questionData.question).toList());
  }
}
