import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/todo_list.dart';
import 'package:flutter_todo/utils/ThemeProvider.dart';
import 'package:provider/provider.dart';

import 'file:///C:/Users/dista/Desktop/Flutter%20workspace/flutter_todo/lib/ui/components/confirm_dialog.dart';

// Irrelevant change
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<TodoListState> _mListKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Todo List'),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (ctx) {
              return [
                PopupMenuItem(
                    value: 0,
                    child: Text(
                        themeModel.lightTheme ? 'Dark mode' : 'Light mode')),
                PopupMenuItem(
                  value: 1,
                  child: Text((_mListKey.currentState.incompleteItems != 0)
                      ? 'Mark all'
                      : 'Reset'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text('Clear'),
                )
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case 0: // Theme!
                  themeModel.lightTheme = !themeModel.lightTheme;
                  break;
                case 1: // Mark all/reset
                  // Updating UI
                  setState(() {
                    if (!_mListKey.currentState.isEmpty) {
                      _mListKey.currentState.markAll(
                          mark: _mListKey.currentState.incompleteItems != 0);
                    } else {
                      _mListKey.currentState
                          .showSnackBar(text: 'Please add some items first');
                    }
                  });
                  break;
                case 2: // Clear
                  if (!_mListKey.currentState.isEmpty) {
                    final result = await ConfirmDialog.pop(context);
                    // Clearing list
                    if (result) _mListKey.currentState.clearList();
                  } else {
                    _mListKey.currentState
                        .showSnackBar(text: 'Please add some items first');
                  }
                  break;
              }
            },
            icon: Icon(Icons.menu),
          )
        ],
      ),
      body: TodoList(
        key: _mListKey,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add a new todoItem
          _mListKey.currentState.addNewItem();
        },
      ),
    );
  }
}
