import "package:photos/models/file/file.dart";
import "package:photos/models/file/file_type.dart";

extension FilePropsExtn on EnteFile {
  bool get isLivePhoto => fileType == FileType.livePhoto;

  bool get isMotionPhoto => pubMagicMetadata?.mvi != null;

  bool get isLiveOrMotionPhoto => isLivePhoto || isMotionPhoto;
}
