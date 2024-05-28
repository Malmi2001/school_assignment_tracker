import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'school.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        contact TEXT,
      
      )'''
    );
    await db.execute(
      '''CREATE TABLE marks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER,
        term TEXT,
        subject TEXT,
        mark INTEGER,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE
      )'''
    );
  }

  Future<void> deleteMarks(int studentId) async {
    final db = await database;
    await db.delete('marks', where: 'studentId = ?', whereArgs: [studentId]);
  }

  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert('students', student);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query('students');
  }

  Future<void> updateStudent(Map<String, dynamic> student) async {
    final db = await database;
    await db.update('students', student, where: 'id = ?', whereArgs: [student['id']]);
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertMark(Map<String, dynamic> mark) async {
    final db = await database;
    await db.insert('marks', mark);
  }

  Future<List<Map<String, dynamic>>> getMarks(int studentId, String term) async {
    final db = await database;
    return await db.query('marks', where: 'studentId = ? AND term = ?', whereArgs: [studentId, term]);
  }

  Future<double> calculateAverageMarks(int studentId, String term) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'marks',
      where: 'studentId = ? AND term = ?',
      whereArgs: [studentId, term],
    );
    if (maps.isEmpty) return 0.0;
    double totalMarks = maps.fold(0, (sum, item) => sum + item['mark']);
    return totalMarks / maps.length;
  }
}