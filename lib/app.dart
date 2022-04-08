import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/network.dart';
import 'package:photos/l10n/l10n.dart';
import 'package:photos/services/app_lifecycle_service.dart';
import 'package:photos/services/sync_service.dart';
import 'package:photos/ui/home_widget.dart';

final lightThemeData = ThemeData(
  fontFamily: 'Inter',
  brightness: Brightness.light,
  hintColor: Colors.grey,
  primaryColor: Colors.deepOrangeAccent,
  iconTheme: IconThemeData(color: Colors.black),
  primaryIconTheme: IconThemeData(color: Colors.red, opacity: 1.0, size: 50.0),
  colorScheme: ColorScheme.light(primary: Colors.black),
  accentColor: Color.fromRGBO(45, 194, 98, 0.2),
  buttonColor: Color.fromRGBO(45, 194, 98, 1.0),
  outlinedButtonTheme: _outlinedButtonThemeData(
    bgDisabled: Colors.grey.shade500,
    bgEnabled: Colors.black,
    fgDisabled: Colors.white,
    fgEnabled: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    onPrimary: Colors.white,
    primary: Colors.black,
    alignment: Alignment.center,
    textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter-SemiBold',
      fontSize: 18,
    ),
    padding: EdgeInsets.symmetric(vertical: 14),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  )),

  toggleableActiveColor: Colors.red[400],
  scaffoldBackgroundColor: Colors.white,
  bottomAppBarColor: Color.fromRGBO(196, 196, 196, 1.0),
  backgroundColor: Colors.white,
  appBarTheme: AppBarTheme().copyWith(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black)),
  //https://api.flutter.dev/flutter/material/TextTheme-class.html
  textTheme: _buildTextTheme(Colors.black),
  primaryTextTheme: TextTheme().copyWith(
      bodyText2: TextStyle(color: Colors.yellow),
      bodyText1: TextStyle(color: Colors.orange)),
  cardColor: Color.fromRGBO(250, 250, 250, 1.0),
  dialogTheme: DialogTheme().copyWith(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1.0), //
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 32, fontWeight: FontWeight.w600),
      contentTextStyle: TextStyle(
          fontFamily: 'Inter-Medium',
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  // textSelectionTheme: TextSelectionThemeData().copyWith(
  //   cursorColor: Colors.black.withOpacity(0.5),
  // ),
  inputDecorationTheme: InputDecorationTheme().copyWith(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromRGBO(45, 194, 98, 1.0),
      ),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(
      color: Colors.black,
      width: 2,
    ),
    fillColor: MaterialStateProperty.resolveWith((states) {
      return states.contains(MaterialState.selected)
          ? Colors.black
          : Colors.white;
    }),
    checkColor: MaterialStateProperty.resolveWith((states) {
      return states.contains(MaterialState.selected)
          ? Colors.white
          : Colors.black;
    }),
  ),
);

final darkThemeData = ThemeData(
  fontFamily: 'Inter',
  brightness: Brightness.dark,
  iconTheme: IconThemeData(color: Colors.white),
  primaryIconTheme: IconThemeData(color: Colors.red, opacity: 1.0, size: 50.0),
  hintColor: Colors.grey,
  bottomAppBarColor: Color.fromRGBO(196, 196, 196, 1.0),

  colorScheme: ColorScheme.dark(),
  accentColor: Color.fromRGBO(45, 194, 98, 0.2),
  buttonColor: Color.fromRGBO(45, 194, 98, 1.0),
  buttonTheme: ButtonThemeData().copyWith(
    buttonColor: Color.fromRGBO(45, 194, 98, 1.0),
  ),
  // primaryColor: Colors.red,
  textTheme: _buildTextTheme(Colors.white),
  toggleableActiveColor: Colors.green[400],
  outlinedButtonTheme: _outlinedButtonThemeData(
      bgDisabled: Colors.grey.shade500,
      bgEnabled: Colors.white,
      fgDisabled: Colors.white,
      fgEnabled: Colors.black),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    onPrimary: Colors.black,
    primary: Colors.white,
    minimumSize: Size(88, 36),
    alignment: Alignment.center,
    textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter-SemiBold',
      fontSize: 18,
    ),
    padding: EdgeInsets.symmetric(vertical: 14),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  )),
  scaffoldBackgroundColor: Colors.black,
  backgroundColor: Colors.black,
  appBarTheme: AppBarTheme().copyWith(
    color: Color.fromRGBO(10, 20, 20, 1.0),
  ),
  cardColor: Color.fromRGBO(10, 15, 15, 1.0),
  dialogTheme: DialogTheme().copyWith(
      backgroundColor: Color.fromRGBO(10, 15, 15, 1.0),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600),
      contentTextStyle: TextStyle(
          fontFamily: 'Inter-Medium',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  // textSelectionTheme: TextSelectionThemeData().copyWith(
  //   cursorColor: Colors.white.withOpacity(0.5),
  // ),
  inputDecorationTheme: InputDecorationTheme().copyWith(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromRGBO(45, 194, 98, 1.0),
      ),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(
      color: Colors.grey,
      width: 2,
    ),
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.grey;
      } else {
        return Colors.black;
      }
    }),
    checkColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.black;
      } else {
        return Colors.grey;
      }
    }),
  ),
);

TextTheme _buildTextTheme(Color textColor) {
  return TextTheme().copyWith(
      headline4: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter-SemiBold',
      ),
      headline5: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter-SemiBold',
      ),
      headline6: TextStyle(
          color: textColor,
          fontSize: 18,
          fontFamily: 'Inter-Medium',
          fontWeight: FontWeight.w600),
      subtitle1: TextStyle(
          color: textColor,
          fontFamily: 'Inter-Medium',
          fontSize: 16,
          fontWeight: FontWeight.w500),
      bodyText1: TextStyle(
          fontFamily: 'Inter-Medium',
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w400),
      caption: TextStyle(
        color: textColor.withOpacity(0.6),
        fontSize: 14,
      ),
      overline: TextStyle(
        color: textColor.withOpacity(0.8),
        fontSize: 12,
      ));
}

OutlinedButtonThemeData _outlinedButtonThemeData(
    {Color bgDisabled, Color bgEnabled, Color fgDisabled, Color fgEnabled}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(50, 16, 50, 16),
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter-SemiBold',
        fontSize: 18,
      ),
    ).copyWith(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return bgDisabled;
          }
          return bgEnabled;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return fgDisabled;
          }
          return fgEnabled;
        },
      ),
      alignment: Alignment.center,
    ),
  );
}

class EnteApp extends StatefulWidget {
  static const _homeWidget = HomeWidget();

  final Future<void> Function(String) runBackgroundTask;
  final Future<void> Function(String) killBackgroundTask;

  EnteApp(
    this.runBackgroundTask,
    this.killBackgroundTask, {
    Key key,
  }) : super(key: key);

  @override
  _EnteAppState createState() => _EnteAppState();
}

class _EnteAppState extends State<EnteApp> with WidgetsBindingObserver {
  final _logger = Logger("EnteAppState");

  @override
  void initState() {
    _logger.info('init App');
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _configureBackgroundFetch();
  }

  Widget debugBuild(BuildContext context) {
    return MaterialApp(
      title: "ente",
      themeMode: ThemeMode.system,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      home: EnteApp._homeWidget,
      debugShowCheckedModeBanner: false,
      navigatorKey: Network.instance.getAlice().getNavigatorKey(),
      builder: EasyLoading.init(),
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode && Platform.isIOS) {
      return debugBuild(context);
    }
    return AdaptiveTheme(
        light: lightThemeData,
        dark: darkThemeData,
        initial: AdaptiveThemeMode.dark,
        builder: (lightTheme, dartTheme) => MaterialApp(
              title: "ente",
              themeMode: ThemeMode.system,
              theme: lightTheme,
              darkTheme: dartTheme,
              home: EnteApp._homeWidget,
              debugShowCheckedModeBanner: false,
              navigatorKey: Network.instance.getAlice().getNavigatorKey(),
              builder: EasyLoading.init(),
              supportedLocales: L10n.all,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
            ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final String stateChangeReason = 'app -> $state';
    if (state == AppLifecycleState.resumed) {
      AppLifecycleService.instance
          .onAppInForeground(stateChangeReason + ': sync now');
      SyncService.instance.sync();
    } else {
      AppLifecycleService.instance.onAppInBackground(stateChangeReason);
    }
  }

  void _configureBackgroundFetch() {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          forceAlarmManager: false,
          stopOnTerminate: false,
          startOnBoot: true,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE,
        ), (String taskId) async {
      await widget.runBackgroundTask(taskId);
    }, (taskId) {
      _logger.info("BG task timeout taskID: $taskId");
      widget.killBackgroundTask(taskId);
    }).then((int status) {
      _logger.info('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      _logger.info('[BackgroundFetch] configure ERROR: $e');
    });
  }
}
