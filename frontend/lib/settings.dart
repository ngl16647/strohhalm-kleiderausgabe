import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:strohhalm_app/main.dart';
import 'app_settings.dart';
import 'banner_designer.dart';
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
    _tokenController.text = settings.token ?? "";
    _darkMode = settings.darkMode ?? false;
    _useServer = settings.useServer ?? false;
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
    manager.setToken(_tokenController.text);
    manager.setDarkMode(_darkMode);
    manager.setUseServer(_useServer);

    _bannerDesignerKey.currentState?.saveBanner();

    Navigator.of(context).pop(true);
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
                      SizedBox(height:8),Divider(),SizedBox(height:8),
                      createTitleWidget(
                        title :  S.of(context).settings_banner_title,
                        toolTipDescription : S.of(context).settings_banner_desc,
                        context :context,
                      ),
                      SizedBox(height: 10,),
                      designer,
                      SizedBox(height:8),Divider(),SizedBox(height:8),
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
                                onPressed: () => _pickColor(context), child:  Text( S.of(context).settings_pick_Color)),
                          ],
                        ),
                      ),
                      SizedBox(height:8),Divider(),SizedBox(height:8),
                      createTitleWidget(
                        title : S.of(context).settings_server_title,
                        toolTipDescription : S.of(context).settings_server_desc,
                        context :context,
                        switchDescription:  S.of(context).settings_server_switch,
                        switchBool: _useServer,
                        switchChanged: (ev) => setState(() {
                          _useServer = ev;
                        }),
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
                              decoration:  InputDecoration(
                                labelText:  S.of(context).settings_server_urlHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              obscureText: _obscurePassword,
                              obscuringCharacter: "*",
                              controller: _tokenController,
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
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
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
}
