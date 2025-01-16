import 'package:flutter/material.dart';
import 'package:study_app/src/models/choice.dart';

class ExpandableChoicesList extends StatefulWidget {
  final Function(List<Choice>) onChoicesChanged;

  const ExpandableChoicesList({super.key, required this.onChoicesChanged});

  @override
  _ExpandableCardListState createState() => _ExpandableCardListState();
}

class _ExpandableCardListState extends State<ExpandableChoicesList> {
  final List<Choice> _choices = [];

  // Creating controllers for each choice
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    // Initializing controllers
    for (var choice in _choices) {
      _controllers.add(TextEditingController(text: choice.choiceText));
    }
  }

  @override
  void dispose() {
    // Disposing controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addChoice() {
    setState(() {
      _choices.add(Choice(choiceText: '', isCorrect: false));
      _controllers.add(TextEditingController());
      _notifyParent();
    });
  }

  void _notifyParent() {
    widget.onChoicesChanged(_choices);
  }

  _removeChoice(int index) {
    setState(() {
      _choices.removeAt(index);
      _controllers.removeAt(index);
      _notifyParent();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Choice> choiceList = List.from(_choices);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ..._choices.map((choice) {
              int index = _choices.indexOf(choice);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          value: choice.isCorrect,
                          onChanged: (value) {
                            setState(() {
                              for (var c in _choices) {
                                c.isCorrect = false; // Uncheck all other choices
                              }
                              choice.isCorrect = value!; // Check the selected choice
                              _notifyParent();
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: TextField(
                            controller: _controllers[index],
                            onChanged: (value) {
                              setState(() {
                                _choices[index].choiceText = value;
                                _notifyParent();
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Edit Choice Text',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeChoice(index);
                        },
                      ),
                    ],
                  )
                ),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addChoice,
                child: const Text('Add Choice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

