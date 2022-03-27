import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
part 'app_details.g.dart';

class AppDetails extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get appName => text().nullable()();
  TextColumn get appPackageName => text().nullable()();
}

@DriftDatabase(tables: [AppDetails])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<AppDetail>> get getAllApps => select(appDetails).watch();

  Future<int?> createOrUpdateAppDetail(AppDetailsCompanion appDetail) {
    return into(appDetails).insertOnConflictUpdate(appDetail);
  }

  Future deleteAppDetail(int appid) {
    return (delete(appDetails)..where((t) => t.id.isIn([appid]))).go();
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
