import 'dart:async';
import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/events/two_factor_status_change_event.dart';
import 'package:photos/services/user_service.dart';
import 'package:photos/ui/app_lock.dart';
import 'package:photos/ui/loading_widget.dart';
import 'package:photos/ui/sessions_page.dart';
import 'package:photos/ui/settings/common_settings.dart';
import 'package:photos/ui/settings/settings_section_title.dart';
import 'package:photos/ui/settings/settings_text_item.dart';
import 'package:photos/utils/auth_util.dart';
import 'package:photos/utils/toast_util.dart';

class SecuritySectionWidget extends StatefulWidget {
  SecuritySectionWidget({Key key}) : super(key: key);

  @override
  _SecuritySectionWidgetState createState() => _SecuritySectionWidgetState();
}

class _SecuritySectionWidgetState extends State<SecuritySectionWidget> {
  static const kAuthToViewSessions =
      "Please authenticate to view your active sessions";

  final _config = Configuration.instance;

  StreamSubscription<TwoFactorStatusChangeEvent> _twoFactorStatusChangeEvent;

  @override
  void initState() {
    super.initState();
    _twoFactorStatusChangeEvent =
        Bus.instance.on<TwoFactorStatusChangeEvent>().listen((event) async {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _twoFactorStatusChangeEvent.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      header: SettingsSectionTitle("Security"),
      collapsed: Container(),
      expanded: _getSectionOptions(context),
      theme: getExpandableTheme(context),
    );
  }

  Widget _getSectionOptions(BuildContext context) {
    final List<Widget> children = [];
    if (_config.hasConfiguredAccount()) {
      children.addAll(
        [
          Padding(padding: EdgeInsets.all(2)),
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Two-factor",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                FutureBuilder(
                  future: UserService.instance.fetchTwoFactorStatus(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return Switch.adaptive(
                        value: snapshot.data,
                        onChanged: (value) async {
                          AppLock.of(context).setEnabled(false);
                          String reason =
                              "Please authenticate to configure two-factor authentication";
                          final result = await requestAuthentication(reason);
                          AppLock.of(context).setEnabled(
                              Configuration.instance.shouldShowLockScreen());
                          if (!result) {
                            showToast(reason);
                            return;
                          }
                          if (value) {
                            UserService.instance.setupTwoFactor(context);
                          } else {
                            _disableTwoFactor();
                          }
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Icon(
                        Icons.error_outline,
                        color: Colors.white.withOpacity(0.8),
                      );
                    }
                    return loadWidget;
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    children.addAll([
      SectionOptionDivider,
      SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lockscreen",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Switch.adaptive(
              value: _config.shouldShowLockScreen(),
              onChanged: (value) async {
                AppLock.of(context).disable();
                final result = await requestAuthentication(
                    "Please authenticate to change lockscreen setting");
                if (result) {
                  AppLock.of(context).setEnabled(value);
                  _config.setShouldShowLockScreen(value);
                  setState(() {});
                } else {
                  AppLock.of(context)
                      .setEnabled(_config.shouldShowLockScreen());
                }
              },
            ),
          ],
        ),
      ),
    ]);
    if (Platform.isAndroid) {
      children.addAll(
        [
          SectionOptionDivider,
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hide from recents",
                    style: Theme.of(context).textTheme.subtitle1),
                Switch.adaptive(
                  value: _config.shouldHideFromRecents(),
                  onChanged: (value) async {
                    if (value) {
                      AlertDialog alert = AlertDialog(
                        title: Text("Hide from recents?"),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "hiding from the task switcher will prevent you from taking screenshots in this app.",
                                style: TextStyle(
                                  height: 1.5,
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(8)),
                              Text(
                                "are you sure?",
                                style: TextStyle(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text("no",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                          ),
                          TextButton(
                            child: Text("yes",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8))),
                            onPressed: () async {
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                              await _config.setShouldHideFromRecents(true);
                              await FlutterWindowManager.addFlags(
                                  FlutterWindowManager.FLAG_SECURE);
                              setState(() {});
                            },
                          ),
                        ],
                      );

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    } else {
                      await _config.setShouldHideFromRecents(false);
                      await FlutterWindowManager.clearFlags(
                          FlutterWindowManager.FLAG_SECURE);
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    children.addAll([
      SectionOptionDivider,
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          AppLock.of(context).setEnabled(false);
          final result = await requestAuthentication(kAuthToViewSessions);
          AppLock.of(context)
              .setEnabled(Configuration.instance.shouldShowLockScreen());
          if (!result) {
            showToast(kAuthToViewSessions);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return SessionsPage();
              },
            ),
          );
        },
        child: SettingsTextItem(
            text: "Active sessions", icon: Icons.navigate_next),
      ),
    ]);
    return Column(
      children: children,
    );
  }

  void _disableTwoFactor() {
    AlertDialog alert = AlertDialog(
      title: Text("Disable two-factor"),
      content:
          Text("Are you sure you want to disable two-factor authentication?"),
      actions: [
        TextButton(
          child: Text(
            "no",
            style: TextStyle(
              color: Theme.of(context).buttonColor,
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
        TextButton(
          child: Text(
            "yes",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          onPressed: () async {
            await UserService.instance.disableTwoFactor(context);
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
