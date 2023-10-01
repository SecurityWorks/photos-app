import "dart:typed_data";

import "package:logging/logging.dart";
import "package:photos/db/files_db.dart";
import "package:photos/db/ml_data_db.dart";
import "package:photos/models/file/file.dart";
import "package:photos/utils/image_package_util.dart";
import "package:photos/utils/thumbnail_util.dart";

class FaceSearchService {
  final _logger = Logger("FaceSearchService");

  final _mlDatabase = MlDataDB.instance;
  final _filesDatabase = FilesDB.instance;

  // singleton pattern
  FaceSearchService._privateConstructor();
  static final instance = FaceSearchService._privateConstructor();
  factory FaceSearchService() => instance;

  /// Returns the personIDs of all clustered people in the database.
  Future<List<int>> getAllPeople() async {
    final peopleIds = await _mlDatabase.getAllClusterIds();
    return peopleIds;
  }

  /// Returns the thumbnail associated with a given personId.
  Future<Uint8List?> getPersonThumbnail(int personID) async {
    // get the cluster associated with the personID
    final cluster = await _mlDatabase.getClusterResult(personID);
    if (cluster == null) {
      _logger.warning(
        "No cluster found for personID $personID, unable to get thumbnail.",
      );
      return null;
    }

    // get the faceID and fileID you want to use to generate the thumbnail
    final String thumbnailFaceID = cluster.thumbnailFaceId;
    final int thumbnailFileID = cluster.thumbnailFileId;

    // get the full file thumbnail
    final EnteFile enteFile = await _filesDatabase
        .getFilesFromIDs([thumbnailFileID]).then((value) => value.values.first);
    final Uint8List? fileThumbnail = await getThumbnail(enteFile);
    if (fileThumbnail == null) {
      _logger.warning(
        "No full file thumbnail found for thumbnail faceID $thumbnailFaceID, unable to get thumbnail.",
      );
      return null;
    }

    // get the face detection for the thumbnail
    final thumbnailMlResult =
        await _mlDatabase.getFaceMlResult(thumbnailFileID);
    if (thumbnailMlResult == null) {
      _logger.warning(
        "No face ml result found for thumbnail faceID $thumbnailFaceID, unable to get thumbnail.",
      );
      return null;
    }
    final detection = thumbnailMlResult.getDetectionForFaceId(thumbnailFaceID);

    // create the thumbnail from the full file thumbnail and the face detection
    final Uint8List? faceThumbnail = await generateFaceThumbnail(
      fileThumbnail,
      enteFile.displayName,
      detection,
      
    );
    if (faceThumbnail == null) {
      _logger.warning(
        "Unable to generate face thumbnail for thumbnail faceID $thumbnailFaceID, unable to get thumbnail.",
      );
      return null;
    }

    return faceThumbnail;
  }

  /// Returns all files associated with a given personId.
  Future<List<EnteFile>> getFilesForPerson(int personID) async {
    final fileIDs = await _mlDatabase.getClusterFileIds(personID);

    final Map<int, EnteFile> files =
        await _filesDatabase.getFilesFromIDs(fileIDs);
    return files.values.toList();
  }
}
