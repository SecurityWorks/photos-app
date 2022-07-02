import 'package:flutter/material.dart';
import 'package:photos/models/trash_file.dart';
import 'package:photos/utils/date_time_util.dart';

class ThumbnailPlaceHolder extends StatelessWidget {
  final Color backgroundColor;

  const ThumbnailPlaceHolder(this.backgroundColor, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("building placeHolder for thumbnail");
    return Container(
      alignment: Alignment.center,
      color: backgroundColor,
    );
  }
}

class UnSyncedIcon extends StatelessWidget {
  const UnSyncedIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.75, 1],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 4),
          child: Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}

class VideoOverlayIcon extends StatelessWidget {
  const VideoOverlayIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Icon(
        Icons.play_circle_outline,
        size: 40,
        color: Colors.white70,
      ),
    );
  }
}

class LivePhotoOverlayIcon extends StatelessWidget {
  const LivePhotoOverlayIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 4),
        child: Icon(
          Icons.wb_sunny_outlined,
          size: 14,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}

class TrashedFileOverlayText extends StatelessWidget {
  final TrashFile file;

  const TrashedFileOverlayText(this.file, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.33), Colors.transparent],
        ),
      ),
      child: Text(
        daysLeft(file.deleteBy),
        style: Theme.of(context)
            .textTheme
            .subtitle2
            .copyWith(color: Colors.white), //same for both themes
      ),
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 5),
    );
  }
}

class ArchiveOverlayIcon extends StatelessWidget {
  const ArchiveOverlayIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: Icon(
          Icons.visibility_off,
          size: 24,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}
