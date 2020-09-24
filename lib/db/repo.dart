import 'package:flutter_todo/db/models.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class TodoRepo {
  int newItemId = 0;

  Future<Database> _getDatabase() async {
    return openDatabase(path.join(await getDatabasesPath(), 'todo.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE todos(id INTEGER PRIMARY KEY, text TEXT, createdAt TEXT, status INTEGER)");
    }, version: 1);
  }

  Future<void> insertTodoItem(TodoItem todoItem) async {
    final Database db = await _getDatabase();

    await db.insert('todos', todoItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Updating lastId
    newItemId++;
  }

  List<TodoItem> _generateList(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      return TodoItem.get(
          id: maps[i]['id'],
          text: maps[i]['text'],
          status: (maps[i]['status'] == 1) ? true : false,
          createdAt: maps[i]['createdAt']);
    });
  }

  clear() async {
    Database db = await _getDatabase();
    db.rawQuery("DELETE FROM todos");
    // Resetting newItemId
    newItemId = 0;
  }

  Future<List<TodoItem>> todoItems() async {
    final Database db = await _getDatabase();

    final List<Map<String, dynamic>> maps =
        await db.query('todos', where: 'status = ?', whereArgs: [0]);
    final List<Map<String, dynamic>> markedMaps =
        await db.query('todos', where: 'status = ?', whereArgs: [1]);

    List<TodoItem> todoItems = _generateList(maps);
    todoItems.addAll(_generateList(markedMaps));

    // Updating lastId
    this.newItemId =
        (todoItems.isEmpty) ? 0 : todoItems[todoItems.length - 1].id + 1;

    return todoItems;
  }

  Future<void> updateTodo(TodoItem item) async {
    final db = await _getDatabase();

    await db
        .update('todos', item.toMap(), where: "id = ?", whereArgs: [item.id]);
  }

  Future<void> deleteTodo(int id) async {
    final db = await _getDatabase();

    await db.delete('todos', where: "id = ?", whereArgs: [id]);
  }
}
