import "dart:convert";

import "package:photos/services/face_ml/face_clustering/cosine_distance.dart";
import "package:photos/services/face_ml/face_feedback.dart/feedback.dart";
import "package:photos/services/face_ml/face_feedback.dart/feedback_types.dart";

abstract class ClusterFeedback extends Feedback {
  static final Map<FeedbackType, Function(String)> fromJsonStringRegistry = {
    FeedbackType.deleteClusterFeedback: DeleteClusterFeedback.fromJsonString,
    FeedbackType.mergeClusterFeedback: MergeClusterFeedback.fromJsonString,
    FeedbackType.renameOrCustomThumbnailClusterFeedback:
        RenameOrCustomThumbnailClusterFeedback.fromJsonString,
  };

  final List<double> medoid;
  final double medoidDistanceThreshold;
  // TODO: work out the optimal distance threshold so there's never an overlap between clusters

  ClusterFeedback(
    FeedbackType type,
    this.medoid,
    this.medoidDistanceThreshold, {
    String? feedbackID,
    DateTime? timestamp,
    int? madeOnFaceMlVersion,
    int? madeOnClusterMlVersion,
  }) : super(
          type,
          feedbackID: feedbackID,
          timestamp: timestamp,
          madeOnFaceMlVersion: madeOnFaceMlVersion,
          madeOnClusterMlVersion: madeOnClusterMlVersion,
        );

  /// Compares this feedback with another [ClusterFeedback] to see if they are similar enough that only one should be kept.
  ///
  /// It checks this by comparing the distance between the two medoids with the medoidDistanceThreshold of each feedback.
  ///
  /// Returns true if they are similar enough, false otherwise.
  /// // TODO: Should it maybe return a merged feedback instead, when you are similar enough?
  bool matches(ClusterFeedback other) {
    // Using the cosineDistance function you mentioned
    final double distance = cosineDistance(medoid, other.medoid);

    // Check if the distance is less than either of the threshold values
    return distance < medoidDistanceThreshold ||
        distance < other.medoidDistanceThreshold;
  }
}

class DeleteClusterFeedback extends ClusterFeedback {
  DeleteClusterFeedback({
    required List<double> medoid,
    required double medoidDistanceThreshold,
    String? feedbackID,
    DateTime? timestamp,
    int? madeOnFaceMlVersion,
    int? madeOnClusterMlVersion,
  }) : super(
          FeedbackType.deleteClusterFeedback,
          medoid,
          medoidDistanceThreshold,
          feedbackID: feedbackID,
          timestamp: timestamp,
          madeOnFaceMlVersion: madeOnFaceMlVersion,
          madeOnClusterMlVersion: madeOnClusterMlVersion,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toValueString(),
      'medoid': medoid,
      'medoidDistanceThreshold': medoidDistanceThreshold,
      'feedbackID': feedbackID,
      'timestamp': timestamp.toIso8601String(),
      'madeOnFaceMlVersion': madeOnFaceMlVersion,
      'madeOnClusterMlVersion': madeOnClusterMlVersion,
    };
  }

  @override
  String toJsonString() => jsonEncode(toJson());

  static DeleteClusterFeedback fromJson(Map<String, dynamic> json) {
    assert(json['type'] == FeedbackType.deleteClusterFeedback.toValueString());
    return DeleteClusterFeedback(
      medoid:
          (json['medoid'] as List?)?.map((item) => item as double).toList() ??
              [],
      medoidDistanceThreshold: json['medoidDistanceThreshold'],
      feedbackID: json['feedbackID'],
      timestamp: DateTime.parse(json['timestamp']),
      madeOnFaceMlVersion: json['madeOnFaceMlVersion'],
      madeOnClusterMlVersion: json['madeOnClusterMlVersion'],
    );
  }

  static fromJsonString(String jsonString) {
    return fromJson(jsonDecode(jsonString));
  }
}

class MergeClusterFeedback extends ClusterFeedback {
  final List<double> medoidToMoveTo;

  MergeClusterFeedback({
    required List<double> medoid,
    required double medoidDistanceThreshold,
    required this.medoidToMoveTo,
    String? feedbackID,
    DateTime? timestamp,
    int? madeOnFaceMlVersion,
    int? madeOnClusterMlVersion,
  }) : super(
          FeedbackType.mergeClusterFeedback,
          medoid,
          medoidDistanceThreshold,
          feedbackID: feedbackID,
          timestamp: timestamp,
          madeOnFaceMlVersion: madeOnFaceMlVersion,
          madeOnClusterMlVersion: madeOnClusterMlVersion,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toValueString(),
      'medoid': medoid,
      'medoidDistanceThreshold': medoidDistanceThreshold,
      'medoidToMoveTo': medoidToMoveTo,
      'feedbackID': feedbackID,
      'timestamp': timestamp.toIso8601String(),
      'madeOnFaceMlVersion': madeOnFaceMlVersion,
      'madeOnClusterMlVersion': madeOnClusterMlVersion,
    };
  }

  @override
  String toJsonString() => jsonEncode(toJson());

  static MergeClusterFeedback fromJson(Map<String, dynamic> json) {
    assert(json['type'] == FeedbackType.mergeClusterFeedback.toValueString());
    return MergeClusterFeedback(
      medoid:
          (json['medoid'] as List?)?.map((item) => item as double).toList() ??
              [],
      medoidDistanceThreshold: json['medoidDistanceThreshold'],
      medoidToMoveTo: (json['medoidToMoveTo'] as List?)
              ?.map((item) => item as double)
              .toList() ??
          [],
      feedbackID: json['feedbackID'],
      timestamp: DateTime.parse(json['timestamp']),
      madeOnFaceMlVersion: json['madeOnFaceMlVersion'],
      madeOnClusterMlVersion: json['madeOnClusterMlVersion'],
    );
  }

  static MergeClusterFeedback fromJsonString(String jsonString) {
    return fromJson(jsonDecode(jsonString));
  }
}

class RenameOrCustomThumbnailClusterFeedback extends ClusterFeedback {
  String? customName;
  String? customThumbnailFaceId;

  RenameOrCustomThumbnailClusterFeedback({
    required List<double> medoid,
    required double medoidDistanceThreshold,
    this.customName,
    this.customThumbnailFaceId,
    String? feedbackID,
    DateTime? timestamp,
    int? madeOnFaceMlVersion,
    int? madeOnClusterMlVersion,
  })  : assert(
          customName != null || customThumbnailFaceId != null,
          "Either customName or customThumbnailFaceId must be non-null!",
        ),
        super(
          FeedbackType.renameOrCustomThumbnailClusterFeedback,
          medoid,
          medoidDistanceThreshold,
          feedbackID: feedbackID,
          timestamp: timestamp,
          madeOnFaceMlVersion: madeOnFaceMlVersion,
          madeOnClusterMlVersion: madeOnClusterMlVersion,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toValueString(),
      'medoid': medoid,
      'medoidDistanceThreshold': medoidDistanceThreshold,
      if (customName != null) 'customName': customName,
      if (customThumbnailFaceId != null)
        'customThumbnailFaceId': customThumbnailFaceId,
      'feedbackID': feedbackID,
      'timestamp': timestamp.toIso8601String(),
      'madeOnFaceMlVersion': madeOnFaceMlVersion,
      'madeOnClusterMlVersion': madeOnClusterMlVersion,
    };
  }

  @override
  String toJsonString() => jsonEncode(toJson());

  static RenameOrCustomThumbnailClusterFeedback fromJson(
    Map<String, dynamic> json,
  ) {
    assert(
      json['type'] ==
          FeedbackType.renameOrCustomThumbnailClusterFeedback.toValueString(),
    );
    return RenameOrCustomThumbnailClusterFeedback(
      medoid:
          (json['medoid'] as List?)?.map((item) => item as double).toList() ??
              [],
      medoidDistanceThreshold: json['medoidDistanceThreshold'],
      customName: json['customName'],
      customThumbnailFaceId: json['customThumbnailFaceId'],
      feedbackID: json['feedbackID'],
      timestamp: DateTime.parse(json['timestamp']),
      madeOnFaceMlVersion: json['madeOnFaceMlVersion'],
      madeOnClusterMlVersion: json['madeOnClusterMlVersion'],
    );
  }

  static RenameOrCustomThumbnailClusterFeedback fromJsonString(
    String jsonString,
  ) {
    return fromJson(jsonDecode(jsonString));
  }
}

class RemovePhotoClusterFeedback extends ClusterFeedback {
  final int removedPhotoFileID;

  RemovePhotoClusterFeedback({
    required List<double> medoid,
    required double medoidDistanceThreshold,
    required this.removedPhotoFileID,
    String? feedbackID,
    DateTime? timestamp,
    int? madeOnFaceMlVersion,
    int? madeOnClusterMlVersion,
  }) : super(
          FeedbackType.removePhotoClusterFeedback,
          medoid,
          medoidDistanceThreshold,
          feedbackID: feedbackID,
          timestamp: timestamp,
          madeOnFaceMlVersion: madeOnFaceMlVersion,
          madeOnClusterMlVersion: madeOnClusterMlVersion,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toValueString(),
      'medoid': medoid,
      'medoidDistanceThreshold': medoidDistanceThreshold,
      'removedPhotoFileID': removedPhotoFileID,
      'feedbackID': feedbackID,
      'timestamp': timestamp.toIso8601String(),
      'madeOnFaceMlVersion': madeOnFaceMlVersion,
      'madeOnClusterMlVersion': madeOnClusterMlVersion,
    };
  }

  @override
  String toJsonString() => jsonEncode(toJson());

  static RemovePhotoClusterFeedback fromJson(Map<String, dynamic> json) {
    assert(
      json['type'] == FeedbackType.removePhotoClusterFeedback.toValueString(),
    );
    return RemovePhotoClusterFeedback(
      medoid:
          (json['medoid'] as List?)?.map((item) => item as double).toList() ??
              [],
      medoidDistanceThreshold: json['medoidDistanceThreshold'],
      removedPhotoFileID: json['removedPhotoFileID'],
      feedbackID: json['feedbackID'],
      timestamp: DateTime.parse(json['timestamp']),
      madeOnFaceMlVersion: json['madeOnFaceMlVersion'],
      madeOnClusterMlVersion: json['madeOnClusterMlVersion'],
    );
  }

  static RemovePhotoClusterFeedback fromJsonString(String jsonString) {
    return fromJson(jsonDecode(jsonString));
  }
}

class AddPhotoClusterFeedback extends ClusterFeedback {
  final List<int> addedPhotoFileIDs;

  AddPhotoClusterFeedback({
    required List<double> medoid,
    required double medoidDistanceThreshold,
    required this.addedPhotoFileIDs,
    String? feedbackID,
    DateTime? timestamp,
    int? madeOnFaceMlVersion,
    int? madeOnClusterMlVersion,
  }) : super(
          FeedbackType.addPhotoClusterFeedback,
          medoid,
          medoidDistanceThreshold,
          feedbackID: feedbackID,
          timestamp: timestamp,
          madeOnFaceMlVersion: madeOnFaceMlVersion,
          madeOnClusterMlVersion: madeOnClusterMlVersion,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toValueString(),
      'medoid': medoid,
      'medoidDistanceThreshold': medoidDistanceThreshold,
      'addedPhotoFileIDs': addedPhotoFileIDs,
      'feedbackID': feedbackID,
      'timestamp': timestamp.toIso8601String(),
      'madeOnFaceMlVersion': madeOnFaceMlVersion,
      'madeOnClusterMlVersion': madeOnClusterMlVersion,
    };
  }

  @override
  String toJsonString() => jsonEncode(toJson());

  static AddPhotoClusterFeedback fromJson(Map<String, dynamic> json) {
    assert(
      json['type'] == FeedbackType.addPhotoClusterFeedback.toValueString(),
    );
    return AddPhotoClusterFeedback(
      medoid:
          (json['medoid'] as List?)?.map((item) => item as double).toList() ??
              [],
      medoidDistanceThreshold: json['medoidDistanceThreshold'],
      addedPhotoFileIDs: (json['addedPhotoFileIDs'] as List?)
              ?.map((item) => item as int)
              .toList() ??
          [],
      feedbackID: json['feedbackID'],
      timestamp: DateTime.parse(json['timestamp']),
      madeOnFaceMlVersion: json['madeOnFaceMlVersion'],
      madeOnClusterMlVersion: json['madeOnClusterMlVersion'],
    );
  }

  static AddPhotoClusterFeedback fromJsonString(String jsonString) {
    return fromJson(jsonDecode(jsonString));
  }
}
