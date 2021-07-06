import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/models/file.dart';
import 'package:photos/models/file_type.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/utils/date_time_util.dart';

class FileInfoWidget extends StatelessWidget {
  final File file;
  final AssetEntity entity;
  final int fileSize;

  const FileInfoWidget(
    this.file,
    this.entity,
    this.fileSize, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[
      Row(
        children: [
          Icon(Icons.calendar_today_outlined),
          Padding(padding: EdgeInsets.all(4)),
          Text(getFormattedTime(
              DateTime.fromMicrosecondsSinceEpoch(file.creationTime))),
        ],
      ),
      Padding(padding: EdgeInsets.all(4)),
      Row(
        children: [
          Icon(Icons.folder_outlined),
          Padding(padding: EdgeInsets.all(4)),
          Text(file.deviceFolder ??
              CollectionsService.instance
                  .getCollectionByID(file.collectionID)
                  .name),
        ],
      ),
      Padding(padding: EdgeInsets.all(4)),
    ];
    if (file.localID != null) {
      items.add(Row(
        children: [
          Icon(Icons.sd_storage_outlined),
          Padding(padding: EdgeInsets.all(4)),
          Text((fileSize / (1024 * 1024)).toStringAsFixed(2) + " MB"),
        ],
      ));
      items.add(
        Padding(padding: EdgeInsets.all(4)),
      );
      if (file.fileType == FileType.image) {
        items.add(Row(
          children: [
            Icon(Icons.photo_size_select_actual_outlined),
            Padding(padding: EdgeInsets.all(4)),
            Text(entity.width.toString() + " x " + entity.height.toString()),
          ],
        ));
      } else {
        items.add(Row(
          children: [
            Icon(Icons.timer_outlined),
            Padding(padding: EdgeInsets.all(4)),
            Text(entity.videoDuration.toString().split(".")[0]),
          ],
        ));
      }
      items.add(
        Padding(padding: EdgeInsets.all(4)),
      );
    }
    if (file.uploadedFileID != null) {
      items.add(Row(
        children: [
          Icon(Icons.cloud_upload_outlined),
          Padding(padding: EdgeInsets.all(4)),
          Text(getFormattedTime(
              DateTime.fromMicrosecondsSinceEpoch(file.updationTime))),
        ],
      ));
    }
    return AlertDialog(
      title: Text(file.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: items,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('ok'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
      ],
    );
  }
}
