// @dart=2.9

import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photos/ente_theme_data.dart';
import "package:photos/models/file.dart";
import 'package:photos/ui/viewer/file/exif_info_dialog.dart';
import 'package:photos/utils/toast_util.dart';

enum Status {
  loading,
  exifIsAvailable,
  noExif,
}

class RawExifButton extends StatelessWidget {
  final File file;
  final Map<String, IfdTag> exif;
  const RawExifButton(this.exif, this.file, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Status exifStatus = Status.loading;
    if (exif == null) {
      exifStatus = Status.loading;
    } else if (exif.isNotEmpty) {
      exifStatus = Status.exifIsAvailable;
    } else {
      exifStatus = Status.noExif;
    }
    return GestureDetector(
      onTap:
          exifStatus == Status.loading || exifStatus == Status.exifIsAvailable
              ? () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ExifInfoDialog(file);
                    },
                    barrierColor: Colors.black87,
                  );
                }
              : exifStatus == Status.noExif
                  ? () {
                      showShortToast(context, "This image has no exif data");
                    }
                  : null,
      child: Container(
        height: 40,
        width: 140,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .inverseBackgroundColor
              .withOpacity(0.12),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Center(
          child: exifStatus == Status.loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CupertinoActivityIndicator(
                      radius: 8,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('EXIF')
                  ],
                )
              : exifStatus == Status.exifIsAvailable
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.feed_outlined),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Raw EXIF'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.feed_outlined),
                        SizedBox(
                          width: 8,
                        ),
                        Text('No EXIF'),
                      ],
                    ),
        ),
      ),
    );
  }
}
