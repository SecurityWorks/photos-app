import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/ui/settings/account_section_widget.dart';
import 'package:photos/ui/settings/app_version_widget.dart';
import 'package:photos/ui/settings/backup_section_widget.dart';
import 'package:photos/ui/settings/danger_section_widget.dart';
import 'package:photos/ui/settings/debug_section_widget.dart';
import 'package:photos/ui/settings/details_section_widget.dart';
import 'package:photos/ui/settings/info_section_widget.dart';
import 'package:photos/ui/settings/security_section_widget.dart';
import 'package:photos/ui/settings/social_section_widget.dart';
import 'package:photos/ui/settings/support_section_widget.dart';
import 'package:photos/ui/settings/theme_switch_widget.dart';

class SettingsPage extends StatelessWidget {
  final ValueNotifier<String> emailNotifier;
  const SettingsPage({Key key, @required this.emailNotifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(context),
    );
  }

  Widget _getBody(BuildContext context) {
    final hasLoggedIn = Configuration.instance.getToken() != null;
    final List<Widget> contents = [];
    contents.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // // Thanks to the [AnimatedBuilder], only the widget displaying the
            // // current email is rebuilt when `emailNotifier` notifies its
            // // listeners.
            AnimatedBuilder(
              // [AnimatedBuilder] accepts any [Listenable] subtype.
              animation: emailNotifier,
              builder: (BuildContext context, Widget child) {
                return Text(
                  emailNotifier.value,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(overflow: TextOverflow.ellipsis),
                );
              },
            ),

            (Platform.isAndroid)
                ? const ThemeSwitchWidget()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
    final sectionDivider = Divider(
      height: 20,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
    );
    contents.add(const Padding(padding: EdgeInsets.all(4)));
    if (hasLoggedIn) {
      contents.addAll([
        const DetailsSectionWidget(),
        const Padding(padding: EdgeInsets.only(bottom: 24)),
        const BackupSectionWidget(),
        sectionDivider,
        const AccountSectionWidget(),
        sectionDivider,
      ]);
    }
    contents.addAll([
      const SecuritySectionWidget(),
      sectionDivider,
      const SupportSectionWidget(),
      sectionDivider,
      const SocialSectionWidget(),
      sectionDivider,
      const InfoSectionWidget(),
    ]);
    if (hasLoggedIn) {
      contents.addAll([
        sectionDivider,
        const DangerSectionWidget(),
      ]);
    }

    if (kDebugMode && hasLoggedIn) {
      contents.addAll([sectionDivider, const DebugSectionWidget()]);
    }
    contents.add(const AppVersionWidget());
    contents.add(
      const Padding(
        padding: EdgeInsets.only(bottom: 60),
      ),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              children: contents,
            ),
          ),
        ),
      ),
    );
  }
}
