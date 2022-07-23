import 'dart:math';

import 'package:computer/computer.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/models/file.dart';

final _logger = Logger("FileSyncUtil");
const ignoreSizeConstraint = SizeConstraint(ignoreSize: true);
const assetFetchPageSize = 2000;

Future<List<File>> getDeviceFiles(
  int fromTime,
  int toTime,
  Computer computer,
) async {
  final pathEntities = await _getGalleryList(fromTime, toTime);
  List<File> files = [];
  for (AssetPathEntity pathEntity in pathEntities) {
    files = await _computeFiles(pathEntity, fromTime, files, computer);
  }
  // todo: Check if sort is needed and document the reason.
  files.sort(
    (first, second) => first.creationTime.compareTo(second.creationTime),
  );
  return files;
}

Future<List<LocalAsset>> getAllLocalAssets() async {
  final filterOptionGroup = FilterOptionGroup();
  filterOptionGroup.setOption(
    AssetType.image,
    const FilterOption(sizeConstraint: ignoreSizeConstraint),
  );
  filterOptionGroup.setOption(
    AssetType.video,
    const FilterOption(sizeConstraint: ignoreSizeConstraint),
  );
  filterOptionGroup.createTimeCond = DateTimeCond.def().copyWith(ignore: true);
  final assetPaths = await PhotoManager.getAssetPathList(
    hasAll: true,
    type: RequestType.common,
    filterOption: filterOptionGroup,
  );
  final List<LocalAsset> assets = [];
  for (final assetPath in assetPaths) {
    for (final asset in await _getAllAssetLists(assetPath)) {
      assets.add(
        LocalAsset(
          id: asset.id,
          pathName: assetPath.name,
          pathID: assetPath.id,
        ),
      );
    }
  }
  return assets;
}

Future<List<File>> getUnsyncedFiles(
  List<LocalAsset> assets,
  Set<String> existingIDs,
  Set<String> invalidIDs,
  Computer computer,
) async {
  final Map<String, dynamic> args = <String, dynamic>{};
  args['assets'] = assets;
  args['existingIDs'] = existingIDs;
  args['invalidIDs'] = invalidIDs;
  final unsyncedAssets =
      await computer.compute(_getUnsyncedAssets, param: args);
  if (unsyncedAssets.isEmpty) {
    return [];
  }
  return _convertToFiles(unsyncedAssets, computer);
}

List<LocalAsset> _getUnsyncedAssets(Map<String, dynamic> args) {
  final List<LocalAsset> assets = args['assets'];
  final Set<String> existingIDs = args['existingIDs'];
  final Set<String> invalidIDs = args['invalidIDs'];
  final List<LocalAsset> unsyncedAssets = [];
  for (final asset in assets) {
    if (!existingIDs.contains(asset.id) && !invalidIDs.contains(asset.id)) {
      unsyncedAssets.add(asset);
    }
  }
  return unsyncedAssets;
}

Future<List<File>> _convertToFiles(
  List<LocalAsset> assets,
  Computer computer,
) async {
  final Map<String, AssetEntity> assetIDToEntityMap = {};
  final List<File> files = [];
  for (final localAsset in assets) {
    if (!assetIDToEntityMap.containsKey(localAsset.id)) {
      assetIDToEntityMap[localAsset.id] =
          await AssetEntity.fromId(localAsset.id);
    }
    files.add(
      File.fromAsset(
        localAsset.pathName,
        assetIDToEntityMap[localAsset.id],
        devicePathID: localAsset.pathID,
      ),
    );
  }
  return files;
}

Future<List<AssetPathEntity>> _getGalleryList(
  final int fromTime,
  final int toTime,
) async {
  final filterOptionGroup = FilterOptionGroup();
  filterOptionGroup.setOption(
    AssetType.image,
    const FilterOption(needTitle: true, sizeConstraint: ignoreSizeConstraint),
  );
  filterOptionGroup.setOption(
    AssetType.video,
    const FilterOption(needTitle: true, sizeConstraint: ignoreSizeConstraint),
  );

  filterOptionGroup.updateTimeCond = DateTimeCond(
    min: DateTime.fromMicrosecondsSinceEpoch(fromTime),
    max: DateTime.fromMicrosecondsSinceEpoch(toTime),
  );
  final galleryList = await PhotoManager.getAssetPathList(
    hasAll: true,
    type: RequestType.common,
    filterOption: filterOptionGroup,
  );

  galleryList.sort((s1, s2) {
    return s2.assetCount.compareTo(s1.assetCount);
  });

  return galleryList;
}

Future<List<File>> _computeFiles(
  AssetPathEntity pathEntity,
  int fromTime,
  List<File> files,
  Computer computer,
) async {
  final Map<String, dynamic> args = <String, dynamic>{};
  args["pathEntity"] = pathEntity;
  args["assetList"] = await _getAllAssetLists(pathEntity);
  args["fromTime"] = fromTime;
  args["files"] = files;
  return await computer.compute(_getFiles, param: args);
}

Future<List<AssetEntity>> _getAllAssetLists(AssetPathEntity pathEntity) async {
  List<AssetEntity> result = [];
  int currentPage = 0;
  List<AssetEntity> currentPageResult = [];
  do {
    currentPageResult = await pathEntity.getAssetListPaged(
      page: currentPage,
      size: assetFetchPageSize,
    );
    result.addAll(currentPageResult);
    currentPage = currentPage + 1;
  } while (currentPageResult.length >= assetFetchPageSize);
  return result;
}

// review: do we need to run this inside compute, after making File.FromAsset
// sync. If yes, update the method documentation with reason.
Future<List<File>> _getFiles(Map<String, dynamic> args) async {
  final pathEntity = args["pathEntity"] as AssetPathEntity;
  final assetList = args["assetList"];
  final fromTime = args["fromTime"];
  final files = args["files"];
  for (AssetEntity entity in assetList) {
    if (max(
          entity.createDateTime.microsecondsSinceEpoch,
          entity.modifiedDateTime.microsecondsSinceEpoch,
        ) >
        fromTime) {
      try {
        final file = File.fromAsset(
          pathEntity.name,
          entity,
          devicePathID: pathEntity.id,
        );
        files.add(file);
      } catch (e) {
        _logger.severe(e);
      }
    }
  }
  return files;
}

class LocalAsset {
  final String id;
  final String pathID;
  final String pathName;

  LocalAsset({
    @required this.id,
    @required this.pathName,
    @required this.pathID,
  });
}
