import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:strohhalm_app/dialog_helper.dart';
import 'package:strohhalm_app/export_csv.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/main.dart';
import 'app_settings.dart';
import 'banner_designer.dart';
import 'check_connection.dart';
import 'database_helper.dart';
import 'generated/l10n.dart';

///Settings Page
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
  BannerDesigner _designer = BannerDesigner(useDesigner: true);
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Color _selectedColor = Color.fromRGBO(169, 171, 25, 1.0);
  bool _obscurePassword = true;
  bool _darkMode = false;
  bool _useServer = false;
  bool _isMobile = false;

  bool _allowDeleting = false;
  bool _allowAdding = false;
  TextEditingController daysCheckTextController = TextEditingController();

  bool _serverSettingsAreSetAndSame = false;
  bool _localDbIsEmpty = false;
  bool _onlineDbIsEmpty = false;
  bool _onlineIsLoading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    loadSettings();
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    super.initState();
  }

  ///Gets all Settings from the singleton and applies relevant ones
  Future<void> loadSettings() async {
    final settings = AppSettingsManager.instance.settings;

    _selectedColor = settings.selectedColor ?? Color.fromRGBO(169, 171, 25, 1.0);
    _serverController.text = settings.url ?? "";
    _tokenController.text = AppSettingsManager.instance.authToken ?? "" ;
    _darkMode = settings.darkMode ?? false;
    _useServer = settings.useServer ?? false;
    if(_useServer){
      checkServerSettings();
      var customers = await HttpHelper().searchCustomers(query: "", size: 1); //Also checks if connection exists
      _onlineDbIsEmpty = customers == null || customers.isEmpty;
    }else{
      var customersLocal = await DatabaseHelper().countAllUsers();
      _localDbIsEmpty = customersLocal == 0;
    }
     var useBannerDesigner = settings.useBannerDesigner ?? true;
     var bannerWholeImage = settings.bannerSingleImage;
     var bannerDesignerImage = settings.bannerDesignerImageContainer;

     _designer = BannerDesigner(
         key: _bannerDesignerKey,
         useDesigner: useBannerDesigner,
         bannerDesignerImage: bannerDesignerImage,
         wholeBannerImage: bannerWholeImage,
     );

     _allowAdding = settings.allowAdding ?? false;
     _allowDeleting = settings.allowDeleting ?? false;
     daysCheckTextController.text = settings.cutOffDayNumber?.toString() ?? "14";
      setState(() {});
  }

  ///Saves all settings
  Future<void> saveSettings() async {

    final manager = AppSettingsManager.instance;
    manager.setSelectedColor(_selectedColor);
    manager.setServerUrl(_serverController.text);
    await manager.setToken(_tokenController.text);
    manager.setDarkMode(_darkMode);
    manager.setUseServer(_useServer);

    manager.setAllowAdding(_allowAdding);
    manager.setAllowDeleting(_allowDeleting);
    manager.setCutOffDays(int.parse(daysCheckTextController.text));

    _bannerDesignerKey.currentState?.saveBanner();

    if(mounted) Navigator.of(context).pop(true);
  }

  ///Creates the Header/Headline for the Divided Options
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

  ///Opens a colorPicker and sets the selectedColor. (Doesn't get saved yet)
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

  ///Displays Settings as page or Dialog depending on device
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
      padding:  EdgeInsets.only(left: 6, top: 6, bottom: 6, right: 6),
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
                    padding: EdgeInsets.only(right: 15, left: 15),
                    children: [
                      /*createTitleWidget(
                        title :  "kontroll-Variabeln",
                        toolTipDescription :  "Variabeln für die steuerung der Kontrollen",
                        context :context),
                      SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).listTileTheme.tileColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: 1000,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: daysCheckTextController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: S.of(context).day_cutoff,
                                      suffixText: S.of(context).days,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  flex: 2,
                                    child: Row(
                                  children: [
                                    Text(S.of(context).allow_Deleting, softWrap: true,),
                                    Switch(
                                        value: _allowDeleting,
                                        onChanged: (ev){
                                          setState(() {
                                            _allowDeleting = ev;
                                          });
                                        }),
                                  ],
                                )),
                                SizedBox(width: 8,),
                                Expanded(
                                    flex: 2,
                                    child: Row(
                                  children: [
                                    Text(S.of(context).allow_Adding, softWrap: true,),
                                    Switch(
                                        value: _allowAdding,
                                        onChanged: (ev){
                                          setState(() {
                                            _allowAdding = ev;
                                          });
                                        })
                                  ],
                                ))
                              ],
                            ),
                          )
                      ),
                      Divider(),*/
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
                                Text(S.of(context).dark_mode),
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
                        child:  _designer,),
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
                            bool? confirmation = await DialogHelper.dialogConfirmation(
                                context: context,
                                message: S.of(context).settings_switchWarningMessage,
                                hasChoice: true);
                            if(confirmation != null && confirmation){
                              setState(() => _useServer = ev);
                              if(!_useServer){
                                var customersLocal = await DatabaseHelper().countAllUsers();
                                setState(() {
                                  _localDbIsEmpty = customersLocal == 0;
                                });
                              }
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
                            /*Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if(!serverSettingsAreSetAndSame)ElevatedButton(
                                  onPressed: () async {
                                    saveSettingsForServerRequests();
                                  },
                                  child: Text(S.of(context).settings_saveServerSettings, textAlign: TextAlign.center,),
                                ),
                                if(!onlineIsLoading && serverSettingsAreSetAndSame && context.watch<ConnectionProvider>().status == ConnectionStatus.connected) ElevatedButton(
                                    onPressed: ()async{
                                      await DataBaseExportFunctions.importCSV(context);
                                    },
                                    child: Text(S.of(context).settings_downloadFromServer)
                                ),
                                if(onlineIsLoading) Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator())),
                                if(context.watch<ConnectionProvider>().status != ConnectionStatus.connected && serverSettingsAreSetAndSame) Text(S.of(context).settings_noConnection, textAlign: TextAlign.center,)
                              ],
                            )*/
                          ],
                        ),
                      ),
                      Divider(height: 16),
                      createTitleWidget(
                          title : S.of(context).settings_exportCsvFile,
                          toolTipDescription : S.of(context).settings_exportCsvDescription,
                          context :context),
                      SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).listTileTheme.tileColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(maxHeight: 150),
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: !_useServer
                                ? ///Local options
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            if(!_localDbIsEmpty)Expanded(child: Tooltip(
                                              message: S.of(context).settings_exportToolTip,
                                              child: ElevatedButton(
                                                  onPressed: () => DataBaseExportFunctions.saveCsv(context: context,
                                                      useServer: false,
                                                      detailedCSV: true),
                                                  child: Text(S.of(context).settings_exportCsvLocal)),
                                            ),),
                                            //if(!localDbIsEmpty)Spacer(),
                                            //SizedBox(width: 15,),
                                            //if(!localDbIsEmpty)Expanded(child: Tooltip(
                                            //    message: S.of(context).settings_exportToolTip,
                                            //    child: ElevatedButton(
                                            //        onPressed: () => DataBaseExportFunctions.saveCsv(
                                            //            context: context,
                                            //            useServer: false,
                                            //            detailedCSV: true),
                                            //        child: Text(S.of(context).settings_exportDetailedCsvLocal))),),
                                            if(_localDbIsEmpty)Expanded(
                                                child: Tooltip(
                                                  message: S.of(context).settings_importCsvToolTip,
                                                  child: ElevatedButton.icon(
                                                      icon: Icon(Symbols.database_upload_rounded),
                                                      onPressed: () async {
                                                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                          dialogTitle: S.of(context).settings_exportCsvDialogTitle,
                                                          allowedExtensions: ["csv"],
                                                        );
                                                        if (result != null && result.files.single.path != null) {
                                                          File csvFile = File(result.files.single.path!);

                                                          if(context.mounted) {
                                                            DataBaseExportFunctions().importCSV(
                                                                context,
                                                                csvFile,
                                                                    (progress) async {
                                                                  setState(() {
                                                                    _uploadProgress = progress;
                                                                  });
                                                                  if(_uploadProgress == 100){
                                                                    var customersLocal = await DatabaseHelper().countAllUsers();
                                                                    setState(() => _localDbIsEmpty = customersLocal == 0);
                                                                  }
                                                                });
                                                          }
                                                        }
                                                      },
                                                      label: Text(S.of(context).settings_importCsv, overflow: TextOverflow.ellipsis,)
                                                  )
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                      if(_uploadProgress != 0) Padding(
                                        padding: EdgeInsets.all(5),
                                        child: SizedBox(
                                          height: 25,
                                          width: double.infinity,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              LinearProgressIndicator(
                                                value: _uploadProgress/100, // 0.0 bis 1.0
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.teal,
                                                backgroundColor: Colors.grey[300],
                                                minHeight: 20,
                                              ),
                                              Text(
                                                "${(_uploadProgress).toStringAsFixed(0)}%", // Prozentzahl
                                                style: TextStyle(
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        ),
                                      )
                                    ],
                                  )
                                : ///Server options
                                  Row(
                                    children: [
                                      ///Everything loaded and connected
                                      if (!_onlineIsLoading
                                          && _serverSettingsAreSetAndSame
                                          && _useServer
                                          && context.watch<ConnectionProvider>().status == ConnectionStatus.connected) ...[
                                        if(!_onlineDbIsEmpty)Expanded(
                                          child: Tooltip(
                                            message: S.of(context).settings_exportLessDetailsToolTip,
                                            child: ElevatedButton(
                                              onPressed: () => DataBaseExportFunctions.saveCsv(
                                                context: context,
                                                useServer: true,
                                              ),
                                              child: _onlineIsLoading
                                                  ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(),
                                              )
                                                  : Text(S.of(context).settings_exportCsvFromServer),
                                            ),
                                          ),
                                        ),
                                        if (_onlineDbIsEmpty)
                                          Expanded(
                                            child: Tooltip(
                                              message: S.of(context).settings_uploadCsvToServerToolTip,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final result = await FilePicker.platform.pickFiles(
                                                    dialogTitle: S.of(context).settings_importCsv,
                                                    allowedExtensions: ["csv"],
                                                  );

                                                  if (result != null && result.files.single.path != null) {
                                                    final csvFile = File(result.files.single.path!);
                                                    String csvString = await csvFile.readAsString();
                                                    String converted = DataBaseExportFunctions().convertToRight(csvString);
                                                    final convertedFile = File("${csvFile.parent.path}/converted.csv");
                                                    await convertedFile.writeAsString(converted, encoding: utf8);

                                                    await HttpHelper().uploadCsv(convertedFile);

                                                    convertedFile.delete();
                                                  }
                                                },
                                                child: Text(S.of(context).settings_uploadCsvToServer),
                                              ),
                                            )
                                          )
                                      ]
                                      ///Settings not saved
                                      else if (_useServer && !_serverSettingsAreSetAndSame) ...[
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: saveSettingsForServerRequests,
                                            child: Text(
                                              S.of(context).settings_saveServerSettings,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                      //Is loading
                                      if (_onlineIsLoading)
                                        const Expanded(
                                          child: Center(
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      //No connection
                                      if (_useServer &&
                                          _serverSettingsAreSetAndSame &&
                                          context.watch<ConnectionProvider>().status != ConnectionStatus.connected)
                                        Expanded(
                                          child: Text(
                                            S.of(context).settings_noConnection,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
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
                minimumSize: Size(double.infinity, 42)
            ),
          )
        ],
      ),
    );
  }

  ///Saves only the Server-Settings when turning on the useServer-Option
  Future<void> saveSettingsForServerRequests() async {
    setState(() => _onlineIsLoading = true);
    var manager = AppSettingsManager.instance;
    manager.setServerUrl(_serverController.text);
    await manager.setToken(_tokenController.text);
    manager.setUseServer(_useServer);

    checkServerSettings();
    if(mounted) {
      ConnectionStatus status = await context.read<ConnectionProvider>().checkConnection();
      if(status == ConnectionStatus.connected){
        var customers = await HttpHelper().searchCustomers(query: "", size: 1);
        _onlineDbIsEmpty = customers == null || customers.isEmpty;
      } else if(mounted){
        context.read<ConnectionProvider>().periodicCheckConnection();
      }
    }
    setState(() => _onlineIsLoading = false);
  }

  ///Checks if Server-Settings have been changed before taking actions
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
     _serverSettingsAreSetAndSame = settingsWereSet && !settingsHaveChanged;
   });
  }
}
