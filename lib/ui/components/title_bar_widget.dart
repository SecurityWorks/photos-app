import 'package:flutter/material.dart';
import 'package:photos/theme/ente_theme.dart';

class TitleBarWidget extends StatelessWidget {
  final String? title;
  final String? caption;
  final Widget? flexibleSpaceTitle;
  final String? flexibleSpaceCaption;
  final List<Widget>? actionIcons;
  final bool isTitleBigWithoutLeading;
  const TitleBarWidget({
    this.title,
    this.caption,
    this.flexibleSpaceTitle,
    this.flexibleSpaceCaption,
    this.actionIcons,
    this.isTitleBigWithoutLeading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = getEnteTextTheme(context);
    final colorTheme = getEnteColorScheme(context);
    return SliverAppBar(
      toolbarHeight: 48,
      leadingWidth: 48,
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 102,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(left: isTitleBigWithoutLeading ? 16 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            title == null
                ? const SizedBox.shrink()
                : Text(
                    title!,
                    style: isTitleBigWithoutLeading
                        ? textTheme.h2Bold
                        : textTheme.largeBold,
                  ),
            caption == null || isTitleBigWithoutLeading
                ? const SizedBox.shrink()
                : Text(
                    caption!,
                    style: textTheme.mini.copyWith(color: colorTheme.textMuted),
                  )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          child: Row(
            children: _getActions(),
          ),
        ),
      ],
      leading: isTitleBigWithoutLeading
          ? null
          : Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton(
                visualDensity:
                    const VisualDensity(horizontal: -2, vertical: -2),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_outlined),
              ),
            ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              flexibleSpaceTitle == null
                  ? const SizedBox.shrink()
                  : flexibleSpaceTitle!,
              flexibleSpaceCaption == null
                  ? const SizedBox.shrink()
                  : Text(
                      'Caption',
                      style: textTheme.small.copyWith(
                        color: colorTheme.textMuted,
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  _getActions() {
    if (actionIcons == null) {
      return <Widget>[const SizedBox.shrink()];
    }
    final actions = <Widget>[];
    bool addWhiteSpace = false;
    final length = actionIcons!.length;
    int index = 0;
    if (length == 0) {
      return <Widget>[const SizedBox.shrink()];
    }
    if (length == 1) {
      return actionIcons;
    }
    while (index < length) {
      if (!addWhiteSpace) {
        actions.add(actionIcons![index]);
        index++;
        addWhiteSpace = true;
      } else {
        actions.add(const SizedBox(width: 4));
        addWhiteSpace = false;
      }
    }
    return actions;
  }
}
