import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/cache/thumbnail_in_memory_cache.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/constants.dart';
import 'package:photos/core/errors.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/db/trash_db.dart';
import 'package:photos/events/files_updated_event.dart';
import 'package:photos/events/local_photos_updated_event.dart';
import 'package:photos/models/collection.dart';
import 'package:photos/models/file.dart';
import 'package:photos/models/file_type.dart';
import 'package:photos/models/trash_file.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/services/favorites_service.dart';
import 'package:photos/ui/viewer/file/file_icons_widget.dart';
import 'package:photos/utils/file_util.dart';
import 'package:photos/utils/thumbnail_util.dart';

class ThumbnailWidget extends StatefulWidget {
  final File? file;
  final BoxFit fit;
  final bool shouldShowSyncStatus;
  final bool shouldShowArchiveStatus;
  final bool showFavForAlbumOnly;
  final bool shouldShowLivePhotoOverlay;
  final Duration? diskLoadDeferDuration;
  final Duration? serverLoadDeferDuration;
  final int thumbnailSize;
  final bool shouldShowOwnerAvatar;

  ThumbnailWidget(
    this.file, {
    Key? key,
    this.fit = BoxFit.cover,
    this.shouldShowSyncStatus = true,
    this.shouldShowLivePhotoOverlay = false,
    this.shouldShowArchiveStatus = false,
    this.showFavForAlbumOnly = false,
    this.shouldShowOwnerAvatar = false,
    this.diskLoadDeferDuration,
    this.serverLoadDeferDuration,
    this.thumbnailSize = thumbnailSmallSize,
  }) : super(key: key ?? Key(file!.tag));

  @override
  State<ThumbnailWidget> createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  static final _logger = Logger("ThumbnailWidget");
  bool _hasLoadedThumbnail = false;
  bool _isLoadingLocalThumbnail = false;
  bool _errorLoadingLocalThumbnail = false;
  bool _isLoadingRemoteThumbnail = false;
  bool _errorLoadingRemoteThumbnail = false;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    Future.delayed(const Duration(milliseconds: 10), () {
      // Cancel request only if the widget has been unmounted
      if (!mounted && widget.file!.isRemoteFile && !_hasLoadedThumbnail) {
        removePendingGetThumbnailRequestIfAny(widget.file!);
      }
    });
  }

  @override
  void didUpdateWidget(ThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file!.generatedID != oldWidget.file!.generatedID) {
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.file!.isRemoteFile) {
      _loadNetworkImage();
    } else {
      _loadLocalImage(context);
    }
    Widget? image;
    if (_imageProvider != null) {
      image = Image(
        image: _imageProvider!,
        fit: widget.fit,
      );
    }
    // todo: [2ndJuly22] pref-review if the content Widget which depends on
    // thumbnail fetch logic should be part of separate stateFull widget.
    // If yes, parent thumbnail widget can be stateless
    Widget? content;
    if (image != null) {
      final List<Widget> contentChildren = [image];
      if (FavoritesService.instance.isFavoriteCache(
        widget.file!,
        checkOnlyAlbum: widget.showFavForAlbumOnly,
      )) {
        contentChildren.add(const FavoriteOverlayIcon());
      }
      if (widget.file!.fileType == FileType.video) {
        contentChildren.add(const VideoOverlayIcon());
      } else if (widget.shouldShowLivePhotoOverlay &&
          (widget.file!.fileType == FileType.livePhoto ||
              ((widget.file!.pubMagicMetadata?.mvi ?? 0) > 0))) {
        contentChildren.add(const LivePhotoOverlayIcon());
      }
      if (widget.shouldShowOwnerAvatar) {
        if (widget.file!.ownerID != null &&
            widget.file!.ownerID != Configuration.instance.getUserID()) {
          final owner = CollectionsService.instance
              .getFileOwner(widget.file!.ownerID!, widget.file!.collectionID);
          // hide this icon if the current thumbnail is being showed as album
          // cover
          contentChildren.add(
            OwnerAvatarOverlayIcon(owner),
          );
        } else if (widget.file!.pubMagicMetadata!.uploaderName != null) {
          contentChildren.add(
            // Use -1 as userID for enforcing black avatar color
            OwnerAvatarOverlayIcon(
              User(
                id: -1,
                email: '',
                name: widget.file!.pubMagicMetadata!.uploaderName,
              ),
            ),
          );
        }
      }
      content = contentChildren.length == 1
          ? contentChildren.first
          : Stack(
              fit: StackFit.expand,
              children: contentChildren,
            );
    }
    final List<Widget> viewChildren = [
      const ThumbnailPlaceHolder(),
      AnimatedOpacity(
        opacity: content == null ? 0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: content,
      )
    ];
    if (widget.shouldShowSyncStatus && widget.file!.uploadedFileID == null) {
      viewChildren.add(const UnSyncedIcon());
    }
    if (kDebugMode &&
        widget.shouldShowSyncStatus &&
        widget.file!.uploadedFileID != null) {
      if (widget.file!.localID != null) {
        viewChildren.add(const DeviceIcon());
      } else {
        viewChildren.add(const CloudOnlyIcon());
      }
    }
    if (widget.file is TrashFile) {
      viewChildren.add(TrashedFileOverlayText(widget.file as TrashFile));
    }
    // todo: Move this icon overlay to the collection widget.
    if (widget.shouldShowArchiveStatus) {
      viewChildren.add(const ArchiveOverlayIcon());
    }

    return Stack(
      fit: StackFit.expand,
      children: viewChildren,
    );
  }

  void _loadLocalImage(BuildContext context) {
    if (!_hasLoadedThumbnail &&
        !_errorLoadingLocalThumbnail &&
        !_isLoadingLocalThumbnail) {
      _isLoadingLocalThumbnail = true;
      final cachedSmallThumbnail =
          ThumbnailInMemoryLruCache.get(widget.file!, thumbnailSmallSize);
      if (cachedSmallThumbnail != null) {
        _imageProvider = Image.memory(cachedSmallThumbnail).image;
        _hasLoadedThumbnail = true;
      } else {
        if (widget.diskLoadDeferDuration != null) {
          Future.delayed(widget.diskLoadDeferDuration!, () {
            if (mounted) {
              _getThumbnailFromDisk();
            }
          });
        } else {
          _getThumbnailFromDisk();
        }
      }
    }
  }

  Future _getThumbnailFromDisk() async {
    getThumbnailFromLocal(
      widget.file!,
      size: widget.thumbnailSize,
    ).then((thumbData) async {
      if (thumbData == null) {
        if (widget.file!.uploadedFileID != null) {
          _logger.fine("Removing localID reference for " + widget.file!.tag);
          widget.file!.localID = null;
          if (widget.file is TrashFile) {
            TrashDB.instance.update(widget.file as TrashFile);
          } else {
            FilesDB.instance.update(widget.file!);
          }
          _loadNetworkImage();
        } else {
          if (await doesLocalFileExist(widget.file!) == false) {
            _logger.info("Deleting file " + widget.file!.tag);
            FilesDB.instance.deleteLocalFile(widget.file!);
            Bus.instance.fire(
              LocalPhotosUpdatedEvent(
                [widget.file!],
                type: EventType.deletedFromDevice,
                source: "thumbFileDeleted",
              ),
            );
          }
        }
        return;
      }

      if (mounted) {
        final imageProvider = Image.memory(thumbData).image;
        _cacheAndRender(imageProvider);
      }
      ThumbnailInMemoryLruCache.put(
        widget.file!,
        thumbData,
        thumbnailSmallSize,
      );
    }).catchError((e) {
      _logger.warning("Could not load image: ", e);
      _errorLoadingLocalThumbnail = true;
    });
  }

  void _loadNetworkImage() {
    if (!_hasLoadedThumbnail &&
        !_errorLoadingRemoteThumbnail &&
        !_isLoadingRemoteThumbnail) {
      _isLoadingRemoteThumbnail = true;
      final cachedThumbnail = ThumbnailInMemoryLruCache.get(widget.file!);
      if (cachedThumbnail != null) {
        _imageProvider = Image.memory(cachedThumbnail).image;
        _hasLoadedThumbnail = true;
        return;
      }
      if (widget.serverLoadDeferDuration != null) {
        Future.delayed(widget.serverLoadDeferDuration!, () {
          if (mounted) {
            _getThumbnailFromServer();
          }
        });
      } else {
        _getThumbnailFromServer();
      }
    }
  }

  void _getThumbnailFromServer() async {
    try {
      final thumbnail = await getThumbnailFromServer(widget.file!);
      if (mounted) {
        final imageProvider = Image.memory(thumbnail).image;
        _cacheAndRender(imageProvider);
      }
    } catch (e) {
      if (e is RequestCancelledError) {
        if (mounted) {
          _logger.info(
            "Thumbnail request was aborted although it is in view, will retry",
          );
          _reset();
          setState(() {});
        }
      } else {
        _logger.severe("Could not load image " + widget.file.toString(), e);
        _errorLoadingRemoteThumbnail = true;
      }
    }
  }

  void _cacheAndRender(ImageProvider<Object> imageProvider) {
    if (imageCache.currentSizeBytes > 256 * 1024 * 1024) {
      _logger.info("Clearing image cache");
      imageCache.clear();
      imageCache.clearLiveImages();
    }
    precacheImage(imageProvider, context).then((value) {
      if (mounted) {
        setState(() {
          _imageProvider = imageProvider;
          _hasLoadedThumbnail = true;
        });
      }
    });
  }

  void _reset() {
    _hasLoadedThumbnail = false;
    _isLoadingLocalThumbnail = false;
    _isLoadingRemoteThumbnail = false;
    _errorLoadingLocalThumbnail = false;
    _errorLoadingRemoteThumbnail = false;
    _imageProvider = null;
  }
}
