import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:battery_app/models/applications.dart';

class DatabaseHelper {
  //Create database
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'apps.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE applications(id INTEGER PRIMARY KEY AUTOINCREMENT, appName TEXT, hours INTEGER , note TEXT)',
        );
      },
      version: 1,
    );
  }

  // insert data
  Future<int> insertApplications(Applications app) async {
    final db = await initializeDB();
    final insertedId = await db.insert(
        'applications',
        app.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(insertedId);
    return insertedId;
  }

  // get all data
  Future<List<Applications>> applicationsList() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query('applications');
    return queryResult.map((e) => Applications.fromMapObject(e)).toList();
  }

  //delete data
  Future<void> deleteApplications(int id) async {
    final db = await initializeDB();
    await db.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // update data
  Future<int> updateApplications(Applications app) async {
    final db = await initializeDB();
    return await db.update(
      'applications',
      app.toMap(),
      where: 'id = ?',
      whereArgs: [app.id],
    );
  }
}
