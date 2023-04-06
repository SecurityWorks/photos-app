import 'dart:io';

import 'package:flutter/material.dart';
import "package:photos/generated/l10n.dart";
import 'package:photos/models/backup_status.dart';
import 'package:photos/models/duplicate_files.dart';
import 'package:photos/services/deduplication_service.dart';
import 'package:photos/services/sync_service.dart';
import 'package:photos/services/update_service.dart';
import 'package:photos/theme/ente_theme.dart';
import 'package:photos/ui/backup_folder_selection_page.dart';
import 'package:photos/ui/backup_settings_screen.dart';
import 'package:photos/ui/components/captioned_text_widget.dart';
import 'package:photos/ui/components/dialog_widget.dart';
import 'package:photos/ui/components/expandable_menu_item_widget.dart';
import 'package:photos/ui/components/menu_item_widget/menu_item_widget.dart';
import 'package:photos/ui/components/models/button_type.dart';
import 'package:photos/ui/settings/common_settings.dart';
import 'package:photos/ui/tools/deduplicate_page.dart';
import 'package:photos/ui/tools/free_space_page.dart';
import 'package:photos/utils/data_util.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/navigation_util.dart';
import 'package:photos/utils/toast_util.dart';

class BackupSectionWidget extends StatefulWidget {
  const BackupSectionWidget({Key? key}) : super(key: key);

  @override
  BackupSectionWidgetState createState() => BackupSectionWidgetState();
}

class BackupSectionWidgetState extends State<BackupSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return ExpandableMenuItemWidget(
      title: S.of(context).backup,
      selectionOptionsWidget: _getSectionOptions(context),
      leadingIcon: Icons.backup_outlined,
    );
  }

  Widget _getSectionOptions(BuildContext context) {
    final List<Widget> sectionOptions = [
      sectionOptionSpacing,
      MenuItemWidget(
        captionedTextWidget: CaptionedTextWidget(
          title: S.of(context).backedUpFolders,
        ),
        pressedColor: getEnteColorScheme(context).fillFaint,
        trailingIcon: Icons.chevron_right_outlined,
        trailingIconIsMuted: true,
        onTap: () async {
          routeToPage(
            context,
            BackupFolderSelectionPage(
              buttonText: S.of(context).backup,
            ),
          );
        },
      ),
      sectionOptionSpacing,
      MenuItemWidget(
        captionedTextWidget: CaptionedTextWidget(
          title: S.of(context).backupSettings,
        ),
        pressedColor: getEnteColorScheme(context).fillFaint,
        trailingIcon: Icons.chevron_right_outlined,
        trailingIconIsMuted: true,
        onTap: () async {
          routeToPage(
            context,
            const BackupSettingsScreen(),
          );
        },
      ),
      sectionOptionSpacing,
    ];

    sectionOptions.addAll(
      [
        MenuItemWidget(
          captionedTextWidget: CaptionedTextWidget(
            title: S.of(context).freeUpDeviceSpace,
          ),
          pressedColor: getEnteColorScheme(context).fillFaint,
          trailingIcon: Icons.chevron_right_outlined,
          trailingIconIsMuted: true,
          showOnlyLoadingState: true,
          onTap: () async {
            BackupStatus status;
            try {
              status = await SyncService.instance.getBackupStatus();
            } catch (e) {
              showGenericErrorDialog(context: context);
              return;
            }

            if (status.localIDs.isEmpty) {
              showErrorDialog(
                context,
                S.of(context).allClear,
                S.of(context).noDeviceThatCanBeDeleted,
              );
            } else {
              final bool? result =
                  await routeToPage(context, FreeSpacePage(status));
              if (result == true) {
                _showSpaceFreedDialog(status);
              }
            }
          },
        ),
        sectionOptionSpacing,
        MenuItemWidget(
          captionedTextWidget: CaptionedTextWidget(
            title: S.of(context).removeDuplicates,
          ),
          pressedColor: getEnteColorScheme(context).fillFaint,
          trailingIcon: Icons.chevron_right_outlined,
          trailingIconIsMuted: true,
          showOnlyLoadingState: true,
          onTap: () async {
            List<DuplicateFiles> duplicates;
            try {
              duplicates =
                  await DeduplicationService.instance.getDuplicateFiles();
            } catch (e) {
              showGenericErrorDialog(context: context);
              return;
            }

            if (duplicates.isEmpty) {
              showErrorDialog(
                context,
                S.of(context).noDuplicates,
                S.of(context).youveNoDuplicateFilesThatCanBeCleared,
              );
            } else {
              final DeduplicationResult? result =
                  await routeToPage(context, DeduplicatePage(duplicates));
              if (result != null) {
                _showDuplicateFilesDeletedDialog(result);
              }
            }
          },
        ),
        sectionOptionSpacing,
      ],
    );
    return Column(
      children: sectionOptions,
    );
  }

  void _showSpaceFreedDialog(BackupStatus status) {
    final DialogWidget dialog = choiceDialog(
      title: S.of(context).success,
      body: S.of(context).youHaveSuccessfullyFreedUp(formatBytes(status.size)),
      firstButtonLabel: S.of(context).rateUs,
      firstButtonOnTap: () async {
        UpdateService.instance.launchReviewUrl();
      },
      firstButtonType: ButtonType.primary,
      secondButtonLabel: S.of(context).ok,
      secondButtonOnTap: () async {
        if (Platform.isIOS) {
          showToast(
            context,
            S.of(context).remindToEmptyDeviceTrash,
          );
        }
      },
    );

    showConfettiDialog(
      context: context,
      dialogBuilder: (BuildContext context) {
        return dialog;
      },
      barrierColor: Colors.black87,
      confettiAlignment: Alignment.topCenter,
      useRootNavigator: true,
    );
  }

  void _showDuplicateFilesDeletedDialog(DeduplicationResult result) {
    final DialogWidget dialog = choiceDialog(
      title: S.of(context).sparkleSuccess,
      body: S.of(context).duplicateFileCountWithStorageSaved(
            result.count,
            formatBytes(result.size),
          ),
      firstButtonLabel: S.of(context).rateUs,
      firstButtonOnTap: () async {
        UpdateService.instance.launchReviewUrl();
      },
      firstButtonType: ButtonType.primary,
      secondButtonLabel: S.of(context).ok,
      secondButtonOnTap: () async {
        showShortToast(
          context,
          S.of(context).remindToEmptyEnteTrash,
        );
      },
    );

    showConfettiDialog(
      context: context,
      dialogBuilder: (BuildContext context) {
        return dialog;
      },
      barrierColor: Colors.black87,
      confettiAlignment: Alignment.topCenter,
      useRootNavigator: true,
    );
  }
}
