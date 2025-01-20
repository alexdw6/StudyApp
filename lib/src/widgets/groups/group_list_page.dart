import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:study_app/src/dao/group_dao.dart';
import 'package:study_app/src/widgets/groups/group_details_page.dart';
import 'package:study_app/src/widgets/questions/question_list_page.dart';

import '../../models/group.dart';
import 'add_group_page.dart';
import 'edit_group_page.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<StatefulWidget> createState() => _GroupListPageState();

}

class _GroupListPageState extends State<GroupListPage> {
  final GroupDao _groupDao = GetIt.I<GroupDao>();
  late List<Group> _groups;

  bool _isRefreshing = false;


  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _refreshGroupList() async {
    await _groupDao.getGroups().then((groups) {
      setState(() {
        _groups = groups;
        // _selectedList = List.filled(_verbs.length, false);
        _isRefreshing = false;
      });
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _refreshGroupList();
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Groups"),
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddGroupPage(),
              ));

              if (result) {
                _handleRefresh();
              }
            },
            icon: Icon(Icons.add),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => QuestionListPage(),
              ));
            },
            child: const Text("questions"))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isRefreshing
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
          itemCount: _groups.length,
          itemBuilder: (BuildContext context, int index) {
            Group group = _groups[index];
            return Card(
              child: ListTile(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GroupDetailsPage(groupId: group.id!),
                  ));

                  _handleRefresh();
                },
                title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                  <Widget>[
                    IconButton(
                      onPressed: () async {
                        await _showAlertDialog(context, "Are you sure you want to delete this group?").then((value) async {
                          if (value) {
                            await _groupDao.deleteGroup(group.id!);
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
        ),
      )
    );
  }
}
