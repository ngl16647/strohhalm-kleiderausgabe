import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:strohhalm_app/main_page.dart';
import 'package:window_manager/window_manager.dart';

import 'generated/l10n.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
enum DeviceType { mobile, desktop, web }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await windowManager.ensureInitialized();

    WindowOptions options = const WindowOptions(
      title: "Strohhalm Kleiderausgabe",
      minimumSize: Size(600, 800),
      center: true,
    );

    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;

  DeviceType getDeviceType() {
    if (kIsWeb) {
      return DeviceType.web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return DeviceType.mobile;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return DeviceType.desktop;
      default:
        return DeviceType.mobile; // Fallback
    }
  }
}

class MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Locale? getLocale() => _locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Strohhalm Kleiderausgabe",
      navigatorKey: navigatorKey,
      locale: _locale,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en", ""),
        Locale("de", ""),
        Locale("ru", ""),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.limeAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: CupertinoColors.lightBackgroundGray,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          margin: EdgeInsets.all(8),
          elevation: 1,
        ),
        listTileTheme: ListTileThemeData(
          tileColor: Colors.white,
          textColor: Colors.black87,
          iconColor: Colors.black54,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.limeAccent,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.blueGrey[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey[800],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.blueGrey[800],
            margin: EdgeInsets.all(8),
            elevation: 1,
          ),
          listTileTheme: ListTileThemeData(
            tileColor: Colors.blueGrey[800],
            textColor: Colors.white70,
            iconColor: Colors.white70,
          ),
      ),
      themeMode: themeMode,
      home: MainPage(
        onLocaleChange: setLocale,
      )
    );
  }

  void changeTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }
}


