import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart' as sql;

import 'package:battery_app/pages/notification_setter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import './pages/notification_setter.dart';

class SQLHelper {
  final String dbName;
  Database? _db;
  List<Battery> _batterys = [];
  final _streamController = StreamController<List<Battery>>.broadcast();

  SQLHelper({required this.dbName});

  //Shamikh's part starts
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

  // Create a new record
  static Future<int> createItem(String percentage) async {
    final db = await SQLHelper.db();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedDateWithTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    // Formatted date is used as primary key so that only one record can exist for each day
    final data = {
      'id': formattedDate,
      'percentage': percentage,
      'createdAt': formattedDateWithTime
    };
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all records
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.rawQuery('SELECT * FROM items ORDER BY date(id) DESC');
  }

  // Read a single record by date
  static Future<List<Map<String, dynamic>>> getItem() async {
    final db = await SQLHelper.db();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return db.query('items',
        where: "id = ?", whereArgs: [formattedDate], limit: 1);
  }

  //Update a record by date
  static Future<int> updateItem(String percentage) async {
    final db = await SQLHelper.db();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedDateWithTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final data = {'percentage': percentage, 'createdAt': formattedDateWithTime};

    final result = await db
        .update('items', data, where: "id = ?", whereArgs: [formattedDate]);
    return result;
  }

  // Delete any record that is older than 10 days from the present date
  static Future<void> deleteItem() async {
    final db = await SQLHelper.db();
    try {
      await db.rawQuery(
          "DELETE FROM items WHERE createdAt <= datetime('now','-9 day')");
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
  //Shamikh's part ends

  //Shehani's part starts
  //CREATE THE BATTERY ALERT (CRUD)
  Future create(int batteryLevel, int isTriggered) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final id = await db.insert('BATTERYINFO',
          {'BATTERY_LEVEL': batteryLevel, 'IS_TRIGGERED': isTriggered});

      //read all the existing Battery objects from the DB
      //_streamController - the gateway which contains a stream allowing not only to read the data, but also to write the data
      final battery =
          Battery(id: id, batteryLevel: batteryLevel, isTriggered: isTriggered);
      _batterys.add(battery);
      _streamController.add(_batterys);
      return true;
    } catch (e) {
      print('Error in creating battery =$e');
      return false;
    }
  }

  //READ THE BATTERY ALERT (CRUD)
  Future<List<Battery>> _fetchbatteryinfo() async {
    final db = _db;
    if (db == null) {
      return [];
    }
    try {
      final read = await db.query('BATTERYINFO',
          distinct: true, columns: ['ID', 'BATTERY_LEVEL'], orderBy: 'ID');

      //DB data is read and it is saved to batteryinfo variable as a map function
      final batteryinfo = read.map((row) => Battery.fromRow(row)).toList();
      return batteryinfo;
    } catch (e) {
      print('Error fetching batteryinfo  = $e');
      return [];
    }
  }

  //UPDATE THE BATTERY ALERT (CRUD)
  Future<bool> update(Battery battery) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final updateCount = await db.update(
        'BATTERYINFO',
        {'BATTERY_LEVEL': battery.batteryLevel},
        where: 'ID=?',
        whereArgs: [battery.id],
      );

      if (updateCount == 1) {
        _batterys.removeWhere((other) => other.id == battery.id);
        _batterys.add(battery);
        _streamController.add(_batterys);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Failed to update battery, error = $e');
      return false;
    }
  }

  //DELETE THE BATTERY ALERT (CRUD)
  Future<bool> delete(Battery battery) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final deletedCount = await db.delete(
        'BATTERYINFO',
        where: 'ID = ?',
        whereArgs: [battery.id],
      );

      if (deletedCount == 1) {
        _batterys.remove(battery);
        _streamController.add(_batterys);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Deletion failed with error $e');
      return false;
    }
  }

  //Close the DB
  Future<bool> close() async {
    final db = _db;
    if (db == null) {
      return false;
    }

    await db.close();
    return true;
  }

  //Open and read the DB
  Future<bool> open() async {
    if (_db != null) {
      return true;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$dbName';

    try {
      final db = await openDatabase(path);
      _db = db;

      //CREATE THE DB TABLE
      const create = '''CREATE TABLE IF NOT EXISTS BATTERYINFO (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        BATTERY_LEVEL INT NOT NULL,
        IS_TRIGGERED INT NOT NULL
      )''';

      await db.execute(create);

      //READ ALL THE EXISTING BATTERY OBJECTS FROM THE DB
      _batterys = await _fetchbatteryinfo();
      _streamController.add(_batterys);

      return true;
    } catch (e) {
      print('Error = $e');
      return false;
    }
  }

  Stream<List<Battery>> all() =>
      _streamController.stream.map((Batterys) => Batterys..sort());
  //Shehani's part ends
}
