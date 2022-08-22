import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration/sqflite_migration.dart';

class FilesMigrationDB {
  static const _databaseName = "ente.files_migration.db";
  static final Logger _logger = Logger((FilesMigrationDB).toString());

  static const tableName = 're_upload_tracker';
  static const _columnLocalID = 'local_id';
  static const _columnReason = 'reason';
  static const missingLocation = 'missing_location';
  static const modificationTimeUpdated = 'modificationTimeUpdated';

  // SQL code to create the database table
  static List<String> _createTable() {
    return [
      ''' 
      CREATE TABLE $tableName (
      $_columnLocalID TEXT NOT NULL,
      UNIQUE($_columnLocalID)
      ); 
      ''',
    ];
  }

  static List<String> addReasonColumn() {
    return [
      '''
        ALTER TABLE $tableName ADD COLUMN $_columnReason TEXT;
      ''',
      '''
        UPDATE $tableName SET $_columnReason = '$missingLocation';
      ''',
    ];
  }

  static final initializationScript = [..._createTable()];
  static final migrationScripts = [
    ...addReasonColumn(),
  ];
  final dbConfig = MigrationConfig(
    initializationScript: initializationScript,
    migrationScripts: migrationScripts,
  );

  FilesMigrationDB._privateConstructor();

  static final FilesMigrationDB instance =
      FilesMigrationDB._privateConstructor();

  // only have a single app-wide reference to the database
  static Future<Database> _dbFuture;

  Future<Database> get database async {
    // lazily instantiate the db the first time it is accessed
    _dbFuture ??= _initDatabase();
    return _dbFuture;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    debugPrint("DB path " + path);
    return await openDatabaseWithMigration(path, dbConfig);
  }

  Future<void> clearTable() async {
    final db = await instance.database;
    await db.delete(tableName);
  }

  Future<void> insertMultiple(
    List<String> fileLocalIDs,
    String reason,
  ) async {
    final startTime = DateTime.now();
    final db = await instance.database;
    var batch = db.batch();
    int batchCounter = 0;
    for (String localID in fileLocalIDs) {
      if (batchCounter == 400) {
        await batch.commit(noResult: true);
        batch = db.batch();
        batchCounter = 0;
      }
      batch.insert(
        tableName,
        _getRowForReUploadTable(localID, reason),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      batchCounter++;
    }
    await batch.commit(noResult: true);
    final endTime = DateTime.now();
    final duration = Duration(
      microseconds:
          endTime.microsecondsSinceEpoch - startTime.microsecondsSinceEpoch,
    );
    _logger.info(
      "Batch insert of ${fileLocalIDs.length} "
      "took ${duration.inMilliseconds} ms.",
    );
  }

  Future<void> deleteByLocalIDs(List<String> localIDs, String reason) async {
    if (localIDs.isEmpty) {
      return;
    }
    String inParam = "";
    for (final localID in localIDs) {
      inParam += "'" + localID + "',";
    }
    inParam = inParam.substring(0, inParam.length - 1);
    final db = await instance.database;
    db.rawQuery(
      '''
      DELETE FROM $tableName
      WHERE $_columnLocalID IN ($inParam) AND $_columnReason = $reason;
    ''',
    );
  }

  Future<List<String>> getLocalIDsForPotentialReUpload(
    int limit,
    String reason,
  ) async {
    final db = await instance.database;
    String whereClause = '$_columnReason = "$reason"';
    final rows = await db.query(
      tableName,
      limit: limit,
      where: whereClause,
    );
    final result = <String>[];
    for (final row in rows) {
      result.add(row[_columnLocalID]);
    }
    return result;
  }

  Map<String, dynamic> _getRowForReUploadTable(String localID, String reason) {
    assert(localID != null);
    final row = <String, dynamic>{};
    row[_columnLocalID] = localID;
    row[_columnReason] = reason;
    return row;
  }
}
