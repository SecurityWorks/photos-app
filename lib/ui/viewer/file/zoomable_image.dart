import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photos/core/cache/thumbnail_in_memory_cache.dart';
import "package:photos/core/configuration.dart";
import 'package:photos/core/constants.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/events/files_updated_event.dart';
import 'package:photos/events/local_photos_updated_event.dart';
import 'package:photos/models/file.dart';
import "package:photos/models/metadata/file_magic.dart";
import "package:photos/services/face_ml/face_detection/detection.dart";
import "package:photos/services/face_ml/face_ml_service.dart";
import "package:photos/services/file_magic_service.dart";
import 'package:photos/ui/common/loading_widget.dart';
import 'package:photos/utils/file_util.dart';
import 'package:photos/utils/image_util.dart';
import 'package:photos/utils/thumbnail_util.dart';
import "package:photos/utils/toast_util.dart";

class ZoomableImage extends StatefulWidget {
  final File photo;
  final Function(bool)? shouldDisableScroll;
  final String? tagPrefix;
  final Decoration? backgroundDecoration;
  final bool shouldCover;

  const ZoomableImage(
    this.photo, {
    Key? key,
    this.shouldDisableScroll,
    required this.tagPrefix,
    this.backgroundDecoration,
    this.shouldCover = false,
  }) : super(key: key);

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  late Logger _logger;
  late File _photo;
  ImageProvider? _imageProvider;
  bool _loadedSmallThumbnail = false;
  bool _loadingLargeThumbnail = false;
  bool _loadedLargeThumbnail = false;
  bool _loadingFinalImage = false;
  bool _loadedFinalImage = false;
  ValueChanged<PhotoViewScaleState>? _scaleStateChangedCallback;
  bool _isZooming = false;
  PhotoViewController _photoViewController = PhotoViewController();
  int? _thumbnailWidth;
  late int _currentUserID;

  @override
  void initState() {
    _photo = widget.photo;
    _logger = Logger("ZoomableImage_" + _photo.tag);
    debugPrint('initState for ${_photo.toString()}');
    _scaleStateChangedCallback = (value) {
      if (widget.shouldDisableScroll != null) {
        widget.shouldDisableScroll!(value != PhotoViewScaleState.initial);
      }
      _isZooming = value != PhotoViewScaleState.initial;
      debugPrint("isZooming = $_isZooming, currentState $value");
      // _logger.info('is reakky zooming $_isZooming with state $value');
    };
    _currentUserID = Configuration.instance.getUserID()!;
    super.initState();
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_photo.isRemoteFile) {
      _loadNetworkImage();
    } else {
      _loadLocalImage(context);
    }
    Widget content;

    if (_imageProvider != null) {
      content = PhotoViewGestureDetectorScope(
        axis: Axis.vertical,
        child: PhotoView(
          imageProvider: _imageProvider,
          controller: _photoViewController,
          scaleStateChangedCallback: _scaleStateChangedCallback,
          minScale: widget.shouldCover
              ? PhotoViewComputedScale.covered
              : PhotoViewComputedScale.contained,
          gaplessPlayback: true,
          heroAttributes: PhotoViewHeroAttributes(
            tag: widget.tagPrefix! + _photo.tag,
          ),
          backgroundDecoration: widget.backgroundDecoration as BoxDecoration?,
        ),
      );
    } else {
      content = const EnteLoadingWidget();
    }

    final GestureDragUpdateCallback? verticalDragCallback = _isZooming
        ? null
        : (d) => {
              if (!_isZooming && d.delta.dy > dragSensitivity)
                {Navigator.of(context).pop()}
            };
    return GestureDetector(
      onVerticalDragUpdate: verticalDragCallback,
      child: content,
    );
  }

  void _loadNetworkImage() {
    if (!_loadedSmallThumbnail && !_loadedFinalImage) {
      final cachedThumbnail = ThumbnailInMemoryLruCache.get(_photo);
      if (cachedThumbnail != null) {
        _imageProvider = Image.memory(cachedThumbnail).image;
        _loadedSmallThumbnail = true;
        _captureThumbnailDimensions(_imageProvider!);
      } else {
        getThumbnailFromServer(_photo).then((file) {
          final imageProvider = Image.memory(file).image;
          if (mounted) {
            precacheImage(imageProvider, context).then((value) {
              if (mounted) {
                setState(() {
                  _imageProvider = imageProvider;
                  _loadedSmallThumbnail = true;
                  _captureThumbnailDimensions(_imageProvider!);
                });
              }
            }).catchError((e) {
              _logger.severe("Could not load image " + _photo.toString());
              _loadedSmallThumbnail = true;
            });
          }
        });
      }
    }
    if (!_loadedFinalImage && !_loadingFinalImage) {
      _loadingFinalImage = true;
      getFileFromServer(_photo).then((file) {
        process_for_face_detection(file!).ignore();
        _onFinalImageLoaded(
          Image.file(
            file!,
            gaplessPlayback: true,
          ).image,
        );
      });
    }
  }

  void _loadLocalImage(BuildContext context) {
    if (!_loadedSmallThumbnail &&
        !_loadedLargeThumbnail &&
        !_loadedFinalImage) {
      final cachedThumbnail =
          ThumbnailInMemoryLruCache.get(_photo, thumbnailSmallSize);
      if (cachedThumbnail != null) {
        _imageProvider = Image.memory(cachedThumbnail).image;
        _loadedSmallThumbnail = true;
      }
    }

    if (!_loadingLargeThumbnail &&
        !_loadedLargeThumbnail &&
        !_loadedFinalImage) {
      _loadingLargeThumbnail = true;
      getThumbnailFromLocal(_photo, size: thumbnailLargeSize, quality: 100)
          .then((cachedThumbnail) {
        if (cachedThumbnail != null) {
          _onLargeThumbnailLoaded(Image.memory(cachedThumbnail).image, context);
        }
      });
    }

    if (!_loadingFinalImage && !_loadedFinalImage) {
      _loadingFinalImage = true;
      getFile(
        _photo,
        isOrigin: io.Platform.isIOS &&
            _isGIF(), // since on iOS GIFs playback only when origin-files are loaded
      ).then((file) {
        if (file != null && file.existsSync()) {
          process_for_face_detection(file).ignore();
          _onFinalImageLoaded(Image.file(file).image);
        } else {
          _logger.info("File was deleted " + _photo.toString());
          if (_photo.uploadedFileID != null) {
            _photo.localID = null;
            FilesDB.instance.update(_photo);
            _loadNetworkImage();
          } else {
            FilesDB.instance.deleteLocalFile(_photo);
            Bus.instance.fire(
              LocalPhotosUpdatedEvent(
                [_photo],
                type: EventType.deletedFromDevice,
                source: "zoomPreview",
              ),
            );
          }
        }
      });
    }
  }

  void _onLargeThumbnailLoaded(
    ImageProvider imageProvider,
    BuildContext context,
  ) {
    if (mounted && !_loadedFinalImage) {
      precacheImage(imageProvider, context).then((value) {
        if (mounted && !_loadedFinalImage) {
          setState(() {
            _imageProvider = imageProvider;
            _loadedLargeThumbnail = true;
          });
        }
      });
    }
  }

  void _onFinalImageLoaded(ImageProvider imageProvider) {
    if (mounted) {
      precacheImage(imageProvider, context).then((value) async {
        if (mounted) {
          await _updatePhotoViewController(imageProvider);
          setState(() {
            _imageProvider = imageProvider;
            _loadedFinalImage = true;
            _logger.info("Final image loaded");
          });
        }
      });
    }
  }

  Future<void> process_for_face_detection(io.File actualFile) async {
    try {
      // final thumbnail = await getThumbnail(actualFile);
      final List<FaceDetectionAbsolute> faceDetectionResults =
          await FaceMlService.instance
              .detectFaces(actualFile.readAsBytesSync());
      showToast(context, '${faceDetectionResults.length} faces detected');
      // throw Exception("Not implemented");
    } catch (e, s) {
      showToast(
        context,
        "Failed to process file ${e.toString()}",
      );
      _logger.warning("Error in processing file for face detection", e, s);
    }
  }

  Future<void> _captureThumbnailDimensions(ImageProvider imageProvider) async {
    final imageInfo = await getImageInfo(imageProvider);
    _thumbnailWidth = imageInfo.image.width;
  }

  Future<void> _updatePhotoViewController(ImageProvider imageProvider) async {
    if (_thumbnailWidth == null || _photoViewController.scale == null) {
      return;
    }
    final imageInfo = await getImageInfo(imageProvider);
    final scale = _photoViewController.scale! /
        (imageInfo.image.width / _thumbnailWidth!);
    final currentPosition = _photoViewController.value.position;
    final positionScaleFactor = 1 / scale;
    final newPosition = currentPosition.scale(
      positionScaleFactor,
      positionScaleFactor,
    );
    _photoViewController = PhotoViewController(
      initialPosition: newPosition,
      initialScale: scale,
    );
    _updateAspectRatioIfNeeded(imageInfo).ignore();
  }

  // Fallback logic to finish back fill and update aspect
  // ratio if needed.
  Future<void> _updateAspectRatioIfNeeded(ImageInfo imageInfo) async {
    if (_imageProvider != null &&
        widget.photo.isUploaded &&
        widget.photo.ownerID == _currentUserID) {
      final int h = imageInfo.image.height, w = imageInfo.image.width;
      if (h != 0 &&
          w != 0 &&
          (h != widget.photo.height || w != widget.photo.width)) {
        _logger.info('Updating aspect ratio for ${widget.photo} to $h:$w');

        await FileMagicService.instance.updatePublicMagicMetadata([
          widget.photo
        ], {
          heightKey: h,
          widthKey: w,
        });
      }
    }
  }

  bool _isGIF() => _photo.displayName.toLowerCase().endsWith(".gif");
}
