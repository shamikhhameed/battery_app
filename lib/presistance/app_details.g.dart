// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_details.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class AppDetail extends DataClass implements Insertable<AppDetail> {
  final int id;
  final String? appName;
  final String? appPackageName;
  AppDetail({required this.id, this.appName, this.appPackageName});
  factory AppDetail.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return AppDetail(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      appName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}app_name']),
      appPackageName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}app_package_name']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || appName != null) {
      map['app_name'] = Variable<String?>(appName);
    }
    if (!nullToAbsent || appPackageName != null) {
      map['app_package_name'] = Variable<String?>(appPackageName);
    }
    return map;
  }

  AppDetailsCompanion toCompanion(bool nullToAbsent) {
    return AppDetailsCompanion(
      id: Value(id),
      appName: appName == null && nullToAbsent
          ? const Value.absent()
          : Value(appName),
      appPackageName: appPackageName == null && nullToAbsent
          ? const Value.absent()
          : Value(appPackageName),
    );
  }

  factory AppDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppDetail(
      id: serializer.fromJson<int>(json['id']),
      appName: serializer.fromJson<String?>(json['appName']),
      appPackageName: serializer.fromJson<String?>(json['appPackageName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'appName': serializer.toJson<String?>(appName),
      'appPackageName': serializer.toJson<String?>(appPackageName),
    };
  }

  AppDetail copyWith({int? id, String? appName, String? appPackageName}) =>
      AppDetail(
        id: id ?? this.id,
        appName: appName ?? this.appName,
        appPackageName: appPackageName ?? this.appPackageName,
      );
  @override
  String toString() {
    return (StringBuffer('AppDetail(')
          ..write('id: $id, ')
          ..write('appName: $appName, ')
          ..write('appPackageName: $appPackageName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, appName, appPackageName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppDetail &&
          other.id == this.id &&
          other.appName == this.appName &&
          other.appPackageName == this.appPackageName);
}

class AppDetailsCompanion extends UpdateCompanion<AppDetail> {
  final Value<int> id;
  final Value<String?> appName;
  final Value<String?> appPackageName;
  const AppDetailsCompanion({
    this.id = const Value.absent(),
    this.appName = const Value.absent(),
    this.appPackageName = const Value.absent(),
  });
  AppDetailsCompanion.insert({
    this.id = const Value.absent(),
    this.appName = const Value.absent(),
    this.appPackageName = const Value.absent(),
  });
  static Insertable<AppDetail> custom({
    Expression<int>? id,
    Expression<String?>? appName,
    Expression<String?>? appPackageName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appName != null) 'app_name': appName,
      if (appPackageName != null) 'app_package_name': appPackageName,
    });
  }

  AppDetailsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? appName,
      Value<String?>? appPackageName}) {
    return AppDetailsCompanion(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      appPackageName: appPackageName ?? this.appPackageName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String?>(appName.value);
    }
    if (appPackageName.present) {
      map['app_package_name'] = Variable<String?>(appPackageName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppDetailsCompanion(')
          ..write('id: $id, ')
          ..write('appName: $appName, ')
          ..write('appPackageName: $appPackageName')
          ..write(')'))
        .toString();
  }
}

class $AppDetailsTable extends AppDetails
    with TableInfo<$AppDetailsTable, AppDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppDetailsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _appNameMeta = const VerificationMeta('appName');
  @override
  late final GeneratedColumn<String?> appName = GeneratedColumn<String?>(
      'app_name', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _appPackageNameMeta =
      const VerificationMeta('appPackageName');
  @override
  late final GeneratedColumn<String?> appPackageName = GeneratedColumn<String?>(
      'app_package_name', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, appName, appPackageName];
  @override
  String get aliasedName => _alias ?? 'app_details';
  @override
  String get actualTableName => 'app_details';
  @override
  VerificationContext validateIntegrity(Insertable<AppDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('app_name')) {
      context.handle(_appNameMeta,
          appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta));
    }
    if (data.containsKey('app_package_name')) {
      context.handle(
          _appPackageNameMeta,
          appPackageName.isAcceptableOrUnknown(
              data['app_package_name']!, _appPackageNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    return AppDetail.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $AppDetailsTable createAlias(String alias) {
    return $AppDetailsTable(attachedDatabase, alias);
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $AppDetailsTable appDetails = $AppDetailsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [appDetails];
}
