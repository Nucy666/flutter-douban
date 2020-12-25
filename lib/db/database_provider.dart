import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

abstract class TableProvider<T> {
  /// Provider 绑定的表名
  String get table;

  Future<Database> get db async => await DbHelper.instance.db;

  /// [T] 类的属性和数据库表格的映射转化
  Map<String, dynamic> toMap(T t);

  /// [T] 类的属性和数据库表格的映射转化
  T fromMap(Map<String, dynamic> map);

  Future<int> insert(T t,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) async {
    var _db = await db;
    return _db.insert(table, toMap(t),
        nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
  }

  insertAll(List<T> list,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) async {
    var _db = await db;
    var batch = _db.batch();
    list.forEach((t) => batch.insert(table, toMap(t),
        nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm));
    return batch.commit();
  }

  /// Helper to query a table
  ///
  /// @param distinct true if you want each row to be unique, false otherwise.
  /// @param columns A list of which columns to return. Passing null will
  ///            return all columns, which is discouraged to prevent reading
  ///            data from storage that isn't going to be used.
  /// @param where A filter declaring which rows to return, formatted as an SQL
  ///            WHERE clause (excluding the WHERE itself). Passing null will
  ///            return all rows for the given URL.
  /// @param groupBy A filter declaring how to group rows, formatted as an SQL
  ///            GROUP BY clause (excluding the GROUP BY itself). Passing null
  ///            will cause the rows to not be grouped.
  /// @param having A filter declare which row groups to include in the cursor,
  ///            if row grouping is being used, formatted as an SQL HAVING
  ///            clause (excluding the HAVING itself). Passing null will cause
  ///            all row groups to be included, and is required when row
  ///            grouping is not being used.
  /// @param orderBy How to order the rows, formatted as an SQL ORDER BY clause
  ///            (excluding the ORDER BY itself). Passing null will use the
  ///            default sort order, which may be unordered.
  /// @param limit Limits the number of rows returned by the query,
  /// @param offset starting index,

  /// @return the items found
  Future<List<T>> query(
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {
    var _db = await db;
    List<Map<String, dynamic>> result = await _db.query(table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);

    var list = List<T>();
    result.forEach((map) => list.add(fromMap(map)));

    return list;
  }

  /// Convenience method for updating rows in the database.
  ///
  /// [where] is the optional WHERE clause to apply when updating.
  /// Passing null will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictResolver] docs for more details
  Future<int> update(T t,
      {String where,
      List<dynamic> whereArgs,
      ConflictAlgorithm conflictAlgorithm}) async {
    var _db = await db;
    return _db.update(table, toMap(t),
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm);
  }

  /// Convenience method for updating rows in the database.
  ///
  /// [where] is the optional WHERE clause to apply when updating.
  /// Passing null will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictResolver] docs for more details
  updateAll(List<T> list,
      {String where,
      List<dynamic> whereArgs,
      ConflictAlgorithm conflictAlgorithm}) async {
    var _db = await db;
    var batch = _db.batch();
    list.forEach((t) => batch.update(table, toMap(t),
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm));
    return batch.commit();
  }

  /// Convenience method for deleting rows in the database.
  ///
  /// [where] is the optional WHERE clause to apply when updating. Passing null
  /// will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// Returns the number of rows affected if a whereClause is passed in, 0
  /// otherwise. To remove all rows and get a count pass '1' as the
  /// whereClause.
  Future<int> delete({String where, List<dynamic> whereArgs}) async {
    var _db = await db;
    return _db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> deleteAll() async {
    var _db = await db;
    return _db.delete(table);
  }
}
