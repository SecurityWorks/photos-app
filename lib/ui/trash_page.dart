import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/trash_db.dart';
import 'package:photos/events/files_updated_event.dart';
import 'package:photos/events/force_reload_trash_page_event.dart';
import 'package:photos/models/galleryType.dart';
import 'package:photos/models/selected_files.dart';
import 'package:photos/ui/common/bottomShadow.dart';
import 'package:photos/ui/gallery.dart';
import 'package:photos/ui/gallery_app_bar_widget.dart';
import 'package:photos/ui/gallery_overlay_widget.dart';
import 'package:photos/utils/delete_file_util.dart';

class TrashPage extends StatefulWidget {
  final String tagPrefix;
  final GalleryType appBarType;
  final GalleryType overlayType;
  final _selectedFiles = SelectedFiles();
  TrashPage(
      {this.tagPrefix = "trash_page",
      this.appBarType = GalleryType.trash,
      this.overlayType = GalleryType.trash,
      Key key})
      : super(key: key);

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  Function() _selectedFilesListener;
  @override
  void initState() {
    _selectedFilesListener = () {
      setState(() {});
    };
    widget._selectedFiles.addListener(_selectedFilesListener);
    super.initState();
  }

  @override
  void dispose() {
    widget._selectedFiles.removeListener(_selectedFilesListener);
    super.dispose();
  }

  @override
  Widget build(Object context) {
    bool filesAreSelected = widget._selectedFiles.files.isNotEmpty;

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
        Bus.instance.on<ForceReloadTrashPageEvent>(),
      ],
      tagPrefix: widget.tagPrefix,
      selectedFiles: widget._selectedFiles,
      header: _headerWidget(),
      initialFiles: null,
      footer: const SizedBox(height: 32),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: GalleryAppBarWidget(
          widget.appBarType,
          "Trash",
          widget._selectedFiles,
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          gallery,
          BottomShadowWidget(
            offsetDy: 20,
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: filesAreSelected ? 0 : 80,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 100),
              opacity: filesAreSelected ? 0.0 : 1.0,
              curve: Curves.easeIn,
              child: IgnorePointer(
                ignoring: filesAreSelected,
                child: SafeArea(
                    minimum: EdgeInsets.only(bottom: 6),
                    child: BottomButtonsWidget()),
              ),
            ),
          ),
          GalleryOverlayWidget(
            widget.overlayType,
            widget._selectedFiles,
          )
        ],
      ),
    );
  }

  Widget _headerWidget() {
    return FutureBuilder<int>(
      future: TrashDB.instance.count(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data > 0) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Items show the number the days remaining before permanent deletion',
              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class BottomButtonsWidget extends StatelessWidget {
  const BottomButtonsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 101, 101, 0.2),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16),
                    child: Text(
                      'Delete All',
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: Color.fromRGBO(255, 101, 101, 1),
                          ),
                    ),
                  ),
                ),
              ),
            ),
            onTap: () async {
              await emptyTrash(context);
            },
          ),
        ),
      ],
    );
  }
}
