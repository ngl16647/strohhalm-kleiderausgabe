import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strohhalm_app/banner_designer.dart';
import 'package:toastification/toastification.dart';

class AppSettings{
  File? bannerSingleImage;
  Color? selectedColor;
  String? url;
  bool? isSocket;
  bool? darkMode;
  bool? useServer;
  String? languageCode;
  BannerImage? bannerDesignerImageContainer; //Here with full-Path
  bool? useBannerDesigner;

  AppSettings({
    this.bannerSingleImage,
    this.selectedColor,
    this.url,
    this.isSocket,
    this.darkMode,
    this.useServer,
    this.languageCode,
    this.bannerDesignerImageContainer,
    this.useBannerDesigner
  });

  @override
  String toString() {
    return "AppSettings("
        "\nbannerImage: ${bannerSingleImage?.path}, "
        "\nselectedColor: $selectedColor, "
        "\nurl: $url, "
        "\nisSocket: $isSocket, "
        "\ndarkMode: $darkMode, "
        "\nuseServer: $useServer, "
        "\nlanguageCode: $languageCode,  "
        "\nlanguageCode: $bannerDesignerImageContainer"
        ")";
  }
}

class AppSettingsManager {
  AppSettingsManager._privateConstructor();
  static final AppSettingsManager instance = AppSettingsManager._privateConstructor();

  AppSettings? _settings;
  String? _cachedToken;

  Future<void> load() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final secureStorage = FlutterSecureStorage();
    final appDir = await getApplicationDocumentsDirectory();
    final bannerDir = join(appDir.path, "bannerImages");

    _cachedToken = await secureStorage.read(key: "auth_token");

    File? bannerFile;
    if (pref.getString("bannerFileName") != null) {
      final fileName = pref.getString("bannerFileName");

      if (fileName != null) {

        bannerFile = File(join(bannerDir, fileName));
        if (!await bannerFile.exists()) {
          bannerFile = null;
        }
      }
    }

    BannerImage? bannerImage;
    String? jsonBannerString = pref.getString("dynamicBanner");
    if(jsonBannerString != null && jsonBannerString.isNotEmpty){
      bannerImage = await BannerImage.fromJsonString(jsonBannerString);
    }

    Color selectColor = Color.fromRGBO(169, 171, 25, 1.0);
    if (pref.getInt("selectedColor") != null) {
      selectColor = Color(pref.getInt("selectedColor")!);
    }

    _settings = AppSettings(
        bannerSingleImage: bannerFile,
        selectedColor: selectColor,
        url: pref.getString("serverUrl"),
        //token: token,
        isSocket: pref.getBool("scannerMode"),
        darkMode: pref.getBool("darkMode"),
        useServer: pref.getBool("useServer"),
        languageCode: pref.getString("languageCode"),
        bannerDesignerImageContainer: bannerImage,
        useBannerDesigner: pref.getBool("useBannerDesigner")
    );
  }

  AppSettings get settings {
    if (_settings == null) throw Exception("Settings not loaded. Call load() first.");
    return _settings!;
  }

  String? get authToken {
    return _cachedToken;
  }

  Future<void> setUseServer(bool value) async {
    _settings?.useServer = value;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("useServer", value);
  }

  Future<void> setServerUrl(String url) async {
    _settings?.url = url;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("serverUrl", url);
  }

  Future<void> setToken(String token) async {
    final secureStorage = FlutterSecureStorage();
    _cachedToken = token;
    await secureStorage.write(key: "auth_token", value: token);
  }

  Future<void> setBannerImage(File? banner) async {
    _settings?.bannerSingleImage = banner;
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(banner == null) {
      pref.remove("bannerFileName");
      return;
    }
    await pref.setString("bannerFileName", banner.uri.pathSegments.last);
  }

  Future<void> setSelectedColor(Color color) async {
    _settings?.selectedColor = color;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt("selectedColor", color.intValue);
  }

  Future<void> setScannerMode(bool isSocket) async {
    _settings?.isSocket = isSocket;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("scannerMode", isSocket);
  }

  Future<void> setDarkMode(bool darkMode) async {
    _settings?.darkMode = darkMode;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("darkMode", darkMode);
  }

  Future<void> setLanguage(String langCode) async {
    _settings?.languageCode = langCode;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("languageCode", langCode);
  }

  Future<void> setBannerType(bool useBannerDesigner) async {
    _settings?.useBannerDesigner = useBannerDesigner;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("useBannerDesigner", useBannerDesigner);
  }

  Future<void> setDynamicBanner(BannerImage? bannerImage) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(bannerImage == null) {
      await pref.remove("dynamicBanner"); //Saving to sharedPref with only fileName
      _settings?.bannerDesignerImageContainer = null;
    } else {
      String bannerString = bannerImage.toJsonString();
      await pref.setString("dynamicBanner", bannerString); //Saving to sharedPref with only fileName

      _settings?.bannerDesignerImageContainer = bannerImage; //Map in Settings with fullPath
    }

  }

  Future<Map<String, String>> bannerNameMapToPathMap(Map<String, String> bannerMap) async {
    final appDir = await getApplicationDocumentsDirectory();
    final bannerDir = join(appDir.path, "bannerImages");
    if(bannerMap["imageLeft"] != null && bannerMap["imageLeft"]!.isNotEmpty) bannerMap["imageLeft"] = join(bannerDir, bannerMap["imageLeft"]);
    if(bannerMap["imageRight"] != null && bannerMap["imageRight"]!.isNotEmpty) bannerMap["imageRight"] = join(bannerDir, bannerMap["imageRight"]);

    return bannerMap;
  }
}