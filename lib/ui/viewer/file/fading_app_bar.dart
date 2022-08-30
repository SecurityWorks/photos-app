import 'dart:io';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as file_path;
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/events/local_photos_updated_event.dart';
import 'package:photos/models/file.dart';
import 'package:photos/models/file_type.dart';
import 'package:photos/models/ignored_file.dart';
import 'package:photos/models/trash_file.dart';
import 'package:photos/services/favorites_service.dart';
import 'package:photos/services/ignored_files_service.dart';
import 'package:photos/services/local_sync_service.dart';
import 'package:photos/ui/common/progress_dialog.dart';
import 'package:photos/ui/viewer/file/custom_app_bar.dart';
import 'package:photos/utils/delete_file_util.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/file_util.dart';
import 'package:photos/utils/toast_util.dart';

class FadingAppBar extends StatefulWidget implements PreferredSizeWidget {
  final File file;
  final Function(File) onFileDeleted;
  final double height;
  final bool shouldShowActions;
  final int userID;

  const FadingAppBar(
    this.file,
    this.onFileDeleted,
    this.userID,
    this.height,
    this.shouldShowActions, {
    Key key,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  FadingAppBarState createState() => FadingAppBarState();
}

class FadingAppBarState extends State<FadingAppBar> {
  final _logger = Logger("FadingAppBar");
  bool _shouldHide = false;

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      IgnorePointer(
        ignoring: _shouldHide,
        child: AnimatedOpacity(
          opacity: _shouldHide ? 0 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.72),
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
                stops: const [0, 0.2, 1],
              ),
            ),
            child: _buildAppBar(),
          ),
        ),
      ),
      height: Platform.isAndroid ? 80 : 96,
    );
  }

  void hide() {
    setState(() {
      _shouldHide = true;
    });
  }

  void show() {
    if (mounted) {
      setState(() {
        _shouldHide = false;
      });
    }
  }

  AppBar _buildAppBar() {
    debugPrint("building app bar");
    final List<Widget> actions = [];
    final isTrashedFile = widget.file is TrashFile;
    final shouldShowActions = widget.shouldShowActions && !isTrashedFile;
    // only show fav option for files owned by the user
    if (widget.file.ownerID == null || widget.file.ownerID == widget.userID) {
      actions.add(_getFavoriteButton());
    }
    actions.add(
      PopupMenuButton(
        itemBuilder: (context) {
          final List<PopupMenuItem> items = [];
          if (widget.file.isRemoteFile()) {
            items.add(
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(
                      Platform.isAndroid
                          ? Icons.download
                          : CupertinoIcons.cloud_download,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    const Text("Download"),
                  ],
                ),
              ),
            );
          }
          // options for files owned by the user
          if (widget.file.ownerID == null ||
              widget.file.ownerID == widget.userID) {
            items.add(
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(
                      Platform.isAndroid
                          ? Icons.delete_outline
                          : CupertinoIcons.delete,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    const Text("Delete"),
                  ],
                ),
              ),
            );
          }
          return items;
        },
        onSelected: (value) {
          if (value == 1) {
            _download(widget.file);
          } else if (value == 2) {
            _showDeleteSheet(widget.file);
          }
        },
      ),
    );
    return AppBar(
      iconTheme:
          const IconThemeData(color: Colors.white), //same for both themes
      actions: shouldShowActions ? actions : [],
      elevation: 0,
      backgroundColor: const Color(0x00000000),
    );
  }

  Widget _getFavoriteButton() {
    return FutureBuilder(
      future: FavoritesService.instance.isFavorite(widget.file),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _getLikeButton(widget.file, snapshot.data);
        } else {
          return _getLikeButton(widget.file, false);
        }
      },
    );
  }

  Widget _getLikeButton(File file, bool isLiked) {
    return LikeButton(
      isLiked: isLiked,
      onTap: (oldValue) async {
        final isLiked = !oldValue;
        bool hasError = false;
        if (isLiked) {
          final shouldBlockUser = file.uploadedFileID == null;
          ProgressDialog dialog;
          if (shouldBlockUser) {
            dialog = createProgressDialog(context, "Adding to favorites...");
            await dialog.show();
          }
          try {
            await FavoritesService.instance.addToFavorites(file);
          } catch (e, s) {
            _logger.severe(e, s);
            hasError = true;
            showToast(context, "Sorry, could not add this to favorites!");
          } finally {
            if (shouldBlockUser) {
              await dialog.hide();
            }
          }
        } else {
          try {
            await FavoritesService.instance.removeFromFavorites(file);
          } catch (e, s) {
            _logger.severe(e, s);
            hasError = true;
            showToast(context, "Sorry, could not remove this from favorites!");
          }
        }
        return hasError ? oldValue : isLiked;
      },
      likeBuilder: (isLiked) {
        return Icon(
          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color:
              isLiked ? Colors.pinkAccent : Colors.white, //same for both themes
          size: 24,
        );
      },
    );
  }

  void _showDeleteSheet(File file) {
    final List<Widget> actions = [];
    if (file.uploadedFileID == null || file.localID == null) {
      actions.add(
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () async {
            await deleteFilesFromEverywhere(context, [file]);
            Navigator.of(context, rootNavigator: true).pop();
            widget.onFileDeleted(file);
          },
          child: const Text("Everywhere"),
        ),
      );
    } else {
      // uploaded file which is present locally too
      actions.add(
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () async {
            await deleteFilesOnDeviceOnly(context, [file]);
            showToast(context, "File deleted from device");
            Navigator.of(context, rootNavigator: true).pop();
            // TODO: Fix behavior when inside a device folder
          },
          child: const Text("Device"),
        ),
      );

      actions.add(
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () async {
            await deleteFilesFromRemoteOnly(context, [file]);
            showShortToast(context, "Moved to trash");
            Navigator.of(context, rootNavigator: true).pop();
            // TODO: Fix behavior when inside a collection
          },
          child: const Text("ente"),
        ),
      );

      actions.add(
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () async {
            await deleteFilesFromEverywhere(context, [file]);
            Navigator.of(context, rootNavigator: true).pop();
            widget.onFileDeleted(file);
          },
          child: const Text("Everywhere"),
        ),
      );
    }
    final action = CupertinoActionSheet(
      title: const Text("Delete file?"),
      actions: actions,
      cancelButton: CupertinoActionSheetAction(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  Future<void> _download(File file) async {
    final dialog = createProgressDialog(context, "Downloading...");
    await dialog.show();
    final FileType type = file.fileType;
    // save and track image for livePhoto/image and video for FileType.video
    final io.File fileToSave = await getFile(file);
    final savedAsset = type == FileType.video
        ? (await PhotoManager.editor.saveVideo(fileToSave, title: file.title))
        : (await PhotoManager.editor
            .saveImageWithPath(fileToSave.path, title: file.title));
    // immediately track assetID to avoid duplicate upload
    await LocalSyncService.instance.trackDownloadedFile(savedAsset.id);
    file.localID = savedAsset.id;
    await FilesDB.instance.insert(file);

    if (type == FileType.livePhoto) {
      final io.File liveVideo = await getFileFromServer(file, liveVideo: true);
      if (liveVideo == null) {
        _logger.warning("Failed to find live video" + file.tag());
      } else {
        final videoTitle = file_path.basenameWithoutExtension(file.title) +
            file_path.extension(liveVideo.path);
        final savedAsset = (await PhotoManager.editor.saveVideo(
          liveVideo,
          title: videoTitle,
        ));
        final ignoreVideoFile = IgnoredFile(
          savedAsset.id,
          savedAsset.title ?? videoTitle,
          savedAsset.relativePath ?? 'remoteDownload',
          "remoteDownload",
        );
        debugPrint("IgnoreFile for auto-upload ${ignoreVideoFile.toString()}");
        await IgnoredFilesService.instance.cacheAndInsert([ignoreVideoFile]);
      }
    }

    Bus.instance.fire(LocalPhotosUpdatedEvent([file]));
    await dialog.hide();
    if (file.fileType == FileType.livePhoto) {
      showToast(context, "Photo and video saved to gallery");
    } else {
      showToast(context, "File saved to gallery");
    }
  }
}
