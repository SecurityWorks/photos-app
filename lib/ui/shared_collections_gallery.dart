import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/events/collection_updated_event.dart';
import 'package:photos/events/local_photos_updated_event.dart';
import 'package:photos/events/tab_changed_event.dart';
import 'package:photos/events/user_logged_out_event.dart';
import "package:photos/generated/l10n.dart";
import 'package:photos/models/collection.dart';
import 'package:photos/models/collection_items.dart';
import 'package:photos/models/gallery_type.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/theme/colors.dart';
import 'package:photos/ui/collections/section_title.dart';
import 'package:photos/ui/common/gradient_button.dart';
import 'package:photos/ui/common/loading_widget.dart';
import "package:photos/ui/new_shared_collections_gallery.dart";
import 'package:photos/ui/sharing/user_avator_widget.dart';
import 'package:photos/ui/viewer/file/thumbnail_widget.dart';
import 'package:photos/ui/viewer/gallery/collection_page.dart';
import 'package:photos/utils/navigation_util.dart';
import 'package:photos/utils/share_util.dart';
import 'package:photos/utils/toast_util.dart';

class SharedCollectionGallery extends StatefulWidget {
  const SharedCollectionGallery({Key? key}) : super(key: key);

  @override
  State<SharedCollectionGallery> createState() =>
      _SharedCollectionGalleryState();
}

class _SharedCollectionGalleryState extends State<SharedCollectionGallery>
    with AutomaticKeepAliveClientMixin {
  final Logger _logger = Logger("SharedCollectionGallery");
  late StreamSubscription<LocalPhotosUpdatedEvent> _localFilesSubscription;
  late StreamSubscription<CollectionUpdatedEvent>
      _collectionUpdatesSubscription;
  late StreamSubscription<UserLoggedOutEvent> _loggedOutEvent;

  @override
  void initState() {
    _localFilesSubscription =
        Bus.instance.on<LocalPhotosUpdatedEvent>().listen((event) {
      debugPrint("SetState Shared Collections on ${event.reason}");
      setState(() {});
    });
    _collectionUpdatesSubscription =
        Bus.instance.on<CollectionUpdatedEvent>().listen((event) {
      debugPrint("SetState Shared Collections on ${event.reason}");
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
          if (file.collectionID == null) {
            _logger.severe("collection id should not be null");
            continue;
          }
          final Collection? c =
              CollectionsService.instance.getCollectionByID(file.collectionID!);
          if (c == null) {
            _logger
                .severe("shared collection is not cached ${file.collectionID}");
            CollectionsService.instance
                .fetchCollectionByID(file.collectionID!)
                .ignore();
            continue;
          }
          if (c.owner!.id == Configuration.instance.getUserID()) {
            if (c.hasSharees || c.hasLink || c.isSharedFilesCollection()) {
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
          if (second.collection.isSharedFilesCollection() ==
              first.collection.isSharedFilesCollection()) {
            return second.collection.updationTime
                .compareTo(first.collection.updationTime);
          } else {
            if (first.collection.isSharedFilesCollection()) {
              return 1;
            }
            return -1;
          }
        });
        incoming.sort((first, second) {
          return second.collection.updationTime
              .compareTo(first.collection.updationTime);
        });
        return SharedCollections(outgoing, incoming);
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if ((snapshot.data?.incoming.length ?? 0) == 0 &&
              (snapshot.data?.outgoing.length ?? 0) == 0) {
            return const Center(child: EmptyStateWidget());
          }
          return _getSharedCollectionsGallery(snapshot.data!);
        } else if (snapshot.hasError) {
          _logger.severe(
            "critical: failed to load share gallery",
            snapshot.error,
            snapshot.stackTrace,
          );
          return Center(child: Text(S.of(context).somethingWentWrong));
        } else {
          return const EnteLoadingWidget();
        }
      },
    );
  }

  Widget _getSharedCollectionsGallery(SharedCollections collections) {
    const double horizontalPaddingOfGridRow = 16;
    const double crossAxisSpacingOfGrid = 9;
    final Size size = MediaQuery.of(context).size;
    final int albumsCountInOneRow = max(size.width ~/ 220.0, 2);
    final double totalWhiteSpaceOfRow = (horizontalPaddingOfGridRow * 2) +
        (albumsCountInOneRow - 1) * crossAxisSpacingOfGrid;
    final double sideOfThumbnail = (size.width / albumsCountInOneRow) -
        (totalWhiteSpaceOfRow / albumsCountInOneRow);
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(bottom: 50),
        child: Column(
          children: [
            const SizedBox(height: 12),
            SectionTitle(title: S.of(context).sharedWithMe),
            const SizedBox(height: 12),
            collections.incoming.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
            const SizedBox(height: 16),
            SectionTitle(title: S.of(context).sharedByMe),
            const SizedBox(height: 12),
            collections.outgoing.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 12),
                    physics: const NeverScrollableScrollPhysics(),
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
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).askYourLovedOnesToShare,
            style: Theme.of(context).textTheme.caption,
          ),
          const Padding(padding: EdgeInsets.only(top: 14)),
          SizedBox(
            width: 200,
            height: 50,
            child: GradientButton(
              onTap: () async {
                shareText(S.of(context).shareTextRecommendUsingEnte);
              },
              iconData: Icons.outgoing_mail,
              text: S.of(context).invite,
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _getOutgoingCollectionEmptyState() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).shareYourFirstAlbum,
            style: Theme.of(context).textTheme.caption,
          ),
          const Padding(padding: EdgeInsets.only(top: 14)),
          SizedBox(
            width: 200,
            height: 50,
            child: GradientButton(
              onTap: () async {
                await showToast(
                  context,
                  S.of(context).shareAlbumHint,
                  toastLength: Toast.LENGTH_LONG,
                );
                Bus.instance.fire(
                  TabChangedEvent(1, TabChangedEventSource.collectionsPage),
                );
              },
              iconData: Icons.person_add,
              text: S.of(context).share,
            ),
          ),
          const SizedBox(height: 60),
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shareesName = <String>[];
    if (c.collection.hasSharees) {
      for (int index = 0; index < c.collection.sharees!.length; index++) {
        final sharee = c.collection.sharees![index]!;
        final String name =
            (sharee.name?.isNotEmpty ?? false) ? sharee.name! : sharee.email;
        if (index < 2) {
          shareesName.add(name);
        } else {
          final remaining = c.collection.sharees!.length - index;
          if (remaining == 1) {
            // If it's the last sharee
            shareesName.add(name);
          } else {
            shareesName.add(
              "and " +
                  remaining.toString() +
                  " other" +
                  (remaining > 1 ? "s" : ""),
            );
          }
          break;
        }
      }
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: SizedBox(
                height: 60,
                width: 60,
                child: Hero(
                  tag: "outgoing_collection" + c.thumbnail!.tag,
                  child: ThumbnailWidget(
                    c.thumbnail,
                    key: Key("outgoing_collection" + c.thumbnail!.tag),
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        c.collection.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(2)),
                      c.collection.hasLink
                          ? (c.collection.publicURLs!.first!.isExpired
                              ? const Icon(
                                  Icons.link,
                                  color: warning500,
                                )
                              : const Icon(Icons.link))
                          : Container(),
                    ],
                  ),
                  shareesName.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Text(
                            S.of(context).sharedWith(shareesName.join(", ")),
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
          appBarType: GalleryType.ownedCollection,
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double horizontalPaddingOfGridRow = 16;
    const double crossAxisSpacingOfGrid = 9;
    final TextStyle albumTitleTextStyle =
        Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14);
    final Size size = MediaQuery.of(context).size;
    final int albumsCountInOneRow = max(size.width ~/ 220.0, 2);
    final double totalWhiteSpaceOfRow = (horizontalPaddingOfGridRow * 2) +
        (albumsCountInOneRow - 1) * crossAxisSpacingOfGrid;
    final double sideOfThumbnail = (size.width / albumsCountInOneRow) -
        (totalWhiteSpaceOfRow / albumsCountInOneRow);
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: SizedBox(
              height: sideOfThumbnail,
              width: sideOfThumbnail,
              child: Stack(
                children: [
                  Hero(
                    tag: "shared_collection" + c.thumbnail!.tag,
                    child: ThumbnailWidget(
                      c.thumbnail,
                      key: Key("shared_collection" + c.thumbnail!.tag),
                      shouldShowArchiveStatus: c.collection.hasShareeArchived(),
                      shouldShowSyncStatus: false,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: UserAvatarWidget(
                        c.collection.owner!,
                        thumbnailView: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: sideOfThumbnail - 40),
                child: Text(
                  c.collection.displayName,
                  style: albumTitleTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FutureBuilder<int>(
                future: FilesDB.instance.collectionFileCount(c.collection.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data! > 0) {
                    return RichText(
                      text: TextSpan(
                        style: albumTitleTextStyle.copyWith(
                          color: albumTitleTextStyle.color!.withOpacity(0.5),
                        ),
                        children: [
                          const TextSpan(text: "  \u2022  "),
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
            appBarType: GalleryType.sharedCollection,
            tagPrefix: "shared_collection",
          ),
        );
      },
    );
  }
}
