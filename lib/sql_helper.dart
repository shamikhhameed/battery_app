import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  // static Future<void> createTables(sql.Database database) async {
  //   await database.execute("""CREATE TABLE items(
  //       id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  //       percentage TEXT,
  //       createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  //     )
  //     """);
  // }
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id String PRIMARY KEY NOT NULL,
        percentage TEXT,
        createdAt TIMESTAMP NOT NULL
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'batteryapp2.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createItem(String percentage) async {
    final db = await SQLHelper.db();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedDateWithTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final data = {
      'id': formattedDate,
      'percentage': percentage,
      'createdAt': formattedDateWithTime
    };
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    // return db.query('items', orderBy: "id DESC");
    // return db.query('items', orderBy: "convert(id,DATE,103) DESC");
    return db.rawQuery('SELECT * FROM items ORDER BY date(id) DESC');
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  // static Future<List<Map<String, dynamic>>> getItem(int id) async {
  //   final db = await SQLHelper.db();
  //   return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  // }

  // Read a single item by date
  static Future<List<Map<String, dynamic>>> getItem() async {
    final db = await SQLHelper.db();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return db.query('items',
        where: "id = ?", whereArgs: [formattedDate], limit: 1);
    // return db.rawQuery(
    //     "SELECT * FROM items WHERE createdAt >= ? AND createdAt <= ?", [
    //   "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 00:00:00.000000",
    //   "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 23:59:59.999999"
    // ]);
  }

  //Update an item by id
  static Future<int> updateItem(String percentage) async {
    final db = await SQLHelper.db();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedDateWithTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final data = {'percentage': percentage, 'createdAt': formattedDateWithTime};

    final result = await db
        .update('items', data, where: "id = ?", whereArgs: [formattedDate]);
    // await db.rawUpdate(
    //     "UPDATE items SET percentage = ?, createdAt = ? WHERE createdAt >= ? AND createdAt <= ?",
    //     [
    //   percentage.toString(),
    //   DateTime.now().toString(),
    //   "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 00:00:00",
    //   "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 23:59:59"
    // ]);
    return result;
  }

  // Delete
  static Future<void> deleteItem() async {
    final db = await SQLHelper.db();
    try {
      // await db.delete("items", where: "id = ?", whereArgs: [id]);
      await db.rawQuery("DELETE FROM items WHERE createdAt <= datetime('now','-9 day')");
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
