import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photos/models/backup_status.dart';
import 'package:photos/models/file.dart';
import 'package:photos/models/file_load_result.dart';
import 'package:photos/models/file_type.dart';
import 'package:photos/models/location.dart';
import 'package:photos/models/magic_metadata.dart';
import 'package:photos/services/feature_flag_service.dart';
import 'package:photos/utils/file_uploader_util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration/sqflite_migration.dart';

class FilesDB {
  /*
  Note: columnUploadedFileID and columnCollectionID have to be compared against
  both NULL and -1 because older clients might have entries where the DEFAULT
  was unset, and a migration script to set the DEFAULT would break in case of
  duplicate entries for un-uploaded files that were created due to a collision
  in background and foreground syncs.
  */
  static const _databaseName = "ente.files.db";

  static final Logger _logger = Logger("FilesDB");

  static const filesTable = 'files';
  static const tempTable = 'temp_files';

  static const columnGeneratedID = '_id';
  static const columnUploadedFileID = 'uploaded_file_id';
  static const columnOwnerID = 'owner_id';
  static const columnCollectionID = 'collection_id';
  static const columnLocalID = 'local_id';
  static const columnTitle = 'title';
  static const columnDeviceFolder = 'device_folder';
  static const columnLatitude = 'latitude';
  static const columnLongitude = 'longitude';
  static const columnFileType = 'file_type';
  static const columnFileSubType = 'file_sub_type';
  static const columnDuration = 'duration';
  static const columnExif = 'exif';
  static const columnHash = 'hash';
  static const columnMetadataVersion = 'metadata_version';
  static const columnIsDeleted = 'is_deleted';
  static const columnCreationTime = 'creation_time';
  static const columnModificationTime = 'modification_time';
  static const columnUpdationTime = 'updation_time';
  static const columnEncryptedKey = 'encrypted_key';
  static const columnKeyDecryptionNonce = 'key_decryption_nonce';
  static const columnFileDecryptionHeader = 'file_decryption_header';
  static const columnThumbnailDecryptionHeader = 'thumbnail_decryption_header';
  static const columnMetadataDecryptionHeader = 'metadata_decryption_header';

  // MMD -> Magic Metadata
  static const columnMMdEncodedJson = 'mmd_encoded_json';
  static const columnMMdVersion = 'mmd_ver';

  static const columnPubMMdEncodedJson = 'pub_mmd_encoded_json';
  static const columnPubMMdVersion = 'pub_mmd_ver';

  // part of magic metadata
  // Only parse & store selected fields from JSON in separate columns if
  // we need to write query based on that field
  static const columnMMdVisibility = 'mmd_visibility';

  static final initializationScript = [...createTable(filesTable)];
  static final migrationScripts = [
    ...alterDeviceFolderToAllowNULL(),
    ...alterTimestampColumnTypes(),
    ...addIndices(),
    ...addMetadataColumns(),
    ...addMagicMetadataColumns(),
    ...addUniqueConstraintOnCollectionFiles(),
    ...addPubMagicMetadataColumns(),
    ...createOnDeviceFilesAndPathCollection(),
  ];

  final dbConfig = MigrationConfig(
    initializationScript: initializationScript,
    migrationScripts: migrationScripts,
  );
  // make this a singleton class
  FilesDB._privateConstructor();

  static final FilesDB instance = FilesDB._privateConstructor();

  // only have a single app-wide reference to the database
  static Future<Database> _dbFuture;

  Future<Database> get database async {
    // lazily instantiate the db the first time it is accessed
    _dbFuture ??= _initDatabase();
    return _dbFuture;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    _logger.info("DB path " + path);
    return await openDatabaseWithMigration(path, dbConfig);
  }

  // SQL code to create the database table
  static List<String> createTable(String tableName) {
    return [
      '''
        CREATE TABLE $tableName (
          $columnGeneratedID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          $columnLocalID TEXT,
          $columnUploadedFileID INTEGER DEFAULT -1,
          $columnOwnerID INTEGER,
          $columnCollectionID INTEGER DEFAULT -1,
          $columnTitle TEXT NOT NULL,
          $columnDeviceFolder TEXT,
          $columnLatitude REAL,
          $columnLongitude REAL,
          $columnFileType INTEGER,
          $columnModificationTime TEXT NOT NULL,
          $columnEncryptedKey TEXT,
          $columnKeyDecryptionNonce TEXT,
          $columnFileDecryptionHeader TEXT,
          $columnThumbnailDecryptionHeader TEXT,
          $columnMetadataDecryptionHeader TEXT,
          $columnIsDeleted INTEGER DEFAULT 0,
          $columnCreationTime TEXT NOT NULL,
          $columnUpdationTime TEXT,
          UNIQUE($columnLocalID, $columnUploadedFileID, $columnCollectionID)
        );
      ''',
    ];
  }

  static List<String> addIndices() {
    return [
      '''
        CREATE INDEX IF NOT EXISTS collection_id_index ON $filesTable($columnCollectionID);
      ''',
      '''
        CREATE INDEX IF NOT EXISTS device_folder_index ON $filesTable($columnDeviceFolder);
      ''',
      '''
        CREATE INDEX IF NOT EXISTS creation_time_index ON $filesTable($columnCreationTime);
      ''',
      '''
        CREATE INDEX IF NOT EXISTS updation_time_index ON $filesTable($columnUpdationTime);
      '''
    ];
  }

  static List<String> alterDeviceFolderToAllowNULL() {
    return [
      ...createTable(tempTable),
      '''
        INSERT INTO $tempTable
        SELECT *
        FROM $filesTable;

        DROP TABLE $filesTable;
        
        ALTER TABLE $tempTable 
        RENAME TO $filesTable;
    '''
    ];
  }

  static List<String> alterTimestampColumnTypes() {
    return [
      '''
        DROP TABLE IF EXISTS $tempTable;
      ''',
      '''
        CREATE TABLE $tempTable (
          $columnGeneratedID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          $columnLocalID TEXT,
          $columnUploadedFileID INTEGER DEFAULT -1,
          $columnOwnerID INTEGER,
          $columnCollectionID INTEGER DEFAULT -1,
          $columnTitle TEXT NOT NULL,
          $columnDeviceFolder TEXT,
          $columnLatitude REAL,
          $columnLongitude REAL,
          $columnFileType INTEGER,
          $columnModificationTime INTEGER NOT NULL,
          $columnEncryptedKey TEXT,
          $columnKeyDecryptionNonce TEXT,
          $columnFileDecryptionHeader TEXT,
          $columnThumbnailDecryptionHeader TEXT,
          $columnMetadataDecryptionHeader TEXT,
          $columnCreationTime INTEGER NOT NULL,
          $columnUpdationTime INTEGER,
          UNIQUE($columnLocalID, $columnUploadedFileID, $columnCollectionID)
        );
      ''',
      '''
        INSERT INTO $tempTable
        SELECT 
          $columnGeneratedID,
          $columnLocalID,
          $columnUploadedFileID,
          $columnOwnerID,
          $columnCollectionID,
          $columnTitle,
          $columnDeviceFolder,
          $columnLatitude,
          $columnLongitude,
          $columnFileType,
          CAST($columnModificationTime AS INTEGER),
          $columnEncryptedKey,
          $columnKeyDecryptionNonce,
          $columnFileDecryptionHeader,
          $columnThumbnailDecryptionHeader,
          $columnMetadataDecryptionHeader,
          CAST($columnCreationTime AS INTEGER),
          CAST($columnUpdationTime AS INTEGER)
        FROM $filesTable;
      ''',
      '''
        DROP TABLE $filesTable;
      ''',
      '''
        ALTER TABLE $tempTable 
        RENAME TO $filesTable;
      ''',
    ];
  }

  static List<String> addMetadataColumns() {
    return [
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnFileSubType INTEGER;
      ''',
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnDuration INTEGER;
      ''',
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnExif TEXT;
      ''',
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnHash TEXT;
      ''',
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnMetadataVersion INTEGER;
      ''',
    ];
  }

  static List<String> addMagicMetadataColumns() {
    return [
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnMMdEncodedJson TEXT DEFAULT '{}';
      ''',
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnMMdVersion INTEGER DEFAULT 0;
      ''',
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnMMdVisibility INTEGER DEFAULT $kVisibilityVisible;
      '''
    ];
  }

  static List<String> addUniqueConstraintOnCollectionFiles() {
    return [
      '''
      DELETE from $filesTable where $columnCollectionID || '-' || $columnUploadedFileID IN 
      (SELECT $columnCollectionID || '-' || $columnUploadedFileID from $filesTable WHERE 
      $columnCollectionID is not NULL AND $columnUploadedFileID is NOT NULL 
      AND $columnCollectionID != -1 AND $columnUploadedFileID  != -1 
      GROUP BY ($columnCollectionID || '-' || $columnUploadedFileID) HAVING count(*) > 1) 
      AND  ($columnCollectionID || '-' ||  $columnUploadedFileID || '-' || $columnGeneratedID) NOT IN 
      (SELECT $columnCollectionID || '-' ||  $columnUploadedFileID || '-' || max($columnGeneratedID) 
      from $filesTable WHERE 
      $columnCollectionID is not NULL AND $columnUploadedFileID is NOT NULL 
      AND $columnCollectionID != -1 AND $columnUploadedFileID  != -1 GROUP BY 
      ($columnCollectionID || '-' || $columnUploadedFileID) HAVING count(*) > 1);
      ''',
      '''
      CREATE UNIQUE INDEX IF NOT EXISTS cid_uid ON $filesTable ($columnCollectionID, $columnUploadedFileID)
      WHERE $columnCollectionID is not NULL AND $columnUploadedFileID is not NULL
      AND $columnCollectionID != -1 AND $columnUploadedFileID  != -1;
      '''
    ];
  }

  static List<String> addPubMagicMetadataColumns() {
    return [
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnPubMMdEncodedJson TEXT DEFAULT '{}';
      ''',
      '''
        ALTER TABLE $filesTable ADD COLUMN $columnPubMMdVersion INTEGER DEFAULT 0;
      '''
    ];
  }

  static List<String> createOnDeviceFilesAndPathCollection() {
    return [
      '''
        CREATE TABLE IF NOT EXISTS device_files (
          id TEXT NOT NULL,
          path_id TEXT NOT NULL,
          UNIQUE(id, path_id)
       );
       ''',
      '''
       CREATE TABLE IF NOT EXISTS device_collections (
          id TEXT PRIMARY KEY NOT NULL,
          name TEXT,
          modified_at INTEGER NOT NULL DEFAULT 0,
          should_backup INTEGER NOT NULL DEFAULT 0,
          count INTEGER NOT NULL DEFAULT 0,
          collection_id INTEGER DEFAULT -1,
          cover_id TEXT
      );
      ''',
      '''
      CREATE INDEX IF NOT EXISTS df_id_idx ON device_files (id);
      ''',
      '''
      CREATE INDEX IF NOT EXISTS df_path_id_idx ON device_files (path_id);
      ''',
    ];
  }

  Future<void> clearTable() async {
    final db = await instance.database;
    await db.delete(filesTable);
  }

  Future<void> deleteDB() async {
    if (kDebugMode) {
      debugPrint("Deleting files db");
      final io.Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, _databaseName);
      io.File(path).deleteSync(recursive: true);
      _dbFuture = null;
    }
  }

  Future<void> insertMultiple(
    List<File> files, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final startTime = DateTime.now();
    final db = await instance.database;
    var batch = db.batch();
    int batchCounter = 0;
    for (File file in files) {
      if (batchCounter == 400) {
        await batch.commit(noResult: true);
        batch = db.batch();
        batchCounter = 0;
      }
      batch.insert(
        filesTable,
        _getRowForFile(file),
        conflictAlgorithm: conflictAlgorithm,
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
      "Batch insert of " +
          files.length.toString() +
          " took " +
          duration.inMilliseconds.toString() +
          "ms.",
    );
  }

  Future<int> insert(File file) async {
    final db = await instance.database;
    return db.insert(
      filesTable,
      _getRowForFile(file),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<File> getFile(int generatedID) async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where: '$columnGeneratedID = ?',
      whereArgs: [generatedID],
    );
    if (results.isEmpty) {
      return null;
    }
    return convertToFiles(results)[0];
  }

  Future<File> getUploadedFile(int uploadedID, int collectionID) async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where: '$columnUploadedFileID = ? AND $columnCollectionID = ?',
      whereArgs: [
        uploadedID,
        collectionID,
      ],
    );
    if (results.isEmpty) {
      return null;
    }
    return convertToFiles(results)[0];
  }

  Future<Set<int>> getUploadedFileIDs(int collectionID) async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      columns: [columnUploadedFileID],
      where: '$columnCollectionID = ?',
      whereArgs: [
        collectionID,
      ],
    );
    final ids = <int>{};
    for (final result in results) {
      ids.add(result[columnUploadedFileID]);
    }
    return ids;
  }

  Future<BackedUpFileIDs> getBackedUpIDs() async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      columns: [columnLocalID, columnUploadedFileID],
      where:
          '$columnLocalID IS NOT NULL AND ($columnUploadedFileID IS NOT NULL AND $columnUploadedFileID IS NOT -1)',
    );
    final localIDs = <String>{};
    final uploadedIDs = <int>{};
    for (final result in results) {
      localIDs.add(result[columnLocalID]);
      uploadedIDs.add(result[columnUploadedFileID]);
    }
    return BackedUpFileIDs(localIDs.toList(), uploadedIDs.toList());
  }

  Future<FileLoadResult> getAllUploadedFiles(
    int startTime,
    int endTime,
    int ownerID, {
    int limit,
    bool asc,
    int visibility = kVisibilityVisible,
    Set<int> ignoredCollectionIDs,
  }) async {
    final db = await instance.database;
    final order = (asc ?? false ? 'ASC' : 'DESC');
    final results = await db.query(
      filesTable,
      where:
          '$columnCreationTime >= ? AND $columnCreationTime <= ? AND  $columnOwnerID = ? AND ($columnCollectionID IS NOT NULL AND $columnCollectionID IS NOT -1)'
          ' AND $columnMMdVisibility = ?',
      whereArgs: [startTime, endTime, ownerID, visibility],
      orderBy:
          '$columnCreationTime ' + order + ', $columnModificationTime ' + order,
      limit: limit,
    );
    final files = convertToFiles(results);
    final List<File> deduplicatedFiles =
        _deduplicatedAndFilterIgnoredFiles(files, ignoredCollectionIDs);
    return FileLoadResult(deduplicatedFiles, files.length == limit);
  }

  Future<Set<int>> getCollectionIDsOfHiddenFiles(
    int ownerID, {
    int visibility = kVisibilityArchive,
  }) async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where:
          '$columnOwnerID = ? AND $columnMMdVisibility = ? AND $columnCollectionID != -1',
      columns: [columnCollectionID],
      whereArgs: [ownerID, visibility],
      distinct: true,
    );
    Set<int> collectionIDsOfHiddenFiles = {};
    for (var result in results) {
      collectionIDsOfHiddenFiles.add(result['collection_id']);
    }
    return collectionIDsOfHiddenFiles;
  }

  Future<FileLoadResult> getAllLocalAndUploadedFiles(
    int startTime,
    int endTime,
    int ownerID, {
    int limit,
    bool asc,
    Set<int> ignoredCollectionIDs,
  }) async {
    final db = await instance.database;
    final order = (asc ?? false ? 'ASC' : 'DESC');
    final results = await db.query(
      filesTable,
      where:
          '$columnCreationTime >= ? AND $columnCreationTime <= ? AND ($columnOwnerID IS NULL OR $columnOwnerID = ?)  AND ($columnMMdVisibility IS NULL OR $columnMMdVisibility = ?)'
          ' AND ($columnLocalID IS NOT NULL OR ($columnCollectionID IS NOT NULL AND $columnCollectionID IS NOT -1))',
      whereArgs: [startTime, endTime, ownerID, kVisibilityVisible],
      orderBy:
          '$columnCreationTime ' + order + ', $columnModificationTime ' + order,
      limit: limit,
    );
    final files = convertToFiles(results);
    final List<File> deduplicatedFiles =
        _deduplicatedAndFilterIgnoredFiles(files, ignoredCollectionIDs);
    return FileLoadResult(deduplicatedFiles, files.length == limit);
  }

  Future<FileLoadResult> getImportantFiles(
    int startTime,
    int endTime,
    int ownerID,
    List<String> paths, {
    int limit,
    bool asc,
    Set<int> ignoredCollectionIDs,
  }) async {
    final db = await instance.database;
    String inParam = "";
    for (final path in paths) {
      inParam += "'" + path.replaceAll("'", "''") + "',";
    }
    inParam = inParam.substring(0, inParam.length - 1);
    final order = (asc ?? false ? 'ASC' : 'DESC');
    final results = await db.query(
      filesTable,
      where:
          '$columnCreationTime >= ? AND $columnCreationTime <= ? AND ($columnOwnerID IS NULL OR $columnOwnerID = ?) AND ($columnMMdVisibility IS NULL OR $columnMMdVisibility = ?)'
          'AND (($columnLocalID IS NOT NULL AND $columnDeviceFolder IN ($inParam)) OR ($columnCollectionID IS NOT NULL AND $columnCollectionID IS NOT -1))',
      whereArgs: [startTime, endTime, ownerID, kVisibilityVisible],
      orderBy:
          '$columnCreationTime ' + order + ', $columnModificationTime ' + order,
      limit: limit,
    );
    final files = convertToFiles(results);
    final List<File> deduplicatedFiles =
        _deduplicatedAndFilterIgnoredFiles(files, ignoredCollectionIDs);
    return FileLoadResult(deduplicatedFiles, files.length == limit);
  }

  List<File> _deduplicateByLocalID(List<File> files) {
    final localIDs = <String>{};
    final List<File> deduplicatedFiles = [];
    for (final file in files) {
      final id = file.localID;
      if (id != null && localIDs.contains(id)) {
        continue;
      }
      localIDs.add(id);
      deduplicatedFiles.add(file);
    }
    return deduplicatedFiles;
  }

  List<File> _deduplicatedAndFilterIgnoredFiles(
    List<File> files,
    Set<int> ignoredCollectionIDs,
  ) {
    final uploadedFileIDs = <int>{};
    final List<File> deduplicatedFiles = [];
    for (final file in files) {
      final id = file.uploadedFileID;
      if (ignoredCollectionIDs != null &&
          ignoredCollectionIDs.contains(file.collectionID)) {
        continue;
      }
      if (id != null && id != -1 && uploadedFileIDs.contains(id)) {
        continue;
      }
      uploadedFileIDs.add(id);
      deduplicatedFiles.add(file);
    }
    return deduplicatedFiles;
  }

  Future<FileLoadResult> getFilesInCollection(
    int collectionID,
    int startTime,
    int endTime, {
    int limit,
    bool asc,
    int visibility = kVisibilityVisible,
  }) async {
    final db = await instance.database;
    final order = (asc ?? false ? 'ASC' : 'DESC');
    String whereClause;
    List<Object> whereArgs;
    if (FeatureFlagService.instance.isInternalUserOrDebugBuild()) {
      whereClause =
          '$columnCollectionID = ? AND $columnCreationTime >= ? AND $columnCreationTime <= ? AND $columnMMdVisibility = ?';
      whereArgs = [collectionID, startTime, endTime, visibility];
    } else {
      whereClause =
          '$columnCollectionID = ? AND $columnCreationTime >= ? AND $columnCreationTime <= ?';
      whereArgs = [collectionID, startTime, endTime];
    }

    final results = await db.query(
      filesTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy:
          '$columnCreationTime ' + order + ', $columnModificationTime ' + order,
      limit: limit,
    );
    final files = convertToFiles(results);
    _logger.info("Fetched " + files.length.toString() + " files");
    return FileLoadResult(files, files.length == limit);
  }

  Future<FileLoadResult> getFilesInPath(
    String path,
    int startTime,
    int endTime, {
    int limit,
    bool asc,
  }) async {
    final db = await instance.database;
    final order = (asc ?? false ? 'ASC' : 'DESC');
    final results = await db.query(
      filesTable,
      where:
          '$columnDeviceFolder = ? AND $columnCreationTime >= ? AND $columnCreationTime <= ? AND $columnLocalID IS NOT NULL',
      whereArgs: [path, startTime, endTime],
      orderBy:
          '$columnCreationTime ' + order + ', $columnModificationTime ' + order,
      groupBy: columnLocalID,
      limit: limit,
    );
    final files = convertToFiles(results);
    return FileLoadResult(files, files.length == limit);
  }

  Future<FileLoadResult> getLocalDeviceFiles(
    int startTime,
    int endTime, {
    int limit,
    bool asc,
  }) async {
    final db = await instance.database;
    final order = (asc ?? false ? 'ASC' : 'DESC');
    final results = await db.query(
      filesTable,
      where:
          '$columnCreationTime >= ? AND $columnCreationTime <= ? AND $columnLocalID IS NOT NULL',
      whereArgs: [startTime, endTime],
      orderBy:
          '$columnCreationTime ' + order + ', $columnModificationTime ' + order,
      limit: limit,
    );
    final files = convertToFiles(results);
    final result = _deduplicateByLocalID(files);
    return FileLoadResult(result, files.length == limit);
  }

  Future<List<File>> getAllVideos() async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where: '$columnLocalID IS NOT NULL AND $columnFileType = 1',
      orderBy: '$columnCreationTime DESC',
    );
    return convertToFiles(results);
  }

  Future<List<File>> getAllInPath(String path) async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where: '$columnLocalID IS NOT NULL AND $columnDeviceFolder = ?',
      whereArgs: [path],
      orderBy: '$columnCreationTime DESC',
      groupBy: columnLocalID,
    );
    return convertToFiles(results);
  }

  Future<List<File>> getFilesCreatedWithinDurations(
    List<List<int>> durations,
    Set<int> ignoredCollectionIDs, {
    String order = 'ASC',
  }) async {
    final db = await instance.database;
    String whereClause = "( ";
    for (int index = 0; index < durations.length; index++) {
      whereClause += "($columnCreationTime > " +
          durations[index][0].toString() +
          " AND $columnCreationTime < " +
          durations[index][1].toString() +
          ")";
      if (index != durations.length - 1) {
        whereClause += " OR ";
      }
    }
    whereClause += ") AND $columnMMdVisibility = $kVisibilityVisible";
    final results = await db.query(
      filesTable,
      where: whereClause,
      orderBy: '$columnCreationTime ' + order,
    );
    final files = convertToFiles(results);
    return _deduplicatedAndFilterIgnoredFiles(files, ignoredCollectionIDs);
  }

  Future<List<File>> getFilesToBeUploadedWithinFolders(
    Set<String> folders,
  ) async {
    if (folders.isEmpty) {
      return [];
    }
    final db = await instance.database;
    String inParam = "";
    for (final folder in folders) {
      inParam += "'" + folder.replaceAll("'", "''") + "',";
    }
    inParam = inParam.substring(0, inParam.length - 1);
    final results = await db.query(
      filesTable,
      where:
          '($columnUploadedFileID IS NULL OR $columnUploadedFileID IS -1) AND $columnDeviceFolder IN ($inParam)',
      orderBy: '$columnCreationTime DESC',
      groupBy: columnLocalID,
    );
    return convertToFiles(results);
  }

  // Files which user added to a collection manually but they are not uploaded yet.
  Future<List<File>> getPendingManualUploads() async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where:
          '($columnUploadedFileID IS NULL OR $columnUploadedFileID IS -1) AND '
          '$columnCollectionID IS NOT NULL AND $columnCollectionID IS NOT -1 AND '
          '$columnLocalID IS NOT NULL AND $columnLocalID IS NOT -1',
      orderBy: '$columnCreationTime DESC',
      groupBy: columnLocalID,
    );
    final files = convertToFiles(results);
    // future-safe filter just to ensure that the query doesn't end up  returning files
    // which should not be backed up
    files.removeWhere(
      (e) =>
          e.collectionID == null ||
          e.localID == null ||
          e.uploadedFileID != null,
    );
    return files;
  }

  Future<List<File>> getUnUploadedLocalFiles() async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where:
          '($columnUploadedFileID IS NULL OR $columnUploadedFileID IS -1) AND $columnLocalID IS NOT NULL',
      orderBy: '$columnCreationTime DESC',
      groupBy: columnLocalID,
    );
    return convertToFiles(results);
  }

  Future<List<File>> getEditedRemoteFiles() async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where:
          '($columnCollectionID IS NOT NULL AND $columnCollectionID IS NOT -1) AND ($columnUploadedFileID IS NULL OR $columnUploadedFileID IS -1)',
      orderBy: '$columnCreationTime DESC',
      groupBy: columnLocalID,
    );
    return convertToFiles(results);
  }

  Future<List<int>> getUploadedFileIDsToBeUpdated() async {
    final db = await instance.database;
    final rows = await db.query(
      filesTable,
      columns: [columnUploadedFileID],
      where:
          '($columnLocalID IS NOT NULL AND ($columnUploadedFileID IS NOT NULL AND $columnUploadedFileID IS NOT -1) AND $columnUpdationTime IS NULL)',
      orderBy: '$columnCreationTime DESC',
      distinct: true,
    );
    final uploadedFileIDs = <int>[];
    for (final row in rows) {
      uploadedFileIDs.add(row[columnUploadedFileID]);
    }
    return uploadedFileIDs;
  }

  Future<File> getUploadedFileInAnyCollection(int uploadedFileID) async {
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where: '$columnUploadedFileID = ?',
      whereArgs: [
        uploadedFileID,
      ],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    return convertToFiles(results)[0];
  }

  Future<Set<String>> getExistingLocalFileIDs() async {
    final db = await instance.database;
    final rows = await db.query(
      filesTable,
      columns: [columnLocalID],
      distinct: true,
      where: '$columnLocalID IS NOT NULL',
    );
    final result = <String>{};
    for (final row in rows) {
      result.add(row[columnLocalID]);
    }
    return result;
  }

  Future<int> getNumberOfUploadedFiles() async {
    final db = await instance.database;
    final rows = await db.query(
      filesTable,
      columns: [columnUploadedFileID],
      where:
          '($columnLocalID IS NOT NULL AND ($columnUploadedFileID IS NOT NULL AND $columnUploadedFileID IS NOT -1) AND $columnUpdationTime IS NOT NULL)',
      distinct: true,
    );
    return rows.length;
  }

  Future<int> updateUploadedFile(
    String localID,
    String title,
    Location location,
    int creationTime,
    int modificationTime,
    int updationTime,
  ) async {
    final db = await instance.database;
    return await db.update(
      filesTable,
      {
        columnTitle: title,
        columnLatitude: location.latitude,
        columnLongitude: location.longitude,
        columnCreationTime: creationTime,
        columnModificationTime: modificationTime,
        columnUpdationTime: updationTime,
      },
      where: '$columnLocalID = ?',
      whereArgs: [localID],
    );
  }

  Future<List<File>> getMatchingFiles(
    String title,
    String deviceFolder,
  ) async {
    final db = await instance.database;
    final rows = await db.query(
      filesTable,
      where: '''$columnTitle=? AND $columnDeviceFolder=?''',
      whereArgs: [
        title,
        deviceFolder,
      ],
    );
    if (rows.isNotEmpty) {
      return convertToFiles(rows);
    } else {
      return null;
    }
  }

  Future<List<File>> getUploadedFilesWithHashes(
    FileHashData hashData,
    FileType fileType,
    int ownerID,
  ) async {
    String inParam = "'${hashData.fileHash}'";
    if (fileType == FileType.livePhoto && hashData.zipHash != null) {
      inParam += ",'${hashData.zipHash}'";
    }

    final db = await instance.database;
    final rows = await db.query(
      filesTable,
      where: '($columnUploadedFileID != NULL OR $columnUploadedFileID != -1) '
          'AND $columnOwnerID = ? AND $columnFileType ='
          ' ? '
          'AND $columnHash IN ($inParam)',
      whereArgs: [
        ownerID,
        getInt(fileType),
      ],
    );
    return convertToFiles(rows);
  }

  Future<int> update(File file) async {
    final db = await instance.database;
    return await db.update(
      filesTable,
      _getRowForFile(file),
      where: '$columnGeneratedID = ?',
      whereArgs: [file.generatedID],
    );
  }

  Future<int> updateUploadedFileAcrossCollections(File file) async {
    final db = await instance.database;
    return await db.update(
      filesTable,
      _getRowForFileWithoutCollection(file),
      where: '$columnUploadedFileID = ?',
      whereArgs: [file.uploadedFileID],
    );
  }

  Future<int> delete(int uploadedFileID) async {
    final db = await instance.database;
    return db.delete(
      filesTable,
      where: '$columnUploadedFileID =?',
      whereArgs: [uploadedFileID],
    );
  }

  Future<int> deleteByGeneratedID(int genID) async {
    final db = await instance.database;
    return db.delete(
      filesTable,
      where: '$columnGeneratedID =?',
      whereArgs: [genID],
    );
  }

  Future<int> deleteMultipleUploadedFiles(List<int> uploadedFileIDs) async {
    final db = await instance.database;
    return await db.delete(
      filesTable,
      where: '$columnUploadedFileID IN (${uploadedFileIDs.join(', ')})',
    );
  }

  Future<int> deleteLocalFile(File file) async {
    final db = await instance.database;
    if (file.localID != null) {
      // delete all files with same local ID
      return db.delete(
        filesTable,
        where: '$columnLocalID =?',
        whereArgs: [file.localID],
      );
    } else {
      return db.delete(
        filesTable,
        where: '$columnGeneratedID =?',
        whereArgs: [file.generatedID],
      );
    }
  }

  Future<void> deleteLocalFiles(List<String> localIDs) async {
    String inParam = "";
    for (final localID in localIDs) {
      inParam += "'" + localID + "',";
    }
    inParam = inParam.substring(0, inParam.length - 1);
    final db = await instance.database;
    await db.rawQuery(
      '''
      UPDATE $filesTable
      SET $columnLocalID = NULL
      WHERE $columnLocalID IN ($inParam);
    ''',
    );
  }

  Future<List<File>> getLocalFiles(List<String> localIDs) async {
    String inParam = "";
    for (final localID in localIDs) {
      inParam += "'" + localID + "',";
    }
    inParam = inParam.substring(0, inParam.length - 1);
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where: '$columnLocalID IN ($inParam)',
    );
    return convertToFiles(results);
  }

  Future<int> deleteUnSyncedLocalFiles(List<String> localIDs) async {
    String inParam = "";
    for (final localID in localIDs) {
      inParam += "'" + localID + "',";
    }
    inParam = inParam.substring(0, inParam.length - 1);
    final db = await instance.database;
    return db.delete(
      filesTable,
      where:
          '($columnUploadedFileID is NULL OR $columnUploadedFileID = -1 ) AND $columnLocalID IN ($inParam)',
    );
  }

  Future<int> deleteFromCollection(int uploadedFileID, int collectionID) async {
    final db = await instance.database;
    return db.delete(
      filesTable,
      where: '$columnUploadedFileID = ? AND $columnCollectionID = ?',
      whereArgs: [uploadedFileID, collectionID],
    );
  }

  Future<int> deleteFilesFromCollection(
    int collectionID,
    List<int> uploadedFileIDs,
  ) async {
    final db = await instance.database;
    return db.delete(
      filesTable,
      where:
          '$columnCollectionID = ? AND $columnUploadedFileID IN (${uploadedFileIDs.join(', ')})',
      whereArgs: [collectionID],
    );
  }

  Future<int> collectionFileCount(int collectionID) async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $filesTable where $columnCollectionID = $collectionID',
      ),
    );
    return count;
  }

  Future<int> fileCountWithVisibility(int visibility, int ownerID) async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $filesTable where $columnMMdVisibility = $visibility AND $columnOwnerID = $ownerID',
      ),
    );
    return count;
  }

  Future<int> deleteCollection(int collectionID) async {
    final db = await instance.database;
    return db.delete(
      filesTable,
      where: '$columnCollectionID = ?',
      whereArgs: [collectionID],
    );
  }

  Future<int> removeFromCollection(int collectionID, List<int> fileIDs) async {
    final db = await instance.database;
    return db.delete(
      filesTable,
      where:
          '$columnCollectionID =? AND $columnUploadedFileID IN (${fileIDs.join(', ')})',
      whereArgs: [collectionID],
    );
  }

  Future<List<File>> getLatestLocalFiles() async {
    final db = await instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT $filesTable.*
      FROM $filesTable
      INNER JOIN
        (
          SELECT $columnDeviceFolder, MAX($columnCreationTime) AS max_creation_time
          FROM $filesTable
          WHERE $filesTable.$columnLocalID IS NOT NULL
          GROUP BY $columnDeviceFolder
        ) latest_files
        ON $filesTable.$columnDeviceFolder = latest_files.$columnDeviceFolder
        AND $filesTable.$columnCreationTime = latest_files.max_creation_time;
    ''',
    );
    final files = convertToFiles(rows);
    // TODO: Do this de-duplication within the SQL Query
    final folderMap = <String, File>{};
    for (final file in files) {
      if (folderMap.containsKey(file.deviceFolder)) {
        if (folderMap[file.deviceFolder].updationTime < file.updationTime) {
          continue;
        }
      }
      folderMap[file.deviceFolder] = file;
    }
    return folderMap.values.toList();
  }

  Future<List<File>> getLatestCollectionFiles() async {
    debugPrint("Fetching latestCollectionFiles from db");
    String query;
    if (FeatureFlagService.instance.isInternalUserOrDebugBuild()) {
      query = '''
      SELECT $filesTable.*
      FROM $filesTable
      INNER JOIN
        (
          SELECT $columnCollectionID, MAX($columnCreationTime) AS max_creation_time
          FROM $filesTable
          WHERE ($columnCollectionID IS NOT NULL AND $columnCollectionID IS NOT -1 AND $columnMMdVisibility = $kVisibilityVisible)
          GROUP BY $columnCollectionID
        ) latest_files
        ON $filesTable.$columnCollectionID = latest_files.$columnCollectionID
        AND $filesTable.$columnCreationTime = latest_files.max_creation_time;
    ''';
    } else {
      query = '''
      SELECT $filesTable.*
      FROM $filesTable
      INNER JOIN
        (
          SELECT $columnCollectionID, MAX($columnCreationTime) AS max_creation_time
          FROM $filesTable
          WHERE ($columnCollectionID IS NOT NULL AND $columnCollectionID IS NOT -1)
          GROUP BY $columnCollectionID
        ) latest_files
        ON $filesTable.$columnCollectionID = latest_files.$columnCollectionID
        AND $filesTable.$columnCreationTime = latest_files.max_creation_time;
    ''';
    }

    final db = await instance.database;
    final rows = await db.rawQuery(
      query,
    );
    final files = convertToFiles(rows);
    // TODO: Do this de-duplication within the SQL Query
    final collectionMap = <int, File>{};
    for (final file in files) {
      if (collectionMap.containsKey(file.collectionID)) {
        if (collectionMap[file.collectionID].updationTime < file.updationTime) {
          continue;
        }
      }
      collectionMap[file.collectionID] = file;
    }
    return collectionMap.values.toList();
  }

  Future<Map<String, int>> getFileCountInDeviceFolders() async {
    final db = await instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT($columnLocalID)) as count, $columnDeviceFolder
      FROM $filesTable
      WHERE $columnLocalID IS NOT NULL
      GROUP BY $columnDeviceFolder
    ''',
    );
    final result = <String, int>{};
    for (final row in rows) {
      result[row[columnDeviceFolder]] = row["count"];
    }
    return result;
  }

  Future<List<String>> getLocalFilesBackedUpWithoutLocation() async {
    final db = await instance.database;
    final rows = await db.query(
      filesTable,
      columns: [columnLocalID],
      distinct: true,
      where:
          '$columnLocalID IS NOT NULL AND ($columnUploadedFileID IS NOT NULL AND $columnUploadedFileID IS NOT -1) '
          'AND ($columnLatitude IS NULL OR $columnLongitude IS NULL OR $columnLongitude = 0.0 or $columnLongitude = 0.0)',
    );
    final result = <String>[];
    for (final row in rows) {
      result.add(row[columnLocalID]);
    }
    return result;
  }

  Future<void> markForReUploadIfLocationMissing(List<String> localIDs) async {
    if (localIDs.isEmpty) {
      return;
    }
    String inParam = "";
    for (final localID in localIDs) {
      inParam += "'" + localID + "',";
    }
    inParam = inParam.substring(0, inParam.length - 1);
    final db = await instance.database;
    await db.rawUpdate(
      '''
      UPDATE $filesTable
      SET $columnUpdationTime = NULL
      WHERE $columnLocalID IN ($inParam)
      AND ($columnLatitude IS NULL OR $columnLongitude IS NULL OR $columnLongitude = 0.0 or $columnLongitude = 0.0);
    ''',
    );
  }

  Future<bool> doesFileExistInCollection(
    int uploadedFileID,
    int collectionID,
  ) async {
    final db = await instance.database;
    final rows = await db.query(
      filesTable,
      where: '$columnUploadedFileID = ? AND $columnCollectionID = ?',
      whereArgs: [uploadedFileID, collectionID],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Map<int, File>> getFilesFromIDs(List<int> ids) async {
    final result = <int, File>{};
    if (ids.isEmpty) {
      return result;
    }
    String inParam = "";
    for (final id in ids) {
      inParam += "'" + id.toString() + "',";
    }
    inParam = inParam.substring(0, inParam.length - 1);
    final db = await instance.database;
    final results = await db.query(
      filesTable,
      where: '$columnUploadedFileID IN ($inParam)',
    );
    final files = convertToFiles(results);
    for (final file in files) {
      result[file.uploadedFileID] = file;
    }
    return result;
  }

  List<File> convertToFiles(List<Map<String, dynamic>> results) {
    final List<File> files = [];
    for (final result in results) {
      files.add(_getFileFromRow(result));
    }
    return files;
  }

  Future<List<File>> getAllFilesFromDB() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(filesTable);
    final List<File> files = convertToFiles(result);
    final List<File> deduplicatedFiles =
        _deduplicatedAndFilterIgnoredFiles(files, null);
    return deduplicatedFiles;
  }

  Map<String, dynamic> _getRowForFile(File file) {
    final row = <String, dynamic>{};
    if (file.generatedID != null) {
      row[columnGeneratedID] = file.generatedID;
    }
    row[columnLocalID] = file.localID;
    row[columnUploadedFileID] = file.uploadedFileID ?? -1;
    row[columnOwnerID] = file.ownerID;
    row[columnCollectionID] = file.collectionID ?? -1;
    row[columnTitle] = file.title;
    row[columnDeviceFolder] = file.deviceFolder;
    if (file.location != null) {
      row[columnLatitude] = file.location.latitude;
      row[columnLongitude] = file.location.longitude;
    }
    row[columnFileType] = getInt(file.fileType);
    row[columnCreationTime] = file.creationTime;
    row[columnModificationTime] = file.modificationTime;
    row[columnUpdationTime] = file.updationTime;
    row[columnEncryptedKey] = file.encryptedKey;
    row[columnKeyDecryptionNonce] = file.keyDecryptionNonce;
    row[columnFileDecryptionHeader] = file.fileDecryptionHeader;
    row[columnThumbnailDecryptionHeader] = file.thumbnailDecryptionHeader;
    row[columnMetadataDecryptionHeader] = file.metadataDecryptionHeader;
    row[columnFileSubType] = file.fileSubType ?? -1;
    row[columnDuration] = file.duration ?? 0;
    row[columnExif] = file.exif;
    row[columnHash] = file.hash;
    row[columnMetadataVersion] = file.metadataVersion;
    row[columnMMdVersion] = file.mMdVersion ?? 0;
    row[columnMMdEncodedJson] = file.mMdEncodedJson ?? '{}';
    row[columnMMdVisibility] =
        file.magicMetadata?.visibility ?? kVisibilityVisible;
    row[columnPubMMdVersion] = file.pubMmdVersion ?? 0;
    row[columnPubMMdEncodedJson] = file.pubMmdEncodedJson ?? '{}';
    if (file.pubMagicMetadata != null &&
        file.pubMagicMetadata.editedTime != null) {
      // override existing creationTime to avoid re-writing all queries related
      // to loading the gallery
      row[columnCreationTime] = file.pubMagicMetadata.editedTime;
    }
    return row;
  }

  Map<String, dynamic> _getRowForFileWithoutCollection(File file) {
    final row = <String, dynamic>{};
    row[columnLocalID] = file.localID;
    row[columnUploadedFileID] = file.uploadedFileID ?? -1;
    row[columnOwnerID] = file.ownerID;
    row[columnTitle] = file.title;
    row[columnDeviceFolder] = file.deviceFolder;
    if (file.location != null) {
      row[columnLatitude] = file.location.latitude;
      row[columnLongitude] = file.location.longitude;
    }
    row[columnFileType] = getInt(file.fileType);
    row[columnCreationTime] = file.creationTime;
    row[columnModificationTime] = file.modificationTime;
    row[columnUpdationTime] = file.updationTime;
    row[columnFileDecryptionHeader] = file.fileDecryptionHeader;
    row[columnThumbnailDecryptionHeader] = file.thumbnailDecryptionHeader;
    row[columnMetadataDecryptionHeader] = file.metadataDecryptionHeader;
    row[columnFileSubType] = file.fileSubType ?? -1;
    row[columnDuration] = file.duration ?? 0;
    row[columnExif] = file.exif;
    row[columnHash] = file.hash;
    row[columnMetadataVersion] = file.metadataVersion;

    row[columnMMdVersion] = file.mMdVersion ?? 0;
    row[columnMMdEncodedJson] = file.mMdEncodedJson ?? '{}';
    row[columnMMdVisibility] =
        file.magicMetadata?.visibility ?? kVisibilityVisible;

    row[columnPubMMdVersion] = file.pubMmdVersion ?? 0;
    row[columnPubMMdEncodedJson] = file.pubMmdEncodedJson ?? '{}';
    if (file.pubMagicMetadata != null &&
        file.pubMagicMetadata.editedTime != null) {
      // override existing creationTime to avoid re-writing all queries related
      // to loading the gallery
      row[columnCreationTime] = file.pubMagicMetadata.editedTime;
    }
    return row;
  }

  File _getFileFromRow(Map<String, dynamic> row) {
    final file = File();
    file.generatedID = row[columnGeneratedID];
    file.localID = row[columnLocalID];
    file.uploadedFileID =
        row[columnUploadedFileID] == -1 ? null : row[columnUploadedFileID];
    file.ownerID = row[columnOwnerID];
    file.collectionID =
        row[columnCollectionID] == -1 ? null : row[columnCollectionID];
    file.title = row[columnTitle];
    file.deviceFolder = row[columnDeviceFolder];
    if (row[columnLatitude] != null && row[columnLongitude] != null) {
      file.location = Location(row[columnLatitude], row[columnLongitude]);
    }
    file.fileType = getFileType(row[columnFileType]);
    file.creationTime = row[columnCreationTime];
    file.modificationTime = row[columnModificationTime];
    file.updationTime = row[columnUpdationTime] ?? -1;
    file.encryptedKey = row[columnEncryptedKey];
    file.keyDecryptionNonce = row[columnKeyDecryptionNonce];
    file.fileDecryptionHeader = row[columnFileDecryptionHeader];
    file.thumbnailDecryptionHeader = row[columnThumbnailDecryptionHeader];
    file.metadataDecryptionHeader = row[columnMetadataDecryptionHeader];
    file.fileSubType = row[columnFileSubType] ?? -1;
    file.duration = row[columnDuration] ?? 0;
    file.exif = row[columnExif];
    file.hash = row[columnHash];
    file.metadataVersion = row[columnMetadataVersion] ?? 0;

    file.mMdVersion = row[columnMMdVersion] ?? 0;
    file.mMdEncodedJson = row[columnMMdEncodedJson] ?? '{}';

    file.pubMmdVersion = row[columnPubMMdVersion] ?? 0;
    file.pubMmdEncodedJson = row[columnPubMMdEncodedJson] ?? '{}';
    return file;
  }
}
