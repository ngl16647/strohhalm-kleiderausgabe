import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:strohhalm_app/dialog_helper.dart';
import 'package:strohhalm_app/export_csv.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/main.dart';
import 'app_settings.dart';
import 'banner_designer.dart';
import 'check_connection.dart';
import 'generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  final Function(Color color) changeColor;

  static Future<bool?> showSettingsAsDialog({
    required BuildContext context,
    required Function(Color color) changeColor
  }) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context){
          return  SettingsPage(changeColor: changeColor,);
        });
  }

  const SettingsPage({
    super.key,
    required this.changeColor
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<BannerDesignerState> _bannerDesignerKey = GlobalKey();
  BannerDesigner designer = BannerDesigner(useDesigner: true);
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Color _selectedColor = Color.fromRGBO(169, 171, 25, 1.0);
  bool _obscurePassword = true;
  bool _darkMode = false;
  bool _useServer = false;
  bool _isMobile = false;

  bool? isOnline;
  bool serverSettingsAreSetAndSame = false;
  //bool localDbIsEmpty = false;
  bool onlineDbIsEmpty = false;

  @override
  void initState() {
    loadSettings();
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    super.initState();
  }

  Future<void> loadSettings() async {
    final settings = AppSettingsManager.instance.settings;

    _selectedColor = settings.selectedColor ?? Color.fromRGBO(169, 171, 25, 1.0);
    _serverController.text = settings.url ?? "";
    _tokenController.text = AppSettingsManager.instance.authToken ?? "" ;
    _darkMode = settings.darkMode ?? false;
    _useServer = settings.useServer ?? false;
    if(_useServer){
      checkServerSettings();
      //TODO: Check If either database is empty
      var customers = await HttpHelper().searchCustomers(query: ""); //Also checks if connection exists
      onlineDbIsEmpty = customers == null || customers.isEmpty;
      //var customersLocal = await DatabaseHelper().countAllUsers();
      //localDbIsEmpty = customersLocal == 0;
    }
     var useBannerDesigner = settings.useBannerDesigner ?? true;
     var bannerWholeImage = settings.bannerSingleImage;
     var bannerDesignerImage = settings.bannerDesignerImageContainer;

     designer = BannerDesigner(
         key: _bannerDesignerKey,
         useDesigner: useBannerDesigner,
         bannerDesignerImage: bannerDesignerImage,
         wholeBannerImage: bannerWholeImage,
     );
    setState(() {});
  }

  Future<void> saveSettings() async {

    final manager = AppSettingsManager.instance;
    manager.setSelectedColor(_selectedColor);
    manager.setServerUrl(_serverController.text);
    await manager.setToken(_tokenController.text);
    manager.setDarkMode(_darkMode);
    manager.setUseServer(_useServer);

    _bannerDesignerKey.currentState?.saveBanner();

    if(mounted) Navigator.of(context).pop(true);
  }

  Widget createTitleWidget({
    required String title,
    required String toolTipDescription,
    required BuildContext context,
    String? switchDescription,
    bool? switchBool,
    Function(bool)? switchChanged,
  }) {
    final switchWidget = (switchBool != null)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isMobile && switchDescription != null) Text(switchDescription),
              Switch(value: switchBool, onChanged: switchChanged, padding: EdgeInsets.symmetric(horizontal: 10),),
            ],
          )
        : SizedBox.shrink();

    final titleRow = Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Spacer(),
        if (!_isMobile) switchWidget,
        Tooltip(
          message: toolTipDescription,
          child: Icon(Icons.help_outline_rounded, size: 20),
        ),
      ],
    );

    if (_isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          if (switchBool != null) Row(
            children: [
              if (switchDescription != null) Text(switchDescription),
              Spacer(),
              switchWidget,
            ],
          ),
        ],
      );
    }

    return titleRow;
  }

  Future<void> _pickColor(BuildContext context) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = _selectedColor;
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
          ),
          title: Text(S.of(context).settings_pick_Color),
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
        _selectedColor = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isMobile
        ? Dialog(
            constraints:  BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.5 > 500 ? MediaQuery.of(context).size.width*0.5 : 500
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            child: pageContent(context),
        ).animate().slideY(duration: 300.ms, begin: 0.2).fadeIn(duration: 300.ms)
        : Scaffold(
            appBar: AppBar(
              title: Text( S.of(context).settings),
            ),
            body: pageContent(context),
        );
  }

  ///Contains the actual content. So Desktop can use Dialog, mobile can use own page
  Widget pageContent(BuildContext context){
    return Padding(
      padding:  EdgeInsets.only(left: 16.0, top: 6, bottom: 6, right: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(!_isMobile)Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text( S.of(context).settings,style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center,),
              IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: Icon(Icons.close)
              ),
            ],
          ),
          Expanded(
              child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  controller: _scrollController,
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(right: 20),
                    children: [
                      createTitleWidget(
                          title :  S.of(context).settings_themeMode_Title,
                          toolTipDescription :  S.of(context).settings_themeMode_desc,
                          context :context),
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
                                Switch(
                                    value: _darkMode,
                                    onChanged: (ev){
                                      MyApp.of(context).changeTheme(ev ? ThemeMode.dark : ThemeMode.light);
                                      setState(() {
                                        _darkMode = ev;
                                        AppSettingsManager.instance.setDarkMode(_darkMode);
                                      });
                                    })
                              ],
                            ),
                          )
                      ),
                      Divider(height: 16),
                      createTitleWidget(
                        title :  S.of(context).settings_banner_title,
                        toolTipDescription : S.of(context).settings_banner_desc,
                        context :context,
                      ),
                      SizedBox(height: 10,),
                      Container(
                        height: 200,
                        constraints: BoxConstraints(
                          minHeight: 200,
                          maxHeight: 300
                        ),
                        child:  designer,),
                      Divider(height: 16),
                      createTitleWidget(
                          title :  S.of(context).settings_color_title,
                          toolTipDescription : S.of(context).settings_color_desc,
                          context :context),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).listTileTheme.tileColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: _selectedColor
                              ),
                              width: double.infinity,
                              height: 40,
                            ),),
                            SizedBox(width: 50),
                            ElevatedButton(
                                onPressed: () => _pickColor(context),
                                child:  Text( S.of(context).settings_pick_Color)),
                          ],
                        ),
                      ),
                      Divider(height: 16),
                      createTitleWidget(
                        title : S.of(context).settings_server_title,
                        toolTipDescription : S.of(context).settings_server_desc,
                        context :context,
                        switchDescription:  S.of(context).settings_server_switch,
                        switchBool: _useServer,
                        switchChanged: (ev) async {
                            bool? confirmation = await DialogHelper.dialogConfirmation(context, "Server und Lokal sind zwei getrennte Datenbanken!\nBist du sicher, dass du umschalten willst?", true);
                            if(confirmation != null && confirmation){
                              setState(() => _useServer = ev);
                            }
                        },
                      ),
                      SizedBox(height: 16),
                      if(_useServer) Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).listTileTheme.tileColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            TextField(
                              controller: _serverController,
                              onChanged: (ev) => checkServerSettings(),
                              decoration:  InputDecoration(
                                labelText:  S.of(context).settings_server_urlHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              obscureText: _obscurePassword,
                              obscuringCharacter: "*",
                              controller: _tokenController,
                              onChanged: (ev) => checkServerSettings(),
                              decoration: InputDecoration(
                                  labelText: S.of(context).settings_server_tokenHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  suffixIcon: IconButton(
                                      onPressed: () async {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off)
                                  )
                              ),
                            ),
                            SizedBox(height: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if(!serverSettingsAreSetAndSame)ElevatedButton(
                                  onPressed: () async {
                                    var manager = AppSettingsManager.instance;
                                    manager.setServerUrl(_serverController.text);
                                    await manager.setToken(_tokenController.text);
                                    manager.setUseServer(_useServer);

                                    checkServerSettings();
                                    var customers = await HttpHelper().searchCustomers(query: ""); //Also checks if connection exists
                                    onlineDbIsEmpty = customers == null || customers.isEmpty;
                                  },
                                  child: Text("Save Server-Settings before downloading", textAlign: TextAlign.center,),
                                ),
                                if(serverSettingsAreSetAndSame && context.watch<ConnectionProvider>().status == ConnectionStatus.connected) ElevatedButton(
                                    onPressed: ()async{
                                      await DataBaseExportFunctions.importCSVFromServer(context);
                                    },
                                    child: Text("Download from Server")
                                ),
                                if(context.watch<ConnectionProvider>().status != ConnectionStatus.connected) Text("No Connection!", textAlign: TextAlign.center,)
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(height: 16),
                      createTitleWidget(
                          title : "Export CSV-Datei",
                          toolTipDescription :  "Exportiere eine CSV-Datei (welche in z.B. Excel importiert werden kann)\nLokale und Server Datenbank sind NICHT kompatibel!",
                          context :context),
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
                                if(!_useServer)ElevatedButton(
                                    onPressed: () => DataBaseExportFunctions.saveCsv(context, false),
                                    child: Text("Export CSV local")),
                                if(serverSettingsAreSetAndSame &&  _useServer && context.watch<ConnectionProvider>().status == ConnectionStatus.connected)...{
                                  ElevatedButton(
                                      onPressed: () => DataBaseExportFunctions.saveCsv(context, true),
                                      child: Text("Export CSV from Server")),
                                  Spacer(),
                                  if(onlineDbIsEmpty)ElevatedButton(
                                    onPressed: ()async{
                                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                                        dialogTitle: "Daten als CSV exportieren",
                                        allowedExtensions: ["csv"],
                                      );

                                      if (result != null && result.files.single.path != null) {
                                        File csvFile = File(result.files.single.path!);
                                        await HttpHelper().uploadCsv(csvFile);
                                      }
                                    },
                                    child: Text("Upload CSV to server"),
                                  )
                                } else if(_useServer && !serverSettingsAreSetAndSame) ...{
                                  Expanded(child: ElevatedButton(
                                    onPressed: () async {
                                      var manager = AppSettingsManager.instance;
                                      manager.setServerUrl(_serverController.text);
                                      await manager.setToken(_tokenController.text);
                                      manager.setUseServer(_useServer);

                                      checkServerSettings();
                                      var customers = await HttpHelper().searchCustomers(query: ""); //Also checks if connection exists
                                      onlineDbIsEmpty = customers == null || customers.isEmpty;
                                  },
                                    child: Text("Save Server-Settings before\nyou can upload a CSV", textAlign: TextAlign.center,),
                                  )),
                                },
                                if(_useServer && context.watch<ConnectionProvider>().status != ConnectionStatus.connected) Expanded(child: Text("No Connection!", textAlign: TextAlign.center,))
                              ],
                            ),
                          )
                      ),
                    ],
                  )
              ),
          ),
          ElevatedButton.icon(
            onPressed: saveSettings,
            icon:  Icon(Icons.save),
            label:  Text(S.of(context).save),
            style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity,   42)
            ),
          )
        ],
      ),
    );
  }

  void checkServerSettings() {
    bool settingsHaveChanged = false;
    bool settingsWereSet = AppSettingsManager.instance.settings.url != null
        && AppSettingsManager.instance.settings.url!.isNotEmpty
            && AppSettingsManager.instance.authToken != null
            && AppSettingsManager.instance.authToken!.isNotEmpty;

   if(settingsWereSet){
     settingsHaveChanged = AppSettingsManager.instance.settings.url! != _serverController.text || AppSettingsManager.instance.authToken != _tokenController.text;
   }

   setState(() {
     serverSettingsAreSetAndSame = settingsWereSet && !settingsHaveChanged;
     if(!serverSettingsAreSetAndSame) isOnline = null;
   });
  }
}
