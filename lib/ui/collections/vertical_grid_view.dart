import "dart:math";

import 'package:flutter/material.dart';
import "package:photos/models/collection.dart";
import "package:photos/ui/collections/album/row_item.dart";

class CollectionVerticalGridView extends StatelessWidget {
  final List<Collection>? collections;
  final Widget? appTitle;
  final String tag;
  static const maxThumbnailWidth = 160.0;

  // This includes the name, count and padding below the thumbnail
  static const albumBottomInfoHeight = 21.0;
  static const double horizontalPadding = 20;
  static const double gapBetweenAlbumsInRow = 16.0;

  const CollectionVerticalGridView(
    this.collections, {
    this.appTitle,
    this.tag = "",
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: appTitle,
      ),
      body: SafeArea(
        child: _getBody(context),
      ),
    );
  }

  Widget _getBody(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final int albumsCountInOneRow =
        max(screenWidth ~/ (maxThumbnailWidth + horizontalPadding), 2);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: GridView.builder(
          physics: const ScrollPhysics(),
          itemBuilder: (context, index) {
            return AlbumRowItemWidget(
              collections![index],
              maxThumbnailWidth,
              tag: tag,
            );
          },
          itemCount: collections!.length,
          // To include the + button
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: albumsCountInOneRow,
            crossAxisSpacing: gapBetweenAlbumsInRow,
            childAspectRatio:
                maxThumbnailWidth / (maxThumbnailWidth + albumBottomInfoHeight),
          ),
        ),
      ),
    );
  }
}
