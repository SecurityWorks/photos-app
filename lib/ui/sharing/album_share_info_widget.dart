import "dart:math";

import "package:flutter/material.dart";
import "package:photos/models/api/collection/user.dart";
import "package:photos/ui/sharing/more_count_badge.dart";
import "package:photos/ui/sharing/user_avator_widget.dart";

class AlbumSharesIcons extends StatelessWidget {
  final List<User> sharees;
  final int limitCountTo;
  final AvatarType type;
  final bool removeBorder;
  final EdgeInsets padding;
  final Widget? trailingWidget;

  const AlbumSharesIcons({
    Key? key,
    required this.sharees,
    this.type = AvatarType.tiny,
    this.limitCountTo = 2,
    this.removeBorder = true,
    this.trailingWidget,
    this.padding = const EdgeInsets.only(left: 10.0, top: 10, bottom: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayCount = min(sharees.length, limitCountTo);
    final hasMore = sharees.length > limitCountTo;
    final double overlapPadding = type == AvatarType.tiny ? 14.0 : 20.0;
    final widgets = List<Widget>.generate(
      displayCount,
      (index) => Positioned(
        left: overlapPadding * index,
        child: UserAvatarWidget(
          sharees[index],
          thumbnailView: removeBorder,
          type: type,
        ),
      ),
    );

    if (hasMore) {
      widgets.add(
        Positioned(
          left: (overlapPadding * displayCount),
          child: MoreCountWidget(
            sharees.length - displayCount,
            type: type == AvatarType.tiny
                ? MoreCountType.tiny
                : MoreCountType.mini,
            thumbnailView: removeBorder,
          ),
        ),
      );
    }
    if (trailingWidget != null) {
      widgets.add(
        Positioned(
          left: (overlapPadding * (displayCount + (hasMore ? 1 : 0))) + 12,
          child: trailingWidget!,
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Stack(children: widgets),
    );
  }
}
