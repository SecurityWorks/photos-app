// @dart=2.9

import 'dart:async';
import 'dart:io';

import 'package:computer/computer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/device_files_db.dart';
import 'package:photos/db/file_updation_db.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/db/ignored_files_db.dart';
import 'package:photos/events/backup_folders_updated_event.dart';
import 'package:photos/events/local_photos_updated_event.dart';
import 'package:photos/events/sync_status_update_event.dart';
import 'package:photos/models/file.dart';
import 'package:photos/services/app_lifecycle_service.dart';
import 'package:photos/services/local/local_sync_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

class LocalSyncService {
  final _logger = Logger("LocalSyncService");
  final _db = FilesDB.instance;
  final Computer _computer = Computer();
  SharedPreferences _prefs;
  Completer<void> _existingSync;

  static const kDbUpdationTimeKey = "db_updation_time";
  static const kHasCompletedFirstImportKey = "has_completed_firstImport";
  static const hasImportedDeviceCollections = "has_imported_device_collections";
  static const kHasGrantedPermissionsKey = "has_granted_permissions";
  static const kPermissionStateKey = "permission_state";
  static const kEditedFileIDsKey = "edited_file_ids";
  static const kDownloadedFileIDsKey = "downloaded_file_ids";

  // Adding `_2` as a suffic to pull files that were earlier ignored due to permission errors
  // See https://github.com/CaiJingLong/flutter_photo_manager/issues/589
  static const kInvalidFileIDsKey = "invalid_file_ids_2";

  LocalSyncService._privateConstructor();

  static final LocalSyncService instance =
      LocalSyncService._privateConstructor();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (!AppLifecycleService.instance.isForeground) {
      await PhotoManager.setIgnorePermissionCheck(true);
    }
    await _computer.turnOn(workersCount: 1);
    if (hasGrantedPermissions()) {
      _registerChangeCallback();
    }
  }

  Future<void> sync() async {
    if (!_prefs.containsKey(kHasGrantedPermissionsKey)) {
      _logger.info("Skipping local sync since permission has not been granted");
      return;
    }
    if (Platform.isAndroid && AppLifecycleService.instance.isForeground) {
      final permissionState = await PhotoManager.requestPermissionExtend();
      if (permissionState != PermissionState.authorized) {
        _logger.severe(
          "sync requested with invalid permission",
          permissionState.toString(),
        );
        return;
      }
    }
    if (_existingSync != null) {
      _logger.warning("Sync already in progress, skipping.");
      return _existingSync.future;
    }
    _existingSync = Completer<void>();
    final existingLocalFileIDs = await _db.getExistingLocalFileIDs();
    _logger.info(
      existingLocalFileIDs.length.toString() + " localIDs were discovered",
    );
    final editedFileIDs = _getEditedFileIDs().toSet();
    final downloadedFileIDs = _getDownloadedFileIDs().toSet();
    final syncStartTime = DateTime.now().microsecondsSinceEpoch;
    final lastDBUpdationTime = _prefs.getInt(kDbUpdationTimeKey) ?? 0;
    final startTime = DateTime.now().microsecondsSinceEpoch;
    if (lastDBUpdationTime != 0) {
      await _loadAndStorePhotos(
        lastDBUpdationTime,
        syncStartTime,
        existingLocalFileIDs,
        editedFileIDs,
        downloadedFileIDs,
      );
    } else {
      // Load from 0 - 01.01.2010
      Bus.instance.fire(SyncStatusUpdate(SyncStatus.startedFirstGalleryImport));
      var startTime = 0;
      var toYear = 2010;
      var toTime = DateTime(toYear).microsecondsSinceEpoch;
      while (toTime < syncStartTime) {
        await _loadAndStorePhotos(
          startTime,
          toTime,
          existingLocalFileIDs,
          editedFileIDs,
          downloadedFileIDs,
        );
        startTime = toTime;
        toYear++;
        toTime = DateTime(toYear).microsecondsSinceEpoch;
      }
      await _loadAndStorePhotos(
        startTime,
        syncStartTime,
        existingLocalFileIDs,
        editedFileIDs,
        downloadedFileIDs,
      );
    }
    if (!_prefs.containsKey(kHasCompletedFirstImportKey) ||
        !_prefs.getBool(kHasCompletedFirstImportKey)) {
      await _prefs.setBool(kHasCompletedFirstImportKey, true);
      // mark device collection has imported on first import
      await _refreshDeviceFolderCountAndCover();
      await _prefs.setBool(hasImportedDeviceCollections, true);
      _logger.fine("first gallery import finished");
      Bus.instance
          .fire(SyncStatusUpdate(SyncStatus.completedFirstGalleryImport));
    }
    final endTime = DateTime.now().microsecondsSinceEpoch;
    final duration = Duration(microseconds: endTime - startTime);
    _logger.info("Load took " + duration.inMilliseconds.toString() + "ms");
    _existingSync.complete();
    _existingSync = null;
  }

  Future<bool> _refreshDeviceFolderCountAndCover() async {
    final List<Tuple2<AssetPathEntity, String>> result =
        await getDeviceFolderWithCountAndCoverID();
    final bool hasUpdated = await _db.updateDeviceCoverWithCount(
      result,
      shouldBackup: Configuration.instance.hasSelectedAllFoldersForBackup(),
    );
    if (hasUpdated) {
      Bus.instance.fire(BackupFoldersUpdatedEvent());
    }
    if (!_prefs.containsKey(hasImportedDeviceCollections)) {
      await _migrateOldSettings(result);
    }
    return hasUpdated;
  }

  // migrate the backed up folder settings. remove after 6 months?
  Future<void> _migrateOldSettings(
    List<Tuple2<AssetPathEntity, String>> result,
  ) async {
    final pathsToBackUp = Configuration.instance.getPathsToBackUp();
    final entriesToBackUp = Map.fromEntries(
      result
          .where((element) => pathsToBackUp.contains(element.item1.name))
          .map((e) => MapEntry(e.item1.id, true)),
    );
    if (entriesToBackUp.isNotEmpty) {
      await _db.updateDevicePathSyncStatus(entriesToBackUp);
      Bus.instance.fire(BackupFoldersUpdatedEvent());
    }
    await Configuration.instance
        .setHasSelectedAnyBackupFolder(pathsToBackUp.isNotEmpty);
    await _prefs.setBool(hasImportedDeviceCollections, true);
  }

  bool isDeviceFileMigrationDone() {
    return _prefs.containsKey(hasImportedDeviceCollections);
  }

  Future<bool> syncAll() async {
    final stopwatch = Stopwatch()..start();
    final localAssets = await getAllLocalAssets();
    _logger.info(
      "Loading allLocalAssets ${localAssets.length} took ${stopwatch.elapsedMilliseconds}ms ",
    );
    await _refreshDeviceFolderCountAndCover();
    _logger.info(
      "refreshDeviceFolderCountAndCover + allLocalAssets took ${stopwatch.elapsedMilliseconds}ms ",
    );
    final existingLocalFileIDs = await _db.getExistingLocalFileIDs();
    final Map<String, Set<String>> pathToLocalIDs =
        await _db.getDevicePathIDToLocalIDMap();
    final invalidIDs = _getInvalidFileIDs().toSet();
    final localDiffResult = await getDiffWithLocal(
      localAssets,
      existingLocalFileIDs,
      pathToLocalIDs,
      invalidIDs,
      _computer,
    );
    bool hasAnyMappingChanged = false;
    if (localDiffResult.newPathToLocalIDs?.isNotEmpty ?? false) {
      await _db.insertPathIDToLocalIDMapping(localDiffResult.newPathToLocalIDs);
      hasAnyMappingChanged = true;
    }
    if (localDiffResult.deletePathToLocalIDs?.isNotEmpty ?? false) {
      await _db
          .deletePathIDToLocalIDMapping(localDiffResult.deletePathToLocalIDs);
      hasAnyMappingChanged = true;
    }
    final bool hasUnsyncedFiles =
        localDiffResult.uniqueLocalFiles?.isNotEmpty ?? false;
    if (hasUnsyncedFiles) {
      await _db.insertMultiple(
        localDiffResult.uniqueLocalFiles,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      _logger.info(
        "Inserted ${localDiffResult.uniqueLocalFiles.length} "
        "un-synced files",
      );
    }
    debugPrint(
      "syncAll: mappingChange : $hasAnyMappingChanged, "
      "unSyncedFiles: $hasUnsyncedFiles",
    );
    if (hasAnyMappingChanged || hasUnsyncedFiles) {
      Bus.instance.fire(
        LocalPhotosUpdatedEvent(localDiffResult.uniqueLocalFiles),
      );
    }
    _logger.info("syncAll took ${stopwatch.elapsed.inMilliseconds}ms ");
    return hasUnsyncedFiles;
  }

  Future<void> trackEditedFile(File file) async {
    final editedIDs = _getEditedFileIDs();
    editedIDs.add(file.localID);
    await _prefs.setStringList(kEditedFileIDsKey, editedIDs);
  }

  List<String> _getEditedFileIDs() {
    if (_prefs.containsKey(kEditedFileIDsKey)) {
      return _prefs.getStringList(kEditedFileIDsKey);
    } else {
      final List<String> editedIDs = [];
      return editedIDs;
    }
  }

  Future<void> trackDownloadedFile(String localID) async {
    final downloadedIDs = _getDownloadedFileIDs();
    downloadedIDs.add(localID);
    await _prefs.setStringList(kDownloadedFileIDsKey, downloadedIDs);
  }

  List<String> _getDownloadedFileIDs() {
    if (_prefs.containsKey(kDownloadedFileIDsKey)) {
      return _prefs.getStringList(kDownloadedFileIDsKey);
    } else {
      return <String>[];
    }
  }

  Future<void> trackInvalidFile(File file) async {
    final invalidIDs = _getInvalidFileIDs();
    invalidIDs.add(file.localID);
    await _prefs.setStringList(kInvalidFileIDsKey, invalidIDs);
  }

  List<String> _getInvalidFileIDs() {
    if (_prefs.containsKey(kInvalidFileIDsKey)) {
      return _prefs.getStringList(kInvalidFileIDsKey);
    } else {
      return <String>[];
    }
  }

  bool hasGrantedPermissions() {
    return _prefs.getBool(kHasGrantedPermissionsKey) ?? false;
  }

  bool hasGrantedLimitedPermissions() {
    return _prefs.getString(kPermissionStateKey) ==
        PermissionState.limited.toString();
  }

  Future<void> onPermissionGranted(PermissionState state) async {
    await _prefs.setBool(kHasGrantedPermissionsKey, true);
    await _prefs.setString(kPermissionStateKey, state.toString());
    if (state == PermissionState.limited) {
      // when limited permission is granted, by default mark all folders for
      // backup
      await Configuration.instance.setSelectAllFoldersForBackup(true);
    }
    _registerChangeCallback();
  }

  bool hasCompletedFirstImport() {
    return _prefs.getBool(kHasCompletedFirstImportKey) ?? false;
  }

  // Warning: resetLocalSync should only be used for testing imported related
  // changes
  Future<void> resetLocalSync() async {
    assert(kDebugMode, "only available in debug mode");
    await FilesDB.instance.deleteDB();
    await IgnoredFilesDB.instance.clearTable();
    for (var element in [
      kHasCompletedFirstImportKey,
      hasImportedDeviceCollections,
      kDbUpdationTimeKey,
      kDownloadedFileIDsKey,
      kEditedFileIDsKey,
      "has_synced_edit_time",
      "has_selected_all_folders_for_backup",
    ]) {
      await _prefs.remove(element);
    }
  }

  Future<void> _loadAndStorePhotos(
    int fromTime,
    int toTime,
    Set<String> existingLocalFileIDs,
    Set<String> editedFileIDs,
    Set<String> downloadedFileIDs,
  ) async {
    _logger.info(
      "Loading photos from " +
          DateTime.fromMicrosecondsSinceEpoch(fromTime).toString() +
          " to " +
          DateTime.fromMicrosecondsSinceEpoch(toTime).toString(),
    );
    final Tuple2<List<LocalPathAsset>, List<File>> result =
        await getLocalPathAssetsAndFiles(fromTime, toTime, _computer);
    await FilesDB.instance.insertLocalAssets(
      result.item1,
      shouldAutoBackup: Configuration.instance.hasSelectedAllFoldersForBackup(),
    );
    final List<File> files = result.item2;
    if (files.isNotEmpty) {
      _logger.info("Fetched " + files.length.toString() + " files.");
      await _trackUpdatedFiles(
        files,
        existingLocalFileIDs,
        editedFileIDs,
        downloadedFileIDs,
      );
      final List<File> allFiles = [];
      allFiles.addAll(files);
      files.removeWhere((file) => existingLocalFileIDs.contains(file.localID));
      await _db.insertMultiple(
        files,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      _logger.info("Inserted " + files.length.toString() + " files.");
      // _updatePathsToBackup(files);
      Bus.instance.fire(LocalPhotosUpdatedEvent(allFiles));
    }
    await _prefs.setInt(kDbUpdationTimeKey, toTime);
  }

  Future<void> _trackUpdatedFiles(
    List<File> files,
    Set<String> existingLocalFileIDs,
    Set<String> editedFileIDs,
    Set<String> downloadedFileIDs,
  ) async {
    final updatedFiles = files
        .where((file) => existingLocalFileIDs.contains(file.localID))
        .toList();
    updatedFiles.removeWhere((file) => editedFileIDs.contains(file.localID));
    updatedFiles
        .removeWhere((file) => downloadedFileIDs.contains(file.localID));
    if (updatedFiles.isNotEmpty) {
      _logger.info(
        updatedFiles.length.toString() + " local files were updated.",
      );
      final List<String> updatedLocalIDs = [];
      for (final file in updatedFiles) {
        updatedLocalIDs.add(file.localID);
      }
      await FileUpdationDB.instance.insertMultiple(
        updatedLocalIDs,
        FileUpdationDB.modificationTimeUpdated,
      );
    }
  }

  void _registerChangeCallback() {
    // In case of iOS limit permission, this call back is fired immediately
    // after file selection dialog is dismissed.
    PhotoManager.addChangeCallback((value) async {
      _logger.info("Something changed on disk");
      if (_existingSync != null) {
        await _existingSync.future;
      }
      if (hasGrantedLimitedPermissions()) {
        syncAll();
      } else {
        sync().then((value) => _refreshDeviceFolderCountAndCover());
      }
    });
    PhotoManager.startChangeNotify();
  }
}
