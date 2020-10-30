import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/events/user_authenticated_event.dart';
import 'package:photos/models/collection.dart';
import 'package:photos/models/selected_files.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/ui/create_collection_page.dart';
import 'package:photos/ui/email_entry_page.dart';
import 'package:photos/ui/passphrase_entry_page.dart';
import 'package:photos/ui/passphrase_reentry_page.dart';
import 'package:photos/ui/settings_page.dart';
import 'package:photos/ui/share_folder_widget.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/file_util.dart';
import 'package:photos/utils/share_util.dart';

enum GalleryAppBarType {
  homepage,
  local_folder,
  shared_collection,
  collection,
  search_results,
}

class GalleryAppBarWidget extends StatefulWidget
    implements PreferredSizeWidget {
  final GalleryAppBarType type;
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

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}

class _GalleryAppBarWidgetState extends State<GalleryAppBarWidget> {
  final _logger = Logger("GalleryAppBar");

  StreamSubscription _userAuthEventSubscription;

  @override
  void initState() {
    widget.selectedFiles.addListener(() {
      setState(() {});
    });
    _userAuthEventSubscription =
        Bus.instance.on<UserAuthenticatedEvent>().listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _userAuthEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedFiles.files.isEmpty) {
      return AppBar(
        title: Text(widget.title),
        actions: _getDefaultActions(context),
      );
    }

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          _clearSelectedFiles();
        },
      ),
      title: Text(widget.selectedFiles.files.length.toString()),
      actions: _getActions(context),
    );
  }

  List<Widget> _getDefaultActions(BuildContext context) {
    List<Widget> actions = List<Widget>();
    if (Configuration.instance.hasConfiguredAccount()) {
      if (widget.type == GalleryAppBarType.homepage) {
        actions.add(IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return SettingsPage();
                },
              ),
            );
          },
        ));
      } else if (widget.type == GalleryAppBarType.local_folder ||
          widget.type == GalleryAppBarType.collection) {
        actions.add(IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () {
            _showShareCollectionDialog();
          },
        ));
      }
    } else {
      actions.add(IconButton(
        icon: Icon(Icons.sync_disabled),
        onPressed: () {
          var page;
          if (Configuration.instance.getToken() == null) {
            page = EmailEntryPage();
          } else {
            // No key
            if (Configuration.instance.getKey() == null) {
              // Yet to decrypt the key
              page = PassphraseReentryPage();
            } else {
              // Never had a key
              page = PassphraseEntryPage();
            }
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return page;
              },
            ),
          );
        },
      ));
    }
    return actions;
  }

  Future<void> _showShareCollectionDialog() async {
    var collection = widget.collection;
    if (collection == null) {
      if (widget.type == GalleryAppBarType.local_folder) {
        collection =
            CollectionsService.instance.getCollectionForPath(widget.path);
        if (collection == null) {
          final dialog = createProgressDialog(context, "Please wait...");
          await dialog.show();
          collection =
              await CollectionsService.instance.getOrCreateForPath(widget.path);
          await dialog.hide();
        }
      } else {
        throw Exception(
            "Cannot create a collection of type" + widget.type.toString());
      }
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ShareFolderWidget(collection);
      },
    );
  }

  Future<void> _createAlbum() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.bottomToTop,
            child: CreateCollectionPage(
              widget.selectedFiles,
            )));
  }

  List<Widget> _getActions(BuildContext context) {
    List<Widget> actions = List<Widget>();
    actions.add(IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        _createAlbum();
      },
    ));
    actions.add(IconButton(
      icon: Icon(Icons.share),
      onPressed: () {
        _shareSelected(context);
      },
    ));
    if (widget.type == GalleryAppBarType.homepage ||
        widget.type == GalleryAppBarType.local_folder) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _showDeleteSheet(context);
        },
      ));
    } else if (widget.type == GalleryAppBarType.collection) {
      actions.add(PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.remove_circle),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  Text("Remove"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  Icon(Icons.delete),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  Text("Delete"),
                ],
              ),
            )
          ];
        },
        onSelected: (value) {
          if (value == 1) {
            _showRemoveFromCollectionSheet(context);
          } else if (value == 2) {
            _showDeleteSheet(context);
          }
        },
      ));
    }
    return actions;
  }

  void _shareSelected(BuildContext context) {
    shareMultiple(context, widget.selectedFiles.files.toList());
  }

  void _showRemoveFromCollectionSheet(BuildContext context) {
    final action = CupertinoActionSheet(
      title: Text("Remove " +
          widget.selectedFiles.files.length.toString() +
          " files from " +
          widget.collection.name +
          "?"),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Remove"),
          isDestructiveAction: true,
          onPressed: () async {
            final dialog = createProgressDialog(context, "Removing files...");
            await dialog.show();
            try {
              CollectionsService.instance.removeFromCollection(
                  widget.collection.id, widget.selectedFiles.files.toList());
              await dialog.hide();
              widget.selectedFiles.clearAll();
              Navigator.of(context).pop();
            } catch (e, s) {
              _logger.severe(e, s);
              await dialog.hide();
              Navigator.of(context).pop();
              showGenericErrorDialog(context);
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  void _showDeleteSheet(BuildContext context) {
    final action = CupertinoActionSheet(
      title: Text("Permanently delete " +
          widget.selectedFiles.files.length.toString() +
          " files?"),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Delete"),
          isDestructiveAction: true,
          onPressed: () async {
            await _deleteSelected();
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  _deleteSelected() async {
    Navigator.of(context, rootNavigator: true).pop();
    final dialog = createProgressDialog(context, "Deleting...");
    await dialog.show();
    await deleteFiles(widget.selectedFiles.files.toList());
    _clearSelectedFiles();
    await dialog.hide();
  }

  void _clearSelectedFiles() {
    widget.selectedFiles.clearAll();
  }
}
