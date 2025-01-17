import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/choice_dao.dart';
import 'package:study_app/src/dao/question_dao.dart';
import 'package:study_app/src/managers/choice_manager.dart';
import 'package:study_app/src/managers/question_manager.dart';
import 'package:study_app/src/services/database_manager.dart';
import 'package:study_app/src/widgets/groups/group_list_page.dart';
import 'package:study_app/src/widgets/questions/question_list_page.dart';

import 'dao/group_dao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize DB
  DatabaseManager databaseManager = DatabaseManager();
  await databaseManager.initializeDatabase();

  // register singletons
  GetIt.I.registerSingleton<DatabaseManager>(databaseManager);
  GetIt.I.registerSingleton<ChoiceDao>(ChoiceDao());
  GetIt.I.registerSingleton<QuestionDao>(QuestionDao());
  GetIt.I.registerSingleton<GroupDao>(GroupDao());

  GetIt.I.registerSingleton<QuestionManager>(QuestionManager());
  GetIt.I.registerSingleton<ChoiceManager>(ChoiceManager());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[GroupListPage(), QuestionListPage()];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: _widgetOptions[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            destinations: const <Widget>[
              NavigationDestination(
                  icon: Icon(Icons.book),
                  label: 'Questions'
              ),
              // NavigationDestination(
              //     icon: Icon(Icons.border_color),
              //     label: 'Exercise'
              // ),
              NavigationDestination(
                  icon: Icon(Icons.class_),
                  label: 'questions'
              )
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
        onWillPop: () async {
          // if (_selectedIndex != 0) {
          //   setState(() {
          //     _selectedIndex = 0;
          //   });
          //   return false;
          // }
          return true;
        }
    );
  }
}
