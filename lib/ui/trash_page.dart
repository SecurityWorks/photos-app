import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/trash_db.dart';
import 'package:photos/events/files_updated_event.dart';
import 'package:photos/models/file_load_result.dart';
import 'package:photos/models/selected_files.dart';

import 'gallery.dart';
import 'gallery_app_bar_widget.dart';

class TrashPage extends StatelessWidget {
  final String tagPrefix;
  final GalleryAppBarType appBarType;
  final _selectedFiles = SelectedFiles();

  TrashPage(
      {this.tagPrefix = "trash_page",
      this.appBarType = GalleryAppBarType.trash,
      Key key})
      : super(key: key);

  @override
  Widget build(Object context) {
    final gallery = Gallery(
        asyncLoader: (creationStartTime, creationEndTime, {limit, asc}) {
          return TrashDB.instance.getTrashedFiles(
              creationStartTime, creationEndTime,
              limit: limit, asc: asc);
        },
        reloadEvent: Bus.instance.on<FilesUpdatedEvent>().where(
              (event) =>
                  event.updatedFiles.firstWhere(
                      (element) => element.uploadedFileID != null,
                      orElse: () => null) !=
                  null,
            ),
        forceReloadEvents: [
          Bus.instance.on<FilesUpdatedEvent>().where(
                (event) =>
                    event.updatedFiles.firstWhere(
                        (element) => element.uploadedFileID != null,
                        orElse: () => null) !=
                    null,
              ),
        ],
        tagPrefix: tagPrefix,
        selectedFiles: _selectedFiles,
        initialFiles: null,
        footer: footerWidget());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: GalleryAppBarWidget(
          appBarType,
          "trash",
          _selectedFiles,
        ),
      ),
      body: gallery,
    );
  }

  StatefulWidget footerWidget() {
    return FutureBuilder<FileLoadResult>(
        future: TrashDB.instance
            .getTrashedFiles(0, DateTime.now().microsecondsSinceEpoch),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.files.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'memories shows the number the days after which they will be permanently deleted.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
