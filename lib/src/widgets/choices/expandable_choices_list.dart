import 'package:flutter/material.dart';

class ExpandableChoicesList extends StatefulWidget {
  const ExpandableChoicesList({super.key});


  @override
  _ExpandableCardListState createState() => _ExpandableCardListState();
}

class _ExpandableCardListState extends State<ExpandableChoicesList> {
  final List<Map<String, dynamic>> _choices = [
    {"text": "", "isChecked": false}
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _choices.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  _choices[index]["text"] = value;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Enter choice',
                                ),
                              )
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          )
        )
      ],
    );
  }

}