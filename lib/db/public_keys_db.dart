// @dart=2.9

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photos/models/public_key.dart';
import 'package:sqflite/sqflite.dart';

class PublicKeysDB {
  static const _databaseName = "ente.public_keys.db";
  static const _databaseVersion = 1;

  static const table = 'public_keys';

  static const columnEmail = 'email';
  static const columnPublicKey = 'public_key';

  PublicKeysDB._privateConstructor();
  static final PublicKeysDB instance = PublicKeysDB._privateConstructor();

  static Future<Database> _dbFuture;

  Future<Database> get database async {
    _dbFuture ??= _initDatabase();
    return _dbFuture;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      '''
                CREATE TABLE $table (
                  $columnEmail TEXT PRIMARY KEY NOT NULL,
                  $columnPublicKey TEXT NOT NULL
                )
                ''',
    );
  }

  Future<void> clearTable() async {
    final db = await instance.database;
    await db.delete(table);
  }

  Future<int> setKey(PublicKey key) async {
    final db = await instance.database;
    return db.insert(
      table,
      _getRow(key),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PublicKey>> searchByEmail(String email) async {
    final db = await instance.database;
    return _convertRows(
      await db.query(
        table,
        where: '$columnEmail LIKE ?',
        whereArgs: ['%$email%'],
      ),
    );
  }

  Map<String, dynamic> _getRow(PublicKey key) {
    final row = <String, dynamic>{};
    row[columnEmail] = key.email;
    row[columnPublicKey] = key.publicKey;
    return row;
  }

  List<PublicKey> _convertRows(List<Map<String, dynamic>> rows) {
    final keys = <PublicKey>[];
    for (final row in rows) {
      keys.add(PublicKey(row[columnEmail], row[columnPublicKey]));
    }
    return keys;
  }
}
