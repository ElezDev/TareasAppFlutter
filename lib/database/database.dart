import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Task {
  int? id;
  String name;
  bool completed;
  String? imageUrl; // Nuevo campo

  Task(
      {this.id,
      required this.name,
      required this.completed,
      this.imageUrl}); // Actualizado

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "completed": completed ? 1 : 0,
      "imageUrl": imageUrl, // Nuevo campo
    };
  }

  Task.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'] ?? '',
        completed = map['completed'] == 1,
        imageUrl = map['imageUrl']; 
}


class TaskDatabase {
  late Database _db;

    Future<void> initDB() async {
    _db = await openDatabase(
      'my_tareass.db',
      version: 6, // Aumenta la versión de la base de datos
      onCreate: (Database db, int version) {
        try {
          db.execute(
              "CREATE TABLE tasks (id INTEGER PRIMARY KEY, name TEXT NOT NULL, completed INTEGER DEFAULT 0, imageUrl TEXT);"); // Actualizado
        } catch (e) {
          print("Error creating tasks table: $e");
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) {
        if ((oldVersion < 1) && (newVersion <= 6)) {
          db.execute(
              "ALTER TABLE tasks ADD COLUMN imageUrl TEXT;"); // Nuevo campo
        }
      },
    );
    print("DB INITIALIZED");
  }

  Future<void> insert(Task task) async {
    try {
      await _db.insert("tasks", task.toMap());
      print("Task inserted successfully");
    } catch (e) {
      print("Error inserting task: $e");
    }
  }

  Future<List<Task>> getAllTasks() async {
    try {
      List<Map<String, dynamic>> results = await _db.query("tasks");
      print("Number of tasks: ${results.length}");
      return results.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      print("Error querying tasks: $e");
      return [];
    }
  }

  Future updateTask(Task task) async {
    _db.update("tasks", task.toMap(), where: "id = ?", whereArgs: [task.id]);
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _db.delete("tasks", where: "id = ?", whereArgs: [taskId]);
      print("Task deleted successfully");
    } catch (e) {
      print("Error deleting task: $e");
    }
  }
}


