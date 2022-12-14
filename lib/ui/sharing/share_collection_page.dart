// @dart=2.9

import 'package:collection/collection.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:photos/models/collection.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/theme/ente_theme.dart';
import 'package:photos/ui/actions/collection/collection_sharing_actions.dart';
import 'package:photos/ui/components/captioned_text_widget.dart';
import 'package:photos/ui/components/divider_widget.dart';
import 'package:photos/ui/components/menu_item_widget.dart';
import 'package:photos/ui/components/menu_section_title.dart';
import 'package:photos/ui/sharing/add_partipant_page.dart';
import 'package:photos/ui/sharing/album_participants_page.dart';
import 'package:photos/ui/sharing/manage_links_widget.dart';
import 'package:photos/ui/sharing/user_avator_widget.dart';
import 'package:photos/utils/navigation_util.dart';
import 'package:photos/utils/share_util.dart';
import 'package:photos/utils/toast_util.dart';

class ShareCollectionPage extends StatefulWidget {
  final Collection collection;

  const ShareCollectionPage(this.collection, {Key key}) : super(key: key);

  @override
  State<ShareCollectionPage> createState() => _ShareCollectionPageState();
}

class _ShareCollectionPageState extends State<ShareCollectionPage> {
  List<User> _sharees;
  final Logger _logger = Logger("SharingDialogState");
  final CollectionSharingActions sharingActions =
      CollectionSharingActions(CollectionsService.instance);

  Future<void> _navigateToManageUser() async {
    final result = await routeToPage(
      context,
      AlbumParticipantsPage(widget.collection),
    );
    if (mounted) {
      setState(() => {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _sharees = widget.collection.sharees ?? [];
    final children = <Widget>[];
    children.add(
      MenuSectionTitle(
        title: _sharees.isEmpty
            ? "Share with specific people"
            : "Shared with ${_sharees.length} ${_sharees.length == 1 ? 'person' : 'people'}",
        iconData: Icons.workspaces,
      ),
    );

    children.add(
      EmailItemWidget(
        widget.collection,
        onTap: _navigateToManageUser,
      ),
    );

    children.add(
      MenuItemWidget(
        captionedTextWidget: CaptionedTextWidget(
          title: _sharees.isEmpty ? "Add email" : "Add more",
          makeTextBold: true,
        ),
        leadingIcon: Icons.add,
        menuItemColor: getEnteColorScheme(context).fillFaint,
        pressedColor: getEnteColorScheme(context).fillFaint,
        borderRadius: 4.0,
        onTap: () async {
          routeToPage(context, AddParticipantPage(widget.collection)).then(
            (value) => {
              if (mounted) {setState(() => {})}
            },
          );
        },
      ),
    );

    final bool hasUrl = widget.collection.publicURLs?.isNotEmpty ?? false;
    final bool hasExpired =
        widget.collection?.publicURLs?.firstOrNull?.isExpired ?? false;
    children.addAll([
      const SizedBox(
        height: 24,
      ),
      MenuSectionTitle(
        title: hasUrl ? "Public link enabled" : "Share a public link",
        iconData: Icons.public,
      ),
    ]);
    if (hasUrl) {
      if (hasExpired) {
        children.add(
          MenuItemWidget(
            captionedTextWidget: CaptionedTextWidget(
              title: "Link has expired",
              textColor: getEnteColorScheme(context).warning500,
            ),
            leadingIcon: Icons.error_outline,
            leadingIconColor: getEnteColorScheme(context).warning500,
            menuItemColor: getEnteColorScheme(context).fillFaint,
            pressedColor: getEnteColorScheme(context).fillFaint,
            onTap: () async {},
            isBottomBorderRadiusRemoved: true,
          ),
        );
      } else {
        final String collectionKey = Base58Encode(
          CollectionsService.instance.getCollectionKey(widget.collection.id),
        );
        final String url =
            "${widget.collection.publicURLs.first.url}#$collectionKey";
        children.addAll(
          [
            MenuItemWidget(
              captionedTextWidget: const CaptionedTextWidget(
                title: "Copy link",
                makeTextBold: true,
              ),
              leadingIcon: Icons.copy,
              menuItemColor: getEnteColorScheme(context).fillFaint,
              pressedColor: getEnteColorScheme(context).fillFaint,
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: url));
                showToast(context, "Link copied to clipboard");
              },
              isBottomBorderRadiusRemoved: true,
            ),
            DividerWidget(
              dividerType: DividerType.menu,
              bgColor: getEnteColorScheme(context).blurStrokeFaint,
            ),
            MenuItemWidget(
              captionedTextWidget: const CaptionedTextWidget(
                title: "Send link",
                makeTextBold: true,
              ),
              leadingIcon: Icons.adaptive.share,
              menuItemColor: getEnteColorScheme(context).fillFaint,
              pressedColor: getEnteColorScheme(context).fillFaint,
              onTap: () async {
                shareText(url);
              },
              isTopBorderRadiusRemoved: true,
            ),
          ],
        );
      }

      children.addAll(
        [
          DividerWidget(
            dividerType: DividerType.menu,
            bgColor: getEnteColorScheme(context).blurStrokeFaint,
          ),
          MenuItemWidget(
            captionedTextWidget: const CaptionedTextWidget(
              title: "Manage link",
              makeTextBold: true,
            ),
            leadingIcon: Icons.link,
            trailingIcon: Icons.navigate_next,
            menuItemColor: getEnteColorScheme(context).fillFaint,
            pressedColor: getEnteColorScheme(context).fillFaint,
            trailingIconIsMuted: true,
            onTap: () async {
              routeToPage(
                context,
                ManageSharedLinkWidget(collection: widget.collection),
              ).then(
                (value) => {
                  if (mounted) {setState(() => {})}
                },
              );
            },
            isTopBorderRadiusRemoved: true,
          ),
        ],
      );
    } else {
      children.add(
        MenuItemWidget(
          captionedTextWidget: const CaptionedTextWidget(
            title: "Create public link",
          ),
          leadingIcon: Icons.link,
          menuItemColor: getEnteColorScheme(context).fillFaint,
          pressedColor: getEnteColorScheme(context).fillFaint,
          onTap: () async {
            final bool result = await sharingActions.publicLinkToggle(
              context,
              widget.collection,
              true,
            );
            if (result && mounted) {
              setState(() => {});
            }
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sharing")),
      body: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
              child: Column(
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailItemWidget extends StatelessWidget {
  final Collection collection;
  final Function onTap;

  const EmailItemWidget(
    this.collection, {
    this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (collection.getSharees().isEmpty) {
      return const SizedBox.shrink();
    } else if (collection.getSharees().length == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MenuItemWidget(
            captionedTextWidget: CaptionedTextWidget(
              title: collection.getSharees().firstOrNull?.email ?? '',
            ),
            leadingIconWidget: UserAvatarWidget(collection.getSharees().first),
            leadingIconSize: 24,
            menuItemColor: getEnteColorScheme(context).fillFaint,
            pressedColor: getEnteColorScheme(context).fillFaint,
            trailingIconIsMuted: true,
            trailingIcon: Icons.chevron_right,
            onTap: () async {
              if (onTap != null) {
                onTap();
              }
            },
            isBottomBorderRadiusRemoved: true,
          ),
          DividerWidget(
            dividerType: DividerType.menu,
            bgColor: getEnteColorScheme(context).blurStrokeFaint,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MenuItemWidget(
            captionedTextWidget: const CaptionedTextWidget(
              title: 'Manage',
            ),
            leadingIcon: Icons.people_outline,
            menuItemColor: getEnteColorScheme(context).fillFaint,
            pressedColor: getEnteColorScheme(context).fillFaint,
            trailingIconIsMuted: true,
            trailingIcon: Icons.chevron_right,
            onTap: () async {
              if (onTap != null) {
                onTap();
              }
            },
            isBottomBorderRadiusRemoved: true,
          ),
          DividerWidget(
            dividerType: DividerType.menu,
            bgColor: getEnteColorScheme(context).blurStrokeFaint,
          ),
        ],
      );
    }
  }
}