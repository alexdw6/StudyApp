import 'package:flutter/material.dart';
import 'package:study_app/src/models/choice.dart';

class ExpandableChoicesList extends StatefulWidget {
  final Function(List<Choice>) onChoicesChanged;
  final List<Choice>? initialChoices;

  const ExpandableChoicesList({super.key, required this.onChoicesChanged, this.initialChoices});

  @override
  _ExpandableCardListState createState() => _ExpandableCardListState();
}

class _ExpandableCardListState extends State<ExpandableChoicesList> {
  late List<Choice> _choices;
  final List<TextEditingController> _textControllers = [];
  final List<TextEditingController> _explanationControllers = [];

  @override
  void initState() {
    super.initState();
    _choices = widget.initialChoices ?? [];

    // Initialize controllers
    for (var choice in _choices) {
      _textControllers.add(TextEditingController(text: choice.choiceText));
      _explanationControllers.add(TextEditingController(text: choice.explanation ?? ""));
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _textControllers) {
      controller.dispose();
    }
    for (var controller in _explanationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addChoice() {
    setState(() {
      _choices.add(Choice(choiceText: '', isCorrect: false, explanation: ''));
      _textControllers.add(TextEditingController());
      _explanationControllers.add(TextEditingController());
      _notifyParent();
    });
  }

  void _removeChoice(int index) {
    setState(() {
      _choices.removeAt(index);
      _textControllers.removeAt(index);
      _explanationControllers.removeAt(index);
      _notifyParent();
    });
  }

  void _notifyParent() {
    widget.onChoicesChanged(_choices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ..._choices.asMap().entries.map((entry) {
              int index = entry.key;
              Choice choice = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              value: choice.isCorrect,
                              onChanged: (value) {
                                setState(() {
                                  for (var c in _choices) {
                                    c.isCorrect = false; // Uncheck all other choices
                                  }
                                  choice.isCorrect = value!;
                                  _notifyParent();
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              title: TextField(
                                controller: _textControllers[index],
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _removeChoice(index);
                            },
                          ),
                        ],
                      ),
                      if (choice.isCorrect) // Show explanation field only when checked
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextField(
                            controller: _explanationControllers[index],
                            onChanged: (value) {
                              setState(() {
                                _choices[index].explanation = value;
                                _notifyParent();
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Explanation (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
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

