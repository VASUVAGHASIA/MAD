import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/assignment.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('assignments.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE assignments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      courseCode TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      dueDateTime TEXT NOT NULL,
      status TEXT NOT NULL
    )
    ''');
  }

  Future<Assignment> create(Assignment a) async {
    final db = await instance.database;
    final id = await db.insert('assignments', a.toMap());
    a.id = id;
    return a;
  }

  Future<Assignment?> readAssignment(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'assignments',
      columns: ['id', 'courseCode', 'title', 'description', 'dueDateTime', 'status'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Assignment.fromMap(maps.first);
    return null;
  }

  Future<List<Assignment>> readAllAssignments() async {
    final db = await instance.database;
    final result = await db.query('assignments');
    final list = result.map((m) => Assignment.fromMap(m)).toList();
    list.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    return list;
  }

  Future<int> update(Assignment a) async {
    final db = await instance.database;
    return db.update('assignments', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('assignments', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
