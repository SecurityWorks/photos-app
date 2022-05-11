import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/ente_theme_data.dart';
import 'package:photos/events/subscription_purchased_event.dart';
import 'package:photos/models/collection.dart';
import 'package:photos/models/galleryType.dart';
import 'package:photos/models/magic_metadata.dart';
import 'package:photos/models/selected_files.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/ui/create_collection_page.dart';
import 'package:photos/utils/delete_file_util.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/magic_util.dart';
import 'package:photos/utils/share_util.dart';
import 'package:photos/utils/toast_util.dart';

class GalleryOverlayWidget extends StatefulWidget {
  final GalleryType type;
  final SelectedFiles selectedFiles;
  final String path;
  final Collection collection;
  const GalleryOverlayWidget(this.type, this.selectedFiles,
      {this.path, this.collection, Key key})
      : super(key: key);

  @override
  State<GalleryOverlayWidget> createState() => _GalleryOverlayWidgetState();
}

class _GalleryOverlayWidgetState extends State<GalleryOverlayWidget> {
  StreamSubscription _userAuthEventSubscription;
  Function() _selectedFilesListener;
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
    bool filesAreSelected = widget.selectedFiles.files.isNotEmpty;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: filesAreSelected ? 108 : 0,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 75),
        opacity: filesAreSelected ? 1.0 : 0.0,
        curve: Curves.easeIn,
        child: IgnorePointer(
          ignoring: !filesAreSelected,
          child: OverlayWidget(
            widget.type,
            widget.selectedFiles,
            path: widget.path,
            collection: widget.collection,
          ),
        ),
      ),
    );
  }
}

class OverlayWidget extends StatefulWidget {
  final GalleryType type;
  final SelectedFiles selectedFiles;
  final String path;
  final Collection collection;

  const OverlayWidget(
    this.type,
    this.selectedFiles, {
    this.path,
    this.collection,
  });

  @override
  _OverlayWidgetState createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  final _logger = Logger("GalleryOverlay");
  StreamSubscription _userAuthEventSubscription;
  Function() _selectedFilesListener;
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
    return Container(
      color: Colors.transparent,
      child: ListView(
        //ListView for animation to work without render overflow
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  color: Theme.of(context)
                      .colorScheme
                      .frostyBlurBackdropFilterColor
                      .withOpacity(0.5),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(13, 13, 0, 13),
                        child: Text(
                          widget.selectedFiles.files.length.toString() +
                              ' selected',
                          style: Theme.of(context).textTheme.subtitle2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black //same for both themes
                              ),
                        ),
                      ),
                      Row(
                        children: _getActions(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      //height: 32,
                      width: 86,
                      color: Theme.of(context)
                          .colorScheme
                          .cancelSelectedButtonColor
                          .withOpacity(0.5),
                      child: Center(
                        child: Text('Cancel',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                .copyWith(
                                  color: Colors.white, //same for both themes
                                )),
                      ),
                    ),
                  ),
                  onTap: _clearSelectedFiles,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearSelectedFiles() {
    widget.selectedFiles.clearAll();
  }

  Future<void> _createAlbum() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.bottomToTop,
            child: CreateCollectionPage(
              widget.selectedFiles,
              null,
            )));
  }

  Future<void> _moveFiles() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.bottomToTop,
            child: CreateCollectionPage(
              widget.selectedFiles,
              null,
              actionType: CollectionActionType.moveFiles,
            )));
  }

  List<Widget> _getActions(BuildContext context) {
    List<Widget> actions = <Widget>[];
    if (widget.type == GalleryType.trash) {
      _addTrashAction(actions);
      return actions;
    }
    // skip add button for incoming collection till this feature is implemented
    if (Configuration.instance.hasConfiguredAccount() &&
        widget.type != GalleryType.shared_collection) {
      String msg = "add";
      IconData iconData = Platform.isAndroid ? Icons.add : CupertinoIcons.add;
      // show upload icon instead of add for files selected in local gallery
      if (widget.type == GalleryType.local_folder) {
        msg = "upload";
        iconData = Platform.isAndroid
            ? Icons.cloud_upload
            : CupertinoIcons.cloud_upload;
      }
      actions.add(
        Tooltip(
          message: msg,
          child: IconButton(
            color: Colors.black, //same for both themes
            icon: Icon(iconData),
            onPressed: () {
              _createAlbum();
            },
          ),
        ),
      );
    }
    if (Configuration.instance.hasConfiguredAccount() &&
        widget.type == GalleryType.owned_collection &&
        widget.collection.type != CollectionType.favorites) {
      actions.add(
        Tooltip(
          message: "move",
          child: IconButton(
            color: Colors.black, //same for both themes
            icon: Icon(Platform.isAndroid
                ? Icons.arrow_forward
                : CupertinoIcons.arrow_right),
            onPressed: () {
              _moveFiles();
            },
          ),
        ),
      );
    }
    actions.add(
      Tooltip(
        message: "share",
        child: IconButton(
          color: Colors.black, //same for both themes
          key: shareButtonKey,
          icon: Icon(Platform.isAndroid ? Icons.share : CupertinoIcons.share),
          onPressed: () {
            _shareSelected(context);
          },
        ),
      ),
    );
    if (widget.type == GalleryType.homepage ||
        widget.type == GalleryType.archive ||
        widget.type == GalleryType.local_folder) {
      actions.add(
        Tooltip(
          message: "delete",
          child: IconButton(
            color: Colors.black, //same for both themes
            icon:
                Icon(Platform.isAndroid ? Icons.delete : CupertinoIcons.delete),
            onPressed: () {
              _showDeleteSheet(context);
            },
          ),
        ),
      );
    } else if (widget.type == GalleryType.owned_collection) {
      if (widget.collection.type == CollectionType.folder) {
        actions.add(
          Tooltip(
            message: "delete",
            child: IconButton(
              color: Colors.black, //same for both themes
              icon: Icon(
                Platform.isAndroid ? Icons.delete : CupertinoIcons.delete,
              ),
              onPressed: () {
                _showDeleteSheet(context);
              },
            ),
          ),
        );
      } else {
        actions.add(
          Tooltip(
            message: "remove",
            child: IconButton(
              color: Colors.black, //same for both themes
              icon: Icon(
                Icons.remove_circle_rounded,
              ),
              onPressed: () {
                _showRemoveFromCollectionSheet(context);
              },
            ),
          ),
        );
      }
    }

    if (widget.type == GalleryType.homepage ||
        widget.type == GalleryType.archive) {
      bool showArchive = widget.type == GalleryType.homepage;
      actions.add(Tooltip(
        message: showArchive ? "archive" : "unarchive",
        child: IconButton(
          color: Colors.black, //same for both themes
          icon: Icon(
            showArchive ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            _handleVisibilityChangeRequest(
                context, showArchive ? kVisibilityArchive : kVisibilityVisible);
          },
        ),
      ));
    }
    return actions;
  }

  void _addTrashAction(List<Widget> actions) {
    actions.add(Tooltip(
      message: "restore",
      child: IconButton(
        color: Colors.black, //same for both themes
        icon: Icon(
          Icons.restore,
          color: Theme.of(context).colorScheme.inverseIconColor,
        ),
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: CreateCollectionPage(
                    widget.selectedFiles,
                    null,
                    actionType: CollectionActionType.restoreFiles,
                  )));
        },
      ),
    ));
    actions.add(
      Tooltip(
        message: "delete permanently",
        child: IconButton(
          color: Colors.black, //same for both themes
          icon: Icon(
            Icons.delete_forever,
          ),
          onPressed: () async {
            if (await deleteFromTrash(
                context, widget.selectedFiles.files.toList())) {
              _clearSelectedFiles();
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleVisibilityChangeRequest(
      BuildContext context, int newVisibility) async {
    try {
      await changeVisibility(
          context, widget.selectedFiles.files.toList(), newVisibility);
    } catch (e, s) {
      _logger.severe("failed to update file visibility", e, s);
      await showGenericErrorDialog(context);
    } finally {
      _clearSelectedFiles();
    }
  }

  void _shareSelected(BuildContext context) {
    share(context, widget.selectedFiles.files.toList(),
        shareButtonKey: shareButtonKey);
  }

  void _showDeleteSheet(BuildContext context) {
    final count = widget.selectedFiles.files.length;
    bool containsUploadedFile = false, containsLocalFile = false;
    for (final file in widget.selectedFiles.files) {
      if (file.uploadedFileID != null) {
        containsUploadedFile = true;
      }
      if (file.localID != null) {
        containsLocalFile = true;
      }
    }
    final actions = <Widget>[];
    if (containsUploadedFile && containsLocalFile) {
      actions.add(CupertinoActionSheetAction(
        child: Text("device"),
        isDestructiveAction: true,
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop();
          await deleteFilesOnDeviceOnly(
              context, widget.selectedFiles.files.toList());
          _clearSelectedFiles();
          showToast("files deleted from device");
        },
      ));
      actions.add(CupertinoActionSheetAction(
        child: Text("ente"),
        isDestructiveAction: true,
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop();
          await deleteFilesFromRemoteOnly(
              context, widget.selectedFiles.files.toList());
          _clearSelectedFiles();
          showShortToast("moved to trash");
        },
      ));
      actions.add(CupertinoActionSheetAction(
        child: Text("everywhere"),
        isDestructiveAction: true,
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop();
          await deleteFilesFromEverywhere(
              context, widget.selectedFiles.files.toList());
          _clearSelectedFiles();
        },
      ));
    } else {
      actions.add(CupertinoActionSheetAction(
        child: Text("delete"),
        isDestructiveAction: true,
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop();
          await deleteFilesFromEverywhere(
              context, widget.selectedFiles.files.toList());
          _clearSelectedFiles();
        },
      ));
    }
    final action = CupertinoActionSheet(
      title: Text("delete " +
          count.toString() +
          " file" +
          (count == 1 ? "" : "s") +
          (containsUploadedFile && containsLocalFile ? " from" : "?")),
      actions: actions,
      cancelButton: CupertinoActionSheetAction(
        child: Text("cancel"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (_) => action);
  }

  void _showRemoveFromCollectionSheet(BuildContext context) {
    final count = widget.selectedFiles.files.length;
    final action = CupertinoActionSheet(
      title: Text("remove " +
          count.toString() +
          " file" +
          (count == 1 ? "" : "s") +
          " from " +
          widget.collection.name +
          "?"),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("remove"),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            final dialog = createProgressDialog(context, "removing files...");
            await dialog.show();
            try {
              await CollectionsService.instance.removeFromCollection(
                  widget.collection.id, widget.selectedFiles.files.toList());
              await dialog.hide();
              widget.selectedFiles.clearAll();
            } catch (e, s) {
              _logger.severe(e, s);
              await dialog.hide();
              showGenericErrorDialog(context);
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("cancel"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (_) => action);
  }
}
