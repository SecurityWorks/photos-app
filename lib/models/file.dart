import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/models/file_type.dart';
import 'package:photos/models/location.dart';
import 'package:photos/utils/crypto_util.dart';

class File {
  int generatedID;
  int uploadedFileID;
  int ownerID;
  String localID;
  String title;
  String deviceFolder;
  int remoteFolderID;
  int creationTime;
  int modificationTime;
  int updationTime;
  Location location;
  FileType fileType;

  File();

  File.fromJson(Map<String, dynamic> json) {
    uploadedFileID = json["id"];
    ownerID = json["ownerID"];
    localID = json["deviceFileID"];
    deviceFolder = json["deviceFolder"];
    title = json["title"];
    fileType = getFileType(json["fileType"]);
    creationTime = json["creationTime"];
    modificationTime = json["modificationTime"];
    updationTime = json["updationTime"];
  }

  static Future<File> fromAsset(
      AssetPathEntity pathEntity, AssetEntity asset) async {
    File file = File();
    file.localID = asset.id;
    file.title = asset.title;
    file.deviceFolder = pathEntity.name;
    file.location = Location(asset.latitude, asset.longitude);
    switch (asset.type) {
      case AssetType.image:
        file.fileType = FileType.image;
        break;
      case AssetType.video:
        file.fileType = FileType.video;
        break;
      default:
        file.fileType = FileType.other;
        break;
    }
    file.creationTime = asset.createDateTime.microsecondsSinceEpoch;
    if (file.creationTime == 0) {
      try {
        final parsedDateTime = DateTime.parse(
            basenameWithoutExtension(file.title)
                .replaceAll("IMG_", "")
                .replaceAll("DCIM_", "")
                .replaceAll("_", " "));
        file.creationTime = parsedDateTime.microsecondsSinceEpoch;
      } catch (e) {
        file.creationTime = asset.modifiedDateTime.microsecondsSinceEpoch;
      }
    }
    file.modificationTime = asset.modifiedDateTime.microsecondsSinceEpoch;
    return file;
  }

  Future<AssetEntity> getAsset() {
    return AssetEntity.fromId(localID);
  }

  Future<Uint8List> getBytes({int quality = 100}) async {
    if (localID == null) {
      return HttpClient().getUrl(Uri.parse(getDownloadUrl())).then((request) {
        return request.close().then((response) {
          return consolidateHttpClientResponseBytes(response);
        });
      });
    } else {
      final originalBytes = (await getAsset()).originBytes;
      if (extension(title) == ".HEIC" || quality != 100) {
        return originalBytes.then((bytes) {
          return FlutterImageCompress.compressWithList(bytes, quality: quality)
              .then((converted) {
            return Uint8List.fromList(converted);
          });
        });
      } else {
        return originalBytes;
      }
    }
  }

  void applyMetadata(Map<String, dynamic> metadata) {
    localID = metadata["localID"];
    title = metadata["title"];
    deviceFolder = metadata["deviceFolder"];
    creationTime = metadata["creationTime"];
    modificationTime = metadata["modificationTime"];
    final latitude = metadata["latitude"];
    final longitude = metadata["longitude"];
    location = Location(latitude, longitude);
    fileType = getFileType(metadata["fileType"]);
  }

  Map<String, dynamic> getMetadata() {
    final metadata = Map<String, dynamic>();
    metadata["localID"] = localID;
    metadata["title"] = title;
    metadata["deviceFolder"] = deviceFolder;
    metadata["creationTime"] = creationTime;
    metadata["modificationTime"] = modificationTime;
    metadata["latitude"] = location.latitude;
    metadata["longitude"] = location.longitude;
    metadata["fileType"] = fileType.index;
    return metadata;
  }

  String getDownloadUrl() {
    return Configuration.instance.getHttpEndpoint() +
        "/files/download/" +
        uploadedFileID.toString() +
        "?token=" +
        Configuration.instance.getToken();
  }

  // Passing token within the URL due to https://github.com/flutter/flutter/issues/16466
  String getStreamUrl() {
    return Configuration.instance.getHttpEndpoint() +
        "/streams/" +
        Configuration.instance.getToken() +
        "/" +
        uploadedFileID.toString() +
        "/index.m3u8";
  }

  String getThumbnailUrl() {
    return Configuration.instance.getHttpEndpoint() +
        "/files/preview/" +
        uploadedFileID.toString() +
        "?token=" +
        Configuration.instance.getToken();
  }

  @override
  String toString() {
    return '''File(generatedId: $generatedID, uploadedFileId: $uploadedFileID, 
      localId: $localID, title: $title, deviceFolder: $deviceFolder, 
      location: $location, fileType: $fileType, creationTime: $creationTime, 
      modificationTime: $modificationTime, updationTime: $updationTime)''';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is File &&
        o.generatedID == generatedID &&
        o.uploadedFileID == uploadedFileID &&
        o.localID == localID;
  }

  @override
  int get hashCode {
    return generatedID.hashCode ^ uploadedFileID.hashCode ^ localID.hashCode;
  }

  String tag() {
    return "local_" +
        localID.toString() +
        ":remote_" +
        uploadedFileID.toString() +
        ":generated_" +
        generatedID.toString();
  }
}
