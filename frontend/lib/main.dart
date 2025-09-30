import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:strohhalm_app/main_page.dart';
import 'package:window_manager/window_manager.dart';
import 'check_connection.dart';
import 'generated/l10n.dart';

///Main with system-variables, themes, etc.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late final ConnectionProvider connectionProvider;
enum DeviceType { mobile, desktop, web }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  connectionProvider = ConnectionProvider();


  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await windowManager.ensureInitialized();

    WindowOptions options = WindowOptions(
      title: "Besucher Check-In",
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

  runApp(
    ChangeNotifierProvider.value(
      value: connectionProvider,
      child: const MyApp(),
    ),
  );
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
  Color seedColor = Colors.limeAccent;
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
      title: "Besucher Check-In", //TODO: Change to Strohhalm for their version
      navigatorKey: navigatorKey,
      locale: _locale,
      localizationsDelegates: [
        S.delegate,
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en", ""),
        Locale("de", ""),
        //Locale("ru", ""),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white70,
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: seedColor.withAlpha(110),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: seedColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            //backgroundColor: seedColor.withAlpha(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            //foregroundColor: seedColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      themeMode: themeMode,
      home: ConnectionToastListener(
          child: MainPage(
            onLocaleChange: setLocale,
          )
      )
    );
  }

  ///Changes the overall accentColor of the Application
  void changeSeedColor(Color color){
    setState(() {
      seedColor = color;
    });
  }

  ///Sets the dark/lightMode
  void changeTheme(ThemeMode theme) {
    setState(() {
      themeMode = theme;
    });
  }
}


