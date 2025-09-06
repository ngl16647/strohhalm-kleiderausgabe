import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:toastification/toastification.dart';

import 'generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  final Function(Color color) changeColor;

  const SettingsPage({
    super.key,
    required this.changeColor
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences pref;
  File? bannerImage;
  Color selectedColor = Color.fromRGBO(169, 171, 25, 1.0);
  final TextEditingController serverController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  bool obscurePassword = true;
  bool isSocket = false;
  bool darkMode = false;
  bool useServer = false;

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      final image = await decodeImageFromList(await pickedFile.readAsBytes());
      final aspectRatio = image.width / image.height;
      if (aspectRatio < 6) {
        if(!context.mounted) return;
        Utilities().showToast(context: context, title: "Wrong Aspect Ratio", description: "Image Aspectratio is to small, should be at least 6:1", isError: true);
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final bannerDir = Directory(join(appDir.path,"bannerImages"));
      if (!(await bannerDir.exists())) {
        await bannerDir.create(recursive: true);
      }

      final fileName = pickedFile.uri.pathSegments.last;
      final savedImage = await pickedFile.copy(join(bannerDir.path,fileName));

      setState(() {
        bannerImage = savedImage;
      });
    }
  }

  Future<void> _pickColor(BuildContext context) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = selectedColor;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          title: Text("Farbe auswählen"),
          content: SingleChildScrollView(
            child: ColorPicker(
              hexInputBar: true,
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:  Text(S.of(context).cancel)),
            TextButton(
                onPressed: () {
                  widget.changeColor(tempColor);
                  MyApp.of(context).changeSeedColor(tempColor);
                  Navigator.pop(context, tempColor);
                },
                child:  Text(S.of(context).confirm))
          ],
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedColor = picked;
      });
    }
  }

  Future<void> loadSettings() async {
    final settings = AppSettingsManager.instance.settings;
    bannerImage = settings.bannerImage;
    selectedColor = settings.selectedColor ?? Color.fromRGBO(169, 171, 25, 1.0);
    serverController.text = settings.url ?? "";
    tokenController.text = settings.token ?? "";
    isSocket = settings.isSocket ?? false;
    darkMode = settings.darkMode ?? false;
    useServer = settings.useServer ?? false;

    setState(() {});
  }

  Future<void> saveSettings() async {
    final manager = AppSettingsManager.instance;

    manager.setBannerImage(bannerImage);
    manager.setSelectedColor(selectedColor);
    manager.setServerUrl(serverController.text);
    manager.setToken(tokenController.text);
    //manager.setSerialPort(_selectedPort ?? "");
    manager.setScannerMode(isSocket);
    manager.setDarkMode(darkMode);
    manager.setUseServer(useServer);
    navigatorKey.currentState?.pop(true);
  }

  Widget createTitleWidget(String title, String toolTipDescription, BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium,),
        Tooltip(
          message: toolTipDescription,
          child: Icon(Icons.help_outline_rounded, size: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width*0.5 > 500 ? MediaQuery.of(context).size.width*0.5 : 500
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
          padding:  EdgeInsets.all(16.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Einstellungen",style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center,),
                    IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: Icon(Icons.close)
                    ),
                  ],
                ),
                Expanded(
                    child: ListView(
                      children: [
                        createTitleWidget("Theme-Mode",  "Bild das oben auf der Seite dargestellt wird", context),
                        SizedBox(height: 8),
                        Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).listTileTheme.tileColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Text("Dark-Mode"),
                                  Spacer(),
                                  Switch.adaptive(
                                      value: darkMode,
                                      onChanged: (ev){
                                        MyApp.of(context).changeTheme(ev ? ThemeMode.dark : ThemeMode.light);
                                        setState(() {
                                          darkMode = ev;
                                          pref.setBool("darkMode", darkMode);
                                        });
                                      })
                                ],
                              ),
                            )
                        ),
                        SizedBox(height:8),Divider(),SizedBox(height:8),
                        createTitleWidget("Banner / Bild (Aspect-Ratio > 6:1)", "Bild das oben auf der Seite dargestellt wird", context),
                        SizedBox(height: 8),
                        bannerImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(bannerImage!, fit: BoxFit.fitHeight),
                              )
                            :  Text("Kein Bild ausgewählt"),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(context),
                                label:  Text("Bild hochladen"),
                                icon: Icon(Icons.add_photo_alternate),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton.icon(
                                onPressed: ()async{
                                  final appDir = await getApplicationDocumentsDirectory();
                                  final bannerDir = Directory(join(appDir.path,"bannerImages"));
                                  if(!await bannerDir.exists()) return;
                                  final files = bannerDir.listSync().whereType<File>().toList();
                                  if(!context.mounted) return;
                                  final result = await showDialog<File?>(
                                      context: context,
                                      builder: (context){
                                        return Dialog(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width*0.6
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(padding: EdgeInsets.all(5),child: Align(
                                                alignment: AlignmentGeometry.centerRight,
                                                child: IconButton(
                                                    onPressed: Navigator.of(context).pop,
                                                    icon: Icon(Icons.close)),
                                              ),),
                                              Expanded(
                                                child: GridView.count(
                                                crossAxisCount: 2,
                                                childAspectRatio: 2,
                                                children: [
                                                  for(int i= 0; i < files.length; i++)...{
                                                    Padding(
                                                      padding: EdgeInsets.all(15),
                                                      child: Material(
                                                        elevation: 5,
                                                        borderRadius: BorderRadius.circular(6),
                                                        color: Theme.of(context).listTileTheme.tileColor,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            SizedBox(),
                                                            Padding(
                                                                padding: EdgeInsets.all(5),
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  child: FittedBox(
                                                                    fit: BoxFit.contain,
                                                                    child: Image.file(files.elementAt(i)),
                                                                  ),
                                                                )
                                                            ),
                                                            bannerImage == null || files[i].path != bannerImage!.path ? Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 3,
                                                                    child: TextButton.icon(
                                                                    onPressed: (){
                                                                      Navigator.of(context).pop(files.elementAt(i));
                                                                    },
                                                                    label: Text("Pick"),
                                                                    icon: Icon(Icons.hdr_auto_select),
                                                                    style: TextButton.styleFrom(
                                                                        minimumSize: Size(double.infinity, 32)
                                                                    ),
                                                                )),
                                                                IconButton(
                                                                    onPressed: (){
                                                                      files[i].delete();
                                                                      setState(() {
                                                                        files.removeAt(i);
                                                                      });
                                                                    },
                                                                    icon: Icon(Icons.delete),
                                                                ),
                                                              ],
                                                            ) : Padding(
                                                              padding: EdgeInsets.all(4),
                                                              child: Text("Currently Selected!"),
                                                            )

                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  }
                                                ],
                                              ),),
                                              TextButton(
                                                  onPressed: Navigator.of(context).pop,
                                                  style: TextButton.styleFrom(
                                                    minimumSize: Size(double.infinity, 42)
                                                  ),
                                                  child: Text(S.of(context).back),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                  if(result != null){
                                    setState(() {
                                      bannerImage = result;
                                    });
                                  }
                                },
                                label: Text("Vorherige Banner"),
                                icon: Icon(Icons.photo_album),
                              ),
                            ),
                            Expanded(
                                flex: 0,
                                child: IconButton(
                                  icon: Icon(Icons.delete,),
                                  onPressed: (){
                                    setState(() {
                                      bannerImage = null;
                                    });
                                  },
                                ))
                          ]
                        ),
                        SizedBox(height:8),Divider(),SizedBox(height:8),
                        createTitleWidget("Farbe", "Akzentfarbe für die Anwendung", context),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: selectedColor
                              ),
                              width: double.infinity,
                              height: 40,
                            ),),
                            SizedBox(width: 50),
                            ElevatedButton(
                                onPressed: () => _pickColor(context), child:  Text("Farbe wählen")),
                          ],
                        ),
                        SizedBox(height:8),Divider(),SizedBox(height:8),
                        Row(
                          children: [
                            Text("Server Einstellungen", style: Theme.of(context).textTheme.titleMedium),
                            Spacer(),
                            Text("Use Server?"),
                            SizedBox(width: 10,),
                            Switch(
                                value: useServer,
                                onChanged: (ev){
                                  setState(() {
                                    useServer = ev;
                                  });
                                }),
                            SizedBox(width: 15,),
                            Tooltip(
                              message: "Online verwenden?",
                              child: Icon(Icons.help_outline_rounded, size: 20,),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                       if(useServer) Column(
                          children: [
                            TextField(
                              controller: serverController,
                              decoration:  InputDecoration(
                                labelText: "Server URL / IP", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              obscureText: obscurePassword,
                              obscuringCharacter: "*",
                              controller: tokenController,
                              decoration: InputDecoration(
                                  labelText: "Token", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  suffixIcon: IconButton(
                                      onPressed: () => setState(() {
                                        obscurePassword = !obscurePassword;
                                      }),
                                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off)
                                  )
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: 20,),

                      ],
                    )
                ),
                ElevatedButton.icon(
                  onPressed: saveSettings,
                  icon:  Icon(Icons.save),
                  label:  Text("Speichern"),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity,   42)
                  ),
                )
              ],
            ),
          ),
    );
  }
}

class AppSettings{
  File? bannerImage;
  Color? selectedColor;
  String? url;
  String? token;
  bool? isSocket;
  bool? darkMode;
  bool? useServer;
  String? languageCode;

  AppSettings({
    this.bannerImage,
    this.selectedColor,
    this.url,
    this.token,
    this.isSocket,
    this.darkMode,
    this.useServer,
    this.languageCode,
  });

  @override
  String toString() {
    return "AppSettings("
        "\nbannerImage: ${bannerImage?.path}, "
        "\nselectedColor: $selectedColor, "
        "\nurl: $url, "
        "\ntoken: $token, "
        "\nisSocket: $isSocket, "
        "\ndarkMode: $darkMode, "
        "\nuseServer: $useServer, "
        "\nlanguageCode: $languageCode"
      ")";
  }
}

class AppSettingsManager {
  // Singleton
  AppSettingsManager._privateConstructor();
  static final AppSettingsManager instance = AppSettingsManager._privateConstructor();

  AppSettings? _settings;

  Future<void> load() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    File? bannerFile;
    if (pref.getString("bannerFileName") != null) {
      final fileName = pref.getString("bannerFileName");

      if (fileName != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final bannerDir = join(appDir.path, "bannerImages");
        bannerFile = File(join(bannerDir, fileName));

        if (!await bannerFile.exists()) {
          bannerFile = null;
        }
      }
    }

    Color selectColor = Color.fromRGBO(169, 171, 25, 1.0);
    if (pref.getInt("selectedColor") != null) {
      selectColor = Color(pref.getInt("selectedColor")!);
    }

    _settings = AppSettings(
      bannerImage: bannerFile,
      selectedColor: selectColor,
      url: pref.getString("serverUrl"),
      token: pref.getString("servertoken"),
      isSocket: pref.getBool("scannerMode"),
      darkMode: pref.getBool("darkMode"),
      useServer: pref.getBool("useServer"),
      languageCode: pref.getString("languageCode")
    );
  }

  AppSettings get settings {
    if (_settings == null) throw Exception("Settings not loaded. Call load() first.");
    return _settings!;
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
    _settings?.token = token;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("servertoken", token);
  }

  Future<void> setBannerImage(File? banner) async {
    _settings?.bannerImage = banner;
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
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("languageCode", langCode);
  }
}

/* TODO: If scannerType has to be selected/COM-port manually set
   SizedBox(height:8),Divider(),SizedBox(height:8),
   Text("Scanner", style: Theme.of(context).textTheme.titleMedium),
   SizedBox(height: 8),
   Container(
       decoration: BoxDecoration(
         color: Theme.of(context).listTileTheme.tileColor,
         borderRadius: BorderRadius.circular(12),
       ),
       child: Padding(
         padding: EdgeInsets.all(5),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Row(
               children: [
                 Text("Scanner-Mode"),
                 Spacer(),
                 Text(isSocket ? "Socket" : "HDI"),
                 SizedBox(width: 10,),
                 Switch(
                     value: isSocket,
                     onChanged: (value){
                       setState(() {
                         isSocket = value;
                       });
                       //print(SerialPort(SerialPort.availablePorts.first).productName);
                     })
               ],
             ),
             if(isSocket) Flexible(
                 child: RadioGroup(
                     onChanged: (ev){
                       print(ev);
                       setState(() {
                         _selectedPort = ev;
                       });
                     },
                     groupValue: _selectedPort,
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         for (final portName in SerialPort.availablePorts)
                           RadioListTile<String>(
                             title: Text("${SerialPort(portName).productName ?? "Kein Name"} ($portName)"),
                             value: portName,
                           ),
                       ],
                     ))
             )
           ],
         )
         ,
       )
   ),*/