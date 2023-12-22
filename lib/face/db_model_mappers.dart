import "dart:convert";

import 'package:photos/face/db_fields.dart';
import "package:photos/face/model/face.dart";
import 'package:photos/face/model/person_face.dart';
import "package:photos/generated/protos/ente/common/vector.pb.dart";

int boolToSQLInt(bool? value, {bool defaultValue = false}) {
  final bool v = value ?? defaultValue;
  if (v == false) {
    return 0;
  } else {
    return 1;
  }
}

bool sqlIntToBool(int? value, {bool defaultValue = false}) {
  final int v = value ?? (defaultValue ? 1 : 0);
  if (v == 0) {
    return false;
  } else {
    return true;
  }
}

Map<String, dynamic> mapToFaceDB(PersonFace personFace) {
  return {
    faceIDColumn: personFace.face.faceID,
    faceDetectionColumn: json.encode(personFace.face.detection.toJson()),
    faceConfirmedColumn: boolToSQLInt(personFace.confirmed),
    facePersonIDColumn: personFace.personID,
    faceClosestDistColumn: personFace.closeDist,
    faceClosestFaceID: personFace.closeFaceID,
  };
}

Map<String, dynamic> mapRemoteToFaceDB(Face face) {
  return {
    faceIDColumn: face.faceID,
    fileIDColumn: face.fileID,
    faceDetectionColumn: json.encode(face.detection.toJson()),
    faceEmbeddingBlob: EVector(
      values: face.embedding,
    ).writeToBuffer(),
    faceScore: face.score,
    mlVersionColumn: 1,
  };
}
