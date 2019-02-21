import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../entity/plan_entity.dart';
import '../entity/plan_book_entity.dart';

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

  Future<Database> get _dbFile async {
    final path = await _dbPath;
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE plan_info (id INTEGER PRIMARY KEY, name TEXT, total INTEGER, current INTEGER, end_date TEXT)");
      await db.execute(
          "CREATE TABLE book_info (id INTEGER PRIMARY KEY, plan_id INTEGER, title TEXT, done_date TEXT, is_read INTEGER)");
    });
    return database;
  }

  Future<int> insertPlanInfo(
      String name, int total, int current, String endDate) async {
    final db = await _dbFile;
    return await db.rawInsert(
        'INSERT INTO plan_info(name, total, current, end_date) VALUES("$name", "$total", "$current", "$endDate")');
  }

  Future<List<PlanEntity>> getPlanInfo() async {
    final db = await _dbFile;
    List<Map> maps = await db.query('plan_info',
        columns: ['id', 'name', 'total', 'current', 'end_date']);
    List<PlanEntity> res =
        maps.map((item) => new PlanEntity.formMap(item)).toList();
    return res;
  }

  Future<int> updatePlanCurrent(int id) async {
    final db = await _dbFile;
    int count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM book_info where plan_id=$id and is_read=1'));
    return await db
        .rawUpdate('update plan_info set current=$count where id=?', [id]);
  }

  Future<int> insertBook(int planId, String bookTitle, String doneDate) async {
    final db = await _dbFile;
    return await db.rawInsert(
        'INSERT INTO book_info(plan_id, title, done_date, is_read) VALUES("$planId", "$bookTitle", "$doneDate", 0)');
  }

  Future<List<PlanBookEntity>> getPlanBook(int planId) async {
    final db = await _dbFile;
    List<Map> maps = await db.query('book_info',
        columns: ['id', 'plan_id', 'title', 'done_date', 'is_read'],
        where: 'plan_id=?',
        whereArgs: [planId]);
    List<PlanBookEntity> res =
        maps.map((item) => new PlanBookEntity.formMap(item)).toList();
    return res;
  }

  Future<int> updatePlanBookRead(int id) async {
    final db = await _dbFile;
    var formatter = new DateFormat('yyyy年MM月dd日');
    String doneTime = formatter.format(DateTime.now());
    return await db.rawUpdate(
        'update book_info set is_read=1, done_date=? where id=?',
        [doneTime, id]);
  }

  Future<int> updatePlanBookDoneDate(int id, String doneDate) async {
    final db = await _dbFile;
    return await db.rawUpdate(
        'update book_info set done_date=? where id=?', [doneDate, id]);
  }

  Future<int> deletePlanBook(int id) async {
    final db = await _dbFile;
    return await db.rawDelete('DELETE FROM book_info WHERE id = ?', [id]);
  }
}
