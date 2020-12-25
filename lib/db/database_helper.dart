import 'dart:async';

import 'package:path/path.dart' as PathUtils;
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static const String dbName = 'douban.db';
  static const int dbVersion = 1;
  static final String likeTable = 'like_table';
  factory DbHelper() => _getInstance();

  static DbHelper get instance => _getInstance();
  static DbHelper _instance;

  DbHelper._internal();

  static DbHelper _getInstance() {
    if (_instance == null) {
      _instance = new DbHelper._internal();
    }
    return _instance;
  }

  Database _db;

  Future<Database> get db async {
    if (_db == null) _db = await _initDb();
    return _db;
  }

  _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = PathUtils.join(databasesPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) => db.execute(
      'create table $likeTable'
      '("id" TEXT primary key,'
      ' "title" text, "img" text, "type" text, "score" REAL)');
  
  void close() async {
    if (_db != null) await _db.close();
  }
}
