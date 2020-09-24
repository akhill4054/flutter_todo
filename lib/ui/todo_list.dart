import 'package:flutter/material.dart';
import 'package:flutter_todo/db/models.dart';
import 'package:flutter_todo/db/repo.dart';

class TodoList extends StatefulWidget {
  TodoList({Key key}) : super(key: key);

  @override
  TodoListState createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  final _mRepo = TodoRepo();

  var _incompleteItems = 0;

  int get incompleteItems => _incompleteItems;

  List<TodoItem> _items;

  bool get isEmpty => (_items == null) ? 0 : _items.isEmpty;

  var _editPosition = -1;

  @override
  void initState() {
    super.initState();

    // Getting todoItems from db
    _getTodoItems();
  }

  _getTodoItems() async {
    // Getting todoItems and setting up the list
    _setTodoList(await _mRepo.todoItems());
  }

  _setTodoList(List<TodoItem> items) {
    // Updating the widget
    setState(() {
      this._items = items;

      // Getting incomplete item count
      for (TodoItem i in _items) {
        if (i.status) break;
        _incompleteItems++;
      }
    });
  }

  showSnackBar({@required String text, String actionLabel, Function action}) {
    // Hiding current snackBar, just in case
    Scaffold.of(context).hideCurrentSnackBar();

    final sb = SnackBar(
      content: Text(text),
      action: (actionLabel != null && action != null)
          ? SnackBarAction(
              label: actionLabel,
              onPressed: action,
            )
          : null,
    );

    // Showing snackBar
    Scaffold.of(context).showSnackBar(sb);
  }

  clearList() {
    setState(() {
      // SnackBar
      showSnackBar(text: 'Cleared todo list');

      // Resetting stuff
      _incompleteItems = 0;
      _editPosition = 0;
      _items.clear();

      // Clearing table in db
      _mRepo.clear();
    });
  }

  markAll({bool mark = true}) async {
    setState(() {
      _editPosition = -1; // Just in case

      for (TodoItem item in _items) {
        // Marking item
        _incompleteItems = (mark) ? 0 : _items.length;
        item.status = mark;
        // Updating item
        _mRepo.updateTodo(item);
      }
    });
  }

  addNewItem() {
    // Hiding current snackBar, just in case
    Scaffold.of(context).hideCurrentSnackBar();

    setState(() {
      final item = TodoItem(id: _mRepo.newItemId);

      _items.insert(_incompleteItems, item);

      // Inserting new item in db
      _mRepo.insertTodoItem(item);

      // Setting new edit position
      _editPosition = _incompleteItems;
      _incompleteItems++;
    });
  }

  _removeItem(int i) {
    final prevIncompleteCount = _incompleteItems;

    if (i >= _incompleteItems)
      i--;
    else
      _incompleteItems--;

    // Just in case
    _editPosition = -1;

    // Undo option
    final item = _items[i];
    showSnackBar(
        text: 'Item removed',
        actionLabel: 'undo',
        action: () {
          setState(() {
            // Inserting item back in db table
            _mRepo.insertTodoItem(item);
            // Adding item back in list
            _items.insert(i, item);
            // Resetting _incompleteItems
            if (!item.status) _incompleteItems++;
          });
        });

    setState(() {
      // Removing from db
      _mRepo.deleteTodo(_items[i].id);

      // Removing item
      _items.removeAt(i);
    });
  }

  _checkItem(int i, bool status) {
    // Hiding current snackBar, just in case
    Scaffold.of(context).hideCurrentSnackBar();

    setState(() {
      // Removing item from editMode
      if (i == _editPosition) _editPosition = -1;

      if (i >= _incompleteItems) i--;

      // Updating item in _items list
      final item = _items[i];
      _items[i].status = status;

      // Updating item in db
      _mRepo.updateTodo(item);

      // Moving item
      _items.removeAt(i);
      if (status) {
        // Item checked
        _incompleteItems--;
        var inserted = false;
        for (int i = _incompleteItems; i < _items.length; i++) {
          if (_items[i].id > item.id) {
            _items.insert(i, item);
            inserted = true;
            break;
          }
        }
        if (!inserted) _items.add(item);
      } else {
        // Item unchecked
        var inserted = false;
        for (int i = 0; i < _incompleteItems; i++) {
          if (_items[i].id > item.id) {
            _items.insert(i, item);
            inserted = true;
            break;
          }
        }
        if (!inserted) _items.insert(_incompleteItems, item);
        _incompleteItems++;
      }
    });
  }

  Widget _itemBuilder(BuildContext ctx, int i) {
    if (i == _incompleteItems) {
      // Add button
      return Column(
        children: [
          ListTile(
            onTap: () => addNewItem(),
            leading: Icon(Icons.add),
            title: Text(
              'Add new item',
            ),
          ),
          Divider(
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
        ],
      );
    } else {
      // List item
      int currPosition = (i >= _incompleteItems) ? i - 1 : i;
      TodoItem item = _items[currPosition];

      final isEditable = i == _editPosition;

      return Dismissible(
        key: UniqueKey(),
        background: Container(
          padding: EdgeInsets.only(left: 30),
          alignment: Alignment.centerLeft,
          color: Colors.redAccent,
          child: Icon(
            Icons.delete_sweep,
            color: Colors.white,
          ),
        ),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          // Removing item
          _removeItem(i);
        },
        child: ListTile(
          title: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: item.status,
                    onChanged: (bool value) => _checkItem(i, value),
                  ),
                  Expanded(
                    child: TextFormField(
                      autofocus: isEditable,
                      enabled: i < _incompleteItems,
                      onChanged: (value) {
                        item.text = value;
                        // Inserting in db
                        _mRepo.updateTodo(item);
                      },
                      controller: TextEditingController(text: item.text),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                          decoration: (item.status)
                              ? TextDecoration.lineThrough
                              : null),
                    ),
                  ),
                  Visibility(
                    visible: i >= _incompleteItems,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => _removeItem(i),
                    ),
                  ),
                ],
              ),
              Container(
                  margin: EdgeInsets.only(top: 5),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    item.formattedCreatedAt(),
                    style: TextStyle(fontSize: 12),
                  )),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: (_items == null) ? 0 : _items.length + 1,
      itemBuilder: (ctx, i) => _itemBuilder(ctx, i),
    );
  }
}
