import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/ente_theme_data.dart';
import 'package:photos/events/collection_updated_event.dart';
import 'package:photos/events/local_photos_updated_event.dart';
import 'package:photos/events/tab_changed_event.dart';
import 'package:photos/events/user_logged_out_event.dart';
import 'package:photos/models/collection_items.dart';
import 'package:photos/models/galleryType.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/ui/collection_page.dart';
import 'package:photos/ui/collections_gallery_widget.dart';
import 'package:photos/ui/common/gradientButton.dart';
import 'package:photos/ui/loading_widget.dart';
import 'package:photos/ui/thumbnail_widget.dart';
import 'package:photos/utils/navigation_util.dart';
import 'package:photos/utils/share_util.dart';
import 'package:photos/utils/toast_util.dart';

class SharedCollectionGallery extends StatefulWidget {
  const SharedCollectionGallery({Key key}) : super(key: key);

  @override
  _SharedCollectionGalleryState createState() =>
      _SharedCollectionGalleryState();
}

class _SharedCollectionGalleryState extends State<SharedCollectionGallery>
    with AutomaticKeepAliveClientMixin {
  final Logger _logger = Logger("SharedCollectionGallery");
  StreamSubscription<LocalPhotosUpdatedEvent> _localFilesSubscription;
  StreamSubscription<CollectionUpdatedEvent> _collectionUpdatesSubscription;
  StreamSubscription<UserLoggedOutEvent> _loggedOutEvent;

  @override
  void initState() {
    _localFilesSubscription =
        Bus.instance.on<LocalPhotosUpdatedEvent>().listen((event) {
      _logger.info("Files updated");
      setState(() {});
    });
    _collectionUpdatesSubscription =
        Bus.instance.on<CollectionUpdatedEvent>().listen((event) {
      setState(() {});
    });
    _loggedOutEvent = Bus.instance.on<UserLoggedOutEvent>().listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<SharedCollections>(
      future:
          Future.value(CollectionsService.instance.getLatestCollectionFiles())
              .then((files) async {
        final List<CollectionWithThumbnail> outgoing = [];
        final List<CollectionWithThumbnail> incoming = [];
        for (final file in files) {
          final c =
              CollectionsService.instance.getCollectionByID(file.collectionID);
          if (c.owner.id == Configuration.instance.getUserID()) {
            if (c.sharees.isNotEmpty || c.publicURLs.isNotEmpty) {
              outgoing.add(
                CollectionWithThumbnail(
                  c,
                  file,
                ),
              );
            }
          } else {
            incoming.add(
              CollectionWithThumbnail(
                c,
                file,
              ),
            );
          }
        }
        outgoing.sort((first, second) {
          return second.collection.updationTime
              .compareTo(first.collection.updationTime);
        });
        incoming.sort((first, second) {
          return second.collection.updationTime
              .compareTo(first.collection.updationTime);
        });
        return SharedCollections(outgoing, incoming);
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _getSharedCollectionsGallery(snapshot.data);
        } else if (snapshot.hasError) {
          _logger.shout(snapshot.error);
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return loadWidget;
        }
      },
    );
  }

  Widget _getSharedCollectionsGallery(SharedCollections collections) {
    const double horizontalPaddingOfGridRow = 16;
    const double crossAxisSpacingOfGrid = 9;
    Size size = MediaQuery.of(context).size;
    int albumsCountInOneRow = max(size.width ~/ 220.0, 2);
    double totalWhiteSpaceOfRow = (horizontalPaddingOfGridRow * 2) +
        (albumsCountInOneRow - 1) * crossAxisSpacingOfGrid;
    final double sideOfThumbnail = (size.width / albumsCountInOneRow) -
        (totalWhiteSpaceOfRow / albumsCountInOneRow);
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(bottom: 50),
        child: Column(
          children: [
            const SizedBox(height: 12),
            SectionTitle("Incoming"),
            const SizedBox(height: 12),
            collections.incoming.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return IncomingCollectionItem(
                          collections.incoming[index],
                        );
                      },
                      itemCount: collections.incoming.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: albumsCountInOneRow,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: crossAxisSpacingOfGrid,
                        childAspectRatio:
                            sideOfThumbnail / (sideOfThumbnail + 24),
                      ), //24 is height of album title
                    ),
                  )
                : _getIncomingCollectionEmptyState(),
            const SizedBox(height: 52),
            SectionTitle("Outgoing"),
            const SizedBox(height: 12),
            collections.outgoing.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: 12),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return OutgoingCollectionItem(
                        collections.outgoing[index],
                      );
                    },
                    itemCount: collections.outgoing.length,
                  )
                : _getOutgoingCollectionEmptyState(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _getIncomingCollectionEmptyState() {
    return SizedBox(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No one is sharing with you :(",
            style: Theme.of(context).textTheme.caption,
          ),
          Padding(padding: EdgeInsets.only(top: 14)),
          SizedBox(
            width: 200,
            height: 50,
            child: GradientButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.outgoing_mail,
                    color: Colors.white,
                  ),
                  Padding(padding: EdgeInsets.all(2)),
                  Text(
                    "Invite",
                    style: gradientButtonTextTheme().copyWith(fontSize: 16),
                  ),
                ],
              ),
              linearGradientColors: const [
                Color(0xFF2CD267),
                Color(0xFF1DB954),
              ],
              onTap: () async {
                shareText("Check out https://ente.io");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getOutgoingCollectionEmptyState() {
    return SizedBox(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Share your first album!",
            style: Theme.of(context).textTheme.caption,
          ),
          Padding(padding: EdgeInsets.only(top: 14)),
          SizedBox(
            width: 200,
            height: 50,
            child: GradientButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  Padding(padding: EdgeInsets.all(2)),
                  Text(
                    "Share",
                    style: gradientButtonTextTheme().copyWith(fontSize: 16),
                  ),
                ],
              ),
              linearGradientColors: const [
                Color(0xFF2CD267),
                Color(0xFF1DB954),
              ],
              onTap: () async {
                await showToast(
                  context,
                  "Open an album and tap the share button on the top right to share.",
                  toastLength: Toast.LENGTH_LONG,
                );
                Bus.instance.fire(
                  TabChangedEvent(1, TabChangedEventSource.collections_page),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localFilesSubscription.cancel();
    _collectionUpdatesSubscription.cancel();
    _loggedOutEvent.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class OutgoingCollectionItem extends StatelessWidget {
  final CollectionWithThumbnail c;

  const OutgoingCollectionItem(
    this.c, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharees = <String>[];
    for (int index = 0; index < c.collection.sharees.length; index++) {
      final sharee = c.collection.sharees[index];
      final name =
          (sharee.name?.isNotEmpty ?? false) ? sharee.name : sharee.email;
      if (index < 2) {
        sharees.add(name);
      } else {
        final remaining = c.collection.sharees.length - index;
        if (remaining == 1) {
          // If it's the last sharee
          sharees.add(name);
        } else {
          sharees.add(
            "and " +
                remaining.toString() +
                " other" +
                (remaining > 1 ? "s" : ""),
          );
        }
        break;
      }
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                child: Hero(
                  tag: "outgoing_collection" + c.thumbnail.tag(),
                  child: ThumbnailWidget(
                    c.thumbnail,
                    key: Key("outgoing_collection" + c.thumbnail.tag()),
                  ),
                ),
                height: 60,
                width: 60,
              ),
            ),
            Padding(padding: EdgeInsets.all(8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        c.collection.name,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(2)),
                      c.collection.publicURLs.isEmpty
                          ? Container()
                          : Icon(Icons.link),
                    ],
                  ),
                  sharees.isEmpty
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Text(
                            "Shared with " + sharees.join(", "),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorLight,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        final page = CollectionPage(
          c,
          appBarType: GalleryType.owned_collection,
          tagPrefix: "outgoing_collection",
        );
        routeToPage(context, page);
      },
    );
  }
}

class IncomingCollectionItem extends StatelessWidget {
  final CollectionWithThumbnail c;

  const IncomingCollectionItem(
    this.c, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double horizontalPaddingOfGridRow = 16;
    const double crossAxisSpacingOfGrid = 9;
    TextStyle albumTitleTextStyle =
        Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 14);
    Size size = MediaQuery.of(context).size;
    int albumsCountInOneRow = max(size.width ~/ 220.0, 2);
    double totalWhiteSpaceOfRow = (horizontalPaddingOfGridRow * 2) +
        (albumsCountInOneRow - 1) * crossAxisSpacingOfGrid;
    final double sideOfThumbnail = (size.width / albumsCountInOneRow) -
        (totalWhiteSpaceOfRow / albumsCountInOneRow);
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              child: Stack(
                children: [
                  Hero(
                    tag: "shared_collection" + c.thumbnail.tag(),
                    child: ThumbnailWidget(
                      c.thumbnail,
                      key: Key("shared_collection" + c.thumbnail.tag()),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      child: Text(
                        c.collection.owner.name == null ||
                                c.collection.owner.name.isEmpty
                            ? c.collection.owner.email.substring(0, 1)
                            : c.collection.owner.name.substring(0, 1),
                        textAlign: TextAlign.center,
                      ),
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .defaultBackgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
              height: sideOfThumbnail,
              width: sideOfThumbnail,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: sideOfThumbnail - 40),
                child: Text(
                  c.collection.name,
                  style: albumTitleTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FutureBuilder<int>(
                future: FilesDB.instance.collectionFileCount(c.collection.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data > 0) {
                    return RichText(
                      text: TextSpan(
                        style: albumTitleTextStyle.copyWith(
                          color: albumTitleTextStyle.color.withOpacity(0.5),
                        ),
                        children: [
                          TextSpan(text: "  \u2022  "),
                          TextSpan(text: snapshot.data.toString()),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        routeToPage(
          context,
          CollectionPage(
            c,
            appBarType: GalleryType.shared_collection,
            tagPrefix: "shared_collection",
          ),
        );
      },
    );
  }
}
