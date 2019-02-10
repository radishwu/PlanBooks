import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../entity/plan_entity.dart';

class DBManager {
  static final DBManager _singleton = new DBManager._internal();

  factory DBManager() {
    return _singleton;
  }

  DBManager._internal();

  Future<String> get _dbPath async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "read_plan.db");

    return path;
  }

  Future<Database> get _planFile async {
    final path = await _dbPath;
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE plan_info (id INTEGER PRIMARY KEY, name TEXT, total INTEGER, current INTEGER, end_date TEXT)");
    });
    return database;
  }

  Future<Database> get _bookFile async {
    final path = await _dbPath;

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE book_info (id INTEGER PRIMARY KEY, plan_id INTEGER, title TEXT, done_date TEXT)");
    });
    return database;
  }

  Future<int> insertPlanInfo(
      String name, int total, int current, String endDate) async {
    final db = await _planFile;
    return await db.rawInsert(
        'INSERT INTO plan_info(name, total, current, end_date) VALUES("$name", "$total", "$current", "$endDate")');
  }

  Future<List<PlanEntity>> getPlanInfo() async {
    final db = await _planFile;
    List<Map> maps = await db.query('plan_info',
        columns: ['id', 'name', 'total', 'current', 'end_date']);
    List<PlanEntity> res =
        maps.map((item) => new PlanEntity.formMap(item)).toList();
    return res;
  }

  Future<int> insertBook(int planId, String bookTitle, String doneDate) async {
    final db = await _bookFile;
    return await db.rawInsert(
        'INSERT INTO book_info(plan_id, title, done_date) VALUES("$planId", "$bookTitle", "$doneDate")');
  }
}
