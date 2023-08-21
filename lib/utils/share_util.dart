import 'dart:async';
import 'dart:io' as dartio;

import 'package:flutter/widgets.dart';
import "package:image_picker/image_picker.dart";
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/constants.dart';
import 'package:photos/models/file.dart';
import 'package:photos/models/file_type.dart';
import 'package:photos/utils/date_time_util.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/exif_util.dart';
import 'package:photos/utils/file_util.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_plus/share_plus.dart';

final _logger = Logger("ShareUtil");
// Set of possible image extensions
final _imageExtension = {"jpg", "jpeg", "png", "heic", "heif", "webp", ".gif"};
final _videoExtension = {
  "mp4",
  "mov",
  "avi",
  "mkv",
  "webm",
  "wmv",
  "flv",
  "3gp",
};
// share is used to share media/files from ente to other apps
Future<void> share(
  BuildContext context,
  List<File> files, {
  GlobalKey? shareButtonKey,
}) async {
  final remoteFileCount = files.where((element) => element.isRemoteFile).length;
  final dialog = createProgressDialog(
    context,
    "Preparing...",
    isDismissible: remoteFileCount > 2,
  );
  await dialog.show();
  try {
    final List<Future<String?>> pathFutures = [];
    for (File file in files) {
      // Note: We are requesting the origin file for performance reasons on iOS.
      // This will eat up storage, which will be reset only when the app restarts.
      // We could have cleared the cache had there been a callback to the share API.
      pathFutures.add(
        getFile(file, isOrigin: true).then((fetchedFile) => fetchedFile?.path),
      );
      if (file.fileType == FileType.livePhoto) {
        pathFutures.add(
          getFile(file, liveVideo: true)
              .then((fetchedFile) => fetchedFile?.path),
        );
      }
    }
    final paths = await Future.wait(pathFutures);
    await dialog.hide();
    paths.removeWhere((element) => element == null);
    final List<String> nonNullPaths = paths.map((element) => element!).toList();
    return Share.shareFiles(
      nonNullPaths,
      // required for ipad https://github.com/flutter/flutter/issues/47220#issuecomment-608453383
      sharePositionOrigin: shareButtonRect(context, shareButtonKey),
    );
  } catch (e, s) {
    _logger.severe(
      "failed to fetch files for system share ${files.length}",
      e,
      s,
    );
    await dialog.hide();
    await showGenericErrorDialog(context: context);
  }
}

Rect shareButtonRect(BuildContext context, GlobalKey? shareButtonKey) {
  Size size = MediaQuery.of(context).size;
  final RenderObject? renderObject =
      shareButtonKey?.currentContext?.findRenderObject();
  RenderBox? renderBox;
  if (renderObject != null && renderObject is RenderBox) {
    renderBox = renderObject;
  }
  if (renderBox == null) {
    return Rect.fromLTWH(0, 0, size.width, size.height / 2);
  }
  size = renderBox.size;
  final Offset position = renderBox.localToGlobal(Offset.zero);
  return Rect.fromCenter(
    center: position + Offset(size.width / 2, size.height / 2),
    width: size.width,
    height: size.height,
  );
}

Future<void> shareText(String text) async {
  return Share.share(text);
}

Future<List<File>> convertIncomingSharedMediaToFile(
  List<SharedMediaFile> sharedMedia,
  int collectionID,
) async {
  final List<File> localFiles = [];
  for (var media in sharedMedia) {
    if (!(media.type == SharedMediaType.IMAGE ||
        media.type == SharedMediaType.VIDEO)) {
      _logger.warning(
        "ignore unsupported file type ${media.type.toString()} path: ${media.path}",
      );
      continue;
    }
    final enteFile = File();
    // fileName: img_x.jpg
    enteFile.title = basename(media.path);
    var ioFile = dartio.File(media.path);
    ioFile = ioFile.renameSync(
      Configuration.instance.getSharedMediaDirectory() + "/" + enteFile.title!,
    );
    enteFile.localID = sharedMediaIdentifier + enteFile.title!;
    enteFile.collectionID = collectionID;
    enteFile.fileType =
        media.type == SharedMediaType.IMAGE ? FileType.image : FileType.video;
    if (enteFile.fileType == FileType.image) {
      final exifTime = await getCreationTimeFromEXIF(ioFile, null);
      if (exifTime != null) {
        enteFile.creationTime = exifTime.microsecondsSinceEpoch;
      }
    } else if (enteFile.fileType == FileType.video) {
      enteFile.duration = (media.duration ?? 0) ~/ 1000;
    }
    if (enteFile.creationTime == null || enteFile.creationTime == 0) {
      final parsedDateTime =
          parseDateTimeFromFileNameV2(basenameWithoutExtension(media.path));
      if (parsedDateTime != null) {
        enteFile.creationTime = parsedDateTime.microsecondsSinceEpoch;
      } else {
        enteFile.creationTime = DateTime.now().microsecondsSinceEpoch;
      }
    }
    enteFile.modificationTime = enteFile.creationTime;
    localFiles.add(enteFile);
  }
  return localFiles;
}

Future<List<File>> convertPickedFiles(
  List<XFile> pickedFiles,
  int collectionID,
) async {
  final List<File> localFiles = [];
  for (var media in pickedFiles) {
    FileType? enteTypeType;
    final String mimeType = (media.mimeType ?? '').toLowerCase();
    if (mimeType.contains('image')) {
      enteTypeType = FileType.image;
    } else if (mimeType.contains('video')) {
      enteTypeType = FileType.video;
    } else {
      final extenName = extension(media.path ?? '').toLowerCase().replaceFirst(
            '.',
            '',
          );
      if (_imageExtension.contains(extenName)) {
        enteTypeType = FileType.image;
      } else if (_videoExtension.contains(extenName)) {
        enteTypeType = FileType.video;
      } else {
        _logger.warning(
          "ignore file type ${media.mimeType}, extn $extenName path: ${media.path}",
        );
        continue;
      }
    }
    final enteFile = File();
    // fileName: img_x.jpg
    enteFile.title = basename(media.path);
    var ioFile = dartio.File(media.path);
    ioFile = ioFile.renameSync(
      Configuration.instance.getSharedMediaDirectory() + "/" + enteFile.title!,
    );
    enteFile.localID = sharedMediaIdentifier + enteFile.title!;
    enteFile.collectionID = collectionID;
    enteFile.fileType = enteTypeType;
    if (enteFile.fileType == FileType.image) {
      final exifTime = await getCreationTimeFromEXIF(ioFile, null);
      if (exifTime != null) {
        enteFile.creationTime = exifTime.microsecondsSinceEpoch;
      }
    } else if (enteFile.fileType == FileType.video) {
      // enteFile.duration = (media.duration ?? 0) ~/ 1000;
    }
    if (enteFile.creationTime == null || enteFile.creationTime == 0) {
      final parsedDateTime =
          parseDateTimeFromFileNameV2(basenameWithoutExtension(media.path));
      if (parsedDateTime != null) {
        enteFile.creationTime = parsedDateTime.microsecondsSinceEpoch;
      } else {
        enteFile.creationTime = DateTime.now().microsecondsSinceEpoch;
      }
    }
    enteFile.modificationTime = enteFile.creationTime;
    localFiles.add(enteFile);
  }
  return localFiles;
}

DateTime? parseDateFromFileNam1e(String fileName) {
  if (fileName.startsWith('IMG-') || fileName.startsWith('VID-')) {
    // Whatsapp media files
    return DateTime.tryParse(fileName.split('-')[1]);
  } else if (fileName.startsWith("Screenshot_")) {
    // Screenshots on droid
    return DateTime.tryParse(
      (fileName).replaceAll('Screenshot_', '').replaceAll('-', 'T'),
    );
  } else {
    return DateTime.tryParse(
      (fileName)
          .replaceAll("IMG_", "")
          .replaceAll("VID_", "")
          .replaceAll("DCIM_", "")
          .replaceAll("_", " "),
    );
  }
}

void shareSelected(
  BuildContext context,
  GlobalKey shareButtonKey,
  List<File> selectedFiles,
) {
  share(
    context,
    selectedFiles.toList(),
    shareButtonKey: shareButtonKey,
  );
}
