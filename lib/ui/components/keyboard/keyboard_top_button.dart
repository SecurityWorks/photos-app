import 'package:flutter/cupertino.dart';
import "package:photos/generated/l10n.dart";
import 'package:photos/theme/ente_theme.dart';

class KeyboardTopButton extends StatelessWidget {
  final VoidCallback? onDoneTap;
  final VoidCallback? onCancelTap;
  final String? doneText;
  final String? cancelText;

  const KeyboardTopButton({
    super.key,
    this.doneText,
    this.cancelText,
    this.onDoneTap,
    this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    final enteTheme = getEnteTextTheme(context);
    final colorScheme = getEnteColorScheme(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: colorScheme.strokeFaint),
          bottom: BorderSide(width: 1.0, color: colorScheme.strokeFaint),
        ),
        color: colorScheme.backgroundElevated2,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              onPressed: onCancelTap,
              child: Text(
                cancelText ?? S.of(context).cancel,
                style: enteTheme.bodyBold,
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              onPressed: onDoneTap,
              child: Text(
                doneText ?? S.of(context).done,
                style: enteTheme.bodyBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
