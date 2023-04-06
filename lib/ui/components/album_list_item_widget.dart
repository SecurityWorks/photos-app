import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:photos/db/files_db.dart';
import "package:photos/generated/l10n.dart";
import 'package:photos/models/collection_items.dart';
import 'package:photos/theme/ente_theme.dart';
import 'package:photos/ui/viewer/file/no_thumbnail_widget.dart';
import 'package:photos/ui/viewer/file/thumbnail_widget.dart';

///https://www.figma.com/file/SYtMyLBs5SAOkTbfMMzhqt/ente-Visual-Design?node-id=7480%3A33462&t=H5AvR79OYDnB9ekw-4
class AlbumListItemWidget extends StatelessWidget {
  final CollectionWithThumbnail item;

  const AlbumListItemWidget(
    this.item, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = getEnteTextTheme(context);
    final colorScheme = getEnteColorScheme(context);
    const sideOfThumbnail = 60.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(4),
                  ),
                  child: SizedBox(
                    height: sideOfThumbnail,
                    width: sideOfThumbnail,
                    child: item.thumbnail != null
                        ? ThumbnailWidget(
                            item.thumbnail,
                            showFavForAlbumOnly: true,
                            shouldShowOwnerAvatar: false,
                          )
                        : const NoThumbnailWidget(
                            addBorder: false,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.collection.collectionName),
                      FutureBuilder<int>(
                        future: FilesDB.instance.collectionFileCount(
                          item.collection.id,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              S.of(context).memoryCount(snapshot.data!),
                              style: textTheme.small.copyWith(
                                color: colorScheme.textMuted,
                              ),
                            );
                          } else {
                            if (snapshot.hasError) {
                              Logger("AlbumListItemWidget").severe(
                                "Failed to fetch file count of collection",
                                snapshot.error,
                              );
                            }
                            return Text(
                              "",
                              style: textTheme.small.copyWith(
                                color: colorScheme.textMuted,
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: colorScheme.strokeFainter,
                  ),
                ),
                height: sideOfThumbnail,
                width: constraints.maxWidth,
              ),
            ),
          ],
        );
      },
    );
  }
}
