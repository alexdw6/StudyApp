import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_app/src/widgets/exercises/exercise_page.dart';

class ExerciseStartPage extends StatefulWidget {
  final int? groupId;
  final bool isRandomized;

  ExerciseStartPage({this.groupId, required this.isRandomized});

  @override
  State<StatefulWidget> createState() => _ExerciseStartPageState();

}

class _ExerciseStartPageState extends State<ExerciseStartPage> {
  int? selectedAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Exercise Size"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createAmountDropdown(),
            if (selectedAmount != null)
              TextButton(
                onPressed: openExercise,
                child: const Text("Start Exercise"),
              ),
          ],
        ),
      ),
    );
  }

  Widget createAmountDropdown() {
    return DropdownButton<int>(
      value: selectedAmount,
      hint: const Text("Select amount"),
      items: const [
        DropdownMenuItem(value: 1, child: Text("1")),
        DropdownMenuItem(value: 5, child: Text("5")),
        DropdownMenuItem(value: 10, child: Text("10")),
        DropdownMenuItem(value: 25, child: Text("25")),
        DropdownMenuItem(value: 50, child: Text("50")),
        DropdownMenuItem(value: 100, child: Text("100")),
        DropdownMenuItem(value: 0, child: Text("All")),
      ],
      onChanged: (int? newValue) {
        setState(() {
          selectedAmount = newValue;
        });
      },
    );
  }

  void openExercise() {
    if (selectedAmount != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuestionExercisePage(groupId: widget.groupId, listSize: selectedAmount!, isRandomized: widget.isRandomized,),
        ),
      );
    }
  }
}


