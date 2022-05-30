import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/events/subscription_purchased_event.dart';
import 'package:photos/models/collection.dart';
import 'package:photos/models/galleryType.dart';
import 'package:photos/models/magic_metadata.dart';
import 'package:photos/models/selected_files.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/ui/rename_dialog.dart';
import 'package:photos/ui/share_collection_widget.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/magic_util.dart';

class GalleryAppBarWidget extends StatefulWidget {
  final GalleryType type;
  final String title;
  final SelectedFiles selectedFiles;
  final String path;
  final Collection collection;

  GalleryAppBarWidget(
    this.type,
    this.title,
    this.selectedFiles, {
    this.path,
    this.collection,
  });

  @override
  _GalleryAppBarWidgetState createState() => _GalleryAppBarWidgetState();
}

class _GalleryAppBarWidgetState extends State<GalleryAppBarWidget> {
  final _logger = Logger("GalleryAppBar");
  StreamSubscription _userAuthEventSubscription;
  Function() _selectedFilesListener;
  String _appBarTitle;
  final GlobalKey shareButtonKey = GlobalKey();
  @override
  void initState() {
    _selectedFilesListener = () {
      setState(() {});
    };
    widget.selectedFiles.addListener(_selectedFilesListener);
    _userAuthEventSubscription =
        Bus.instance.on<SubscriptionPurchasedEvent>().listen((event) {
      setState(() {});
    });
    _appBarTitle = widget.title;
    super.initState();
  }

  @override
  void dispose() {
    _userAuthEventSubscription.cancel();
    widget.selectedFiles.removeListener(_selectedFilesListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.selectedFiles.files.isEmpty) {
    return AppBar(
      backgroundColor:
          widget.type == GalleryType.homepage ? Color(0x00000000) : null,
      elevation: 0,
      centerTitle: false,
      title: widget.type == GalleryType.homepage
          ? const SizedBox.shrink()
          : TextButton(
              child: Text(
                _appBarTitle,
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(fontSize: 16),
              ),
              onPressed: () => _renameAlbum(context),
            ),
      actions: _getDefaultActions(context),
    );
  }

  Future<dynamic> _renameAlbum(BuildContext context) async {
    if (widget.type != GalleryType.owned_collection) {
      return;
    }
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return RenameDialog(_appBarTitle, 'album');
      },
      barrierColor: Colors.black.withOpacity(0.85),
    );
    // indicates user cancelled the rename request
    if (result == null || result.trim() == _appBarTitle.trim()) {
      return;
    }

    final dialog = createProgressDialog(context, "changing name...");
    await dialog.show();
    try {
      await CollectionsService.instance.rename(widget.collection, result);
      await dialog.hide();
      if (mounted) {
        _appBarTitle = result;
        setState(() {});
      }
    } catch (e) {
      await dialog.hide();
      showGenericErrorDialog(context);
    }
  }

  List<Widget> _getDefaultActions(BuildContext context) {
    List<Widget> actions = <Widget>[];
    if (Configuration.instance.hasConfiguredAccount() &&
        widget.selectedFiles.files.isEmpty &&
        (widget.type == GalleryType.local_folder ||
            widget.type == GalleryType.owned_collection)) {
      actions.add(
        Tooltip(
          message: "Share",
          child: IconButton(
            icon: Icon(Icons.adaptive.share),
            onPressed: () {
              _showShareCollectionDialog();
            },
          ),
        ),
      );
    }
    if (widget.type == GalleryType.owned_collection) {
      actions.add(PopupMenuButton(
        itemBuilder: (context) {
          final List<PopupMenuItem> items = [];
          if (widget.collection.type == CollectionType.album) {
            items.add(
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.edit),
                    Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    Text("Rename"),
                  ],
                ),
              ),
            );
          }
          bool isArchived = widget.collection.isArchived();
          items.add(
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  Icon(isArchived ? Icons.visibility : Icons.visibility_off),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  Text(isArchived ? "Unhide" : "Hide"),
                ],
              ),
            ),
          );
          return items;
        },
        onSelected: (value) async {
          if (value == 1) {
            await _renameAlbum(context);
          }
          if (value == 2) {
            await changeCollectionVisibility(
                context,
                widget.collection,
                widget.collection.isArchived()
                    ? kVisibilityVisible
                    : kVisibilityArchive);
          }
        },
      ));
    }
    return actions;
  }

  Future<void> _showShareCollectionDialog() async {
    var collection = widget.collection;
    final dialog = createProgressDialog(context, "Please wait...");
    await dialog.show();
    try {
      if (collection == null) {
        if (widget.type == GalleryType.local_folder) {
          collection =
              await CollectionsService.instance.getOrCreateForPath(widget.path);
        } else {
          throw Exception(
              "Cannot create a collection of type" + widget.type.toString());
        }
      } else {
        final sharees =
            await CollectionsService.instance.getSharees(collection.id);
        collection = collection.copyWith(sharees: sharees);
      }
      await dialog.hide();
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SharingDialog(collection);
        },
      );
    } catch (e, s) {
      _logger.severe(e, s);
      await dialog.hide();
      showGenericErrorDialog(context);
    }
  }
}
