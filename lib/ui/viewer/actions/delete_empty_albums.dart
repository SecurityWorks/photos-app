import 'package:flutter/material.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/events/collection_updated_event.dart';
import "package:photos/generated/l10n.dart";
import 'package:photos/models/collection.dart';
import 'package:photos/models/file.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/ui/components/action_sheet_widget.dart';
import 'package:photos/ui/components/buttons/button_widget.dart';
import 'package:photos/ui/components/models/button_type.dart';

class DeleteEmptyAlbums extends StatefulWidget {
  const DeleteEmptyAlbums({Key? key}) : super(key: key);

  @override
  State<DeleteEmptyAlbums> createState() => _DeleteEmptyAlbumsState();
}

class _DeleteEmptyAlbumsState extends State<DeleteEmptyAlbums> {
  final ValueNotifier<String> _deleteProgress = ValueNotifier("");
  bool _isCancelled = false;

  @override
  void dispose() {
    _deleteProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 8, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ButtonWidget(
          buttonSize: ButtonSize.small,
          buttonType: ButtonType.secondary,
          labelText: S.of(context).deleteEmptyAlbums,
          icon: Icons.delete_sweep_outlined,
          shouldSurfaceExecutionStates: false,
          onTap: () async {
            await showActionSheet(
              context: context,
              isDismissible: true,
              buttons: [
                ButtonWidget(
                  labelText: S.of(context).yes,
                  buttonType: ButtonType.neutral,
                  buttonSize: ButtonSize.large,
                  shouldStickToDarkTheme: true,
                  shouldSurfaceExecutionStates: true,
                  progressStatus: _deleteProgress,
                  onTap: () async {
                    await _deleteEmptyAlbums();
                    if (!_isCancelled) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    Bus.instance.fire(
                      CollectionUpdatedEvent(
                        0,
                        <File>[],
                        "empty_albums_deleted",
                      ),
                    );
                    CollectionsService.instance.sync().ignore();
                    _isCancelled = false;
                  },
                ),
                ButtonWidget(
                  labelText: S.of(context).cancel,
                  buttonType: ButtonType.secondary,
                  buttonSize: ButtonSize.large,
                  shouldStickToDarkTheme: true,
                  onTap: () async {
                    _isCancelled = true;
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                )
              ],
              title: S.of(context).deleteEmptyAlbumsWithQuestionMark,
              body: S.of(context).deleteAlbumsDialogBody,
              actionSheetType: ActionSheetType.defaultActionSheet,
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteEmptyAlbums() async {
    final collections =
        await CollectionsService.instance.getCollectionsWithThumbnails();
    // remove collections which are not empty or can't be deleted
    collections.removeWhere(
      (element) =>
          element.thumbnail != null || !element.collection.type.canDelete,
    );
    int failedCount = 0;
    for (int i = 0; i < collections.length; i++) {
      if (mounted && !_isCancelled) {
        final String currentlyDeleting = (i + 1)
            .toString()
            .padLeft(collections.length.toString().length, '0');
        _deleteProgress.value =
            S.of(context).deleteProgress(currentlyDeleting, collections.length);
        try {
          await CollectionsService.instance.trashEmptyCollection(
            collections[i].collection,
            isBulkDelete: true,
          );
        } catch (_) {
          failedCount++;
        }
      }
    }
    if (failedCount > 0) {
      debugPrint("Delete ops failed for $failedCount collections");
    }
  }
}
