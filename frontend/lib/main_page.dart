import 'dart:io';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:strohhalm_app/add_user_dialog.dart';
import 'package:strohhalm_app/barcode_scanner_hardware_listener.dart';
import 'package:strohhalm_app/customer_tile.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/settings.dart';
import 'package:strohhalm_app/stat_page.dart';
import 'package:strohhalm_app/statistic_page.dart';
import 'package:strohhalm_app/user.dart';
import 'package:window_manager/window_manager.dart';
import 'barcode_scanner_phone_camera.dart';
import 'generated/l10n.dart';
import 'main.dart';

/* Overall TODO:
  - check everything in mobile and decide what to keep

 */

class MainPage extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  const MainPage({super.key, required this.onLocaleChange});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  late BarcodeScannerListener socketListener;
  List<User> _userList = [];
  Icon _fullScreenIcon = Icon(Icons.fullscreen);
  bool _isListView = true;
  bool _isMobile = false;
  bool _useServer = false;
  bool _blockScan = false;
  Color _selectedColor = Color.fromRGBO(169, 171, 25, 1.0);
  File? _bannerImage;

  @override
  void initState(){
    loadPage();
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    listenForScanner();

    super.initState();
  }

  void loadPage()async{
    loadSettings();
    if(_useServer){
      syncWithServer();
    }
  }

  Future<void> syncWithServer()async{
    await DatabaseHelper().uploadPendingUsers();
    await DatabaseHelper().updatePendingUsers();
    await DatabaseHelper().uploadPendingVisits();
  }

  Future<void> loadSettings() async {
    await AppSettingsManager.instance.load();
    var settings = AppSettingsManager.instance.settings;

    _useServer = settings.useServer ?? false;
    _selectedColor = settings.selectedColor ?? Color.fromRGBO(169, 171, 25, 1.0);
    _bannerImage = settings.bannerImage;
    String languageCode = settings.languageCode ?? "de";

    changeLanguage(languageCode);
    if(mounted){
      MyApp.of(context).changeSeedColor(_selectedColor);
      MyApp.of(context).changeTheme(settings.darkMode! ? ThemeMode.dark : ThemeMode.light);
    }
    setState(() {});
  }

  void listenForScanner(){
    //TODO: HID or COM-Serial
    // Pro HID:
    //   - simple, universal, works with the cheapest scanners
    //   - no drivers needed, plug-and-play
    //   - works consistently across OSes
    //   - Can be dis/reconnected and still works without additional logic
    // Con HID:
    //   - scanner "types" text into the currently active window → focus issues
    //   - keyboard layout must match between scanner and system
    // Pro COM(Serial):
    //   - precise control over incoming data (rawData), no layout issues, more control over results
    //   - can configure scanner via software (LED, beep, scan modes)
    // Con COM (Serial):
    //   - not all scanners support Serial/COM mode
    //   - more complex setup (drivers, baud rate, parity, platform-specific plugins)
    //   - need logic to recognise and act when devices lost/new connected
    void scanSuccess(scannedValue) async {
      openUserFromUuId(scannedValue);
    }

    void uuIdFail(){
      showDialog(context: context, builder: (context){
        return AlertDialog(
            content: Text("Failed UuId Check!\nMake sure your Keyboard-Language (Left-Alt + Left-Shift) is the same as the Barcode-Scanner!"),
            actions: [
              TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(S.of(context).accept))
            ]
        );
      });
    }

    socketListener = BarcodeScannerListener(
        context: context,
        onSuccessScan: scanSuccess,
        onFailedUuIdCheck: uuIdFail
    );
    if(!_isMobile) socketListener.listenForScan();
  }



  ///Gets Users with the firstName/Lastname LIKE the searchTerm. "*" gets all
  Future<void> searchUsers(String searchTerm) async {
    //TODO: Probably include a Search-Button, so there are less unnecessary server-requests
      _userList.clear();
      if(searchTerm.trim().isNotEmpty) { //WhiteSpaces get removed so a SPACE doesn't just retrieve All
        _userList = await DatabaseHelper().getUsers(search: searchTerm == "*" ? "" : searchTerm);
        //var result = await HttpHelper().searchCustomers(searchTerm == "*" ? "" : searchTerm);
        //if(result is List<User>){
        //  for(User u in _userList){
        //    print(u.toString());
        //  }
        //}
      }
    setState(() {
      _userList;
    });
  }

  ///Adds or edits a User (if you want to edit, you have to give it a existing User)
  Future<void> addOrEditUser([User? user]) async {
    _blockScan = true;
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddUserDialog(user: user);
        }
    );
    if(result != null){
      User? newUser = result[0];
      bool delete = result[1];

      if(delete) {
        await DatabaseHelper().deleteUser(newUser!.id);
        setState(() {
          _userList.removeWhere((listUser) => listUser.id == user?.id );
        });
      } else {
        //Here so there doesn't have to be a extra Call to the Database
        if(newUser != null) {
          int index = _userList.indexWhere((item) => item.id == newUser.id);
          if(index != -1){
            setState(() {
              _userList[index] = newUser;
            });
          } else {
            openUser(newUser);
          }
        }
      }
    }
    _blockScan = false;
  }

  Future<void> openStatPage(User user) async {
    _blockScan = true;
    List<TookItem>? updated = await showDialog<List<TookItem>>(
        context: context,
        builder: (context){
          return StatPage(user: user);
        });
    if(updated != null){
      int i = _userList.indexOf(user);
      setState(() {
        _userList[i] = user.copyWith(tookItems: updated); //new Objekt so the ListView can update through ObjectKey(user)
      });
    }
    _blockScan = false;
  }

  Future<void> openUserFromUuId(String uuIdString) async {
    if(_blockScan) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erfolgreich gescannt : $uuIdString")));
    User? user = await DatabaseHelper().getUsers(uuid: uuIdString).then((item) => item.first);
    if(user != null){
      openUser(user);
    } else {
      if(mounted) {
        showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                content: Text("${S.of(context).main_page_noUserWithUUID}:\n$uuIdString"),
                actions: [
                  TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(S.of(context).close))
                ],
              );
            });
      }
    }
  }

  void openUser(User user){
    _userList.clear();
    setState(() {
      _userList.add(user);
    });
    openStatPage(user);
    _searchController.text = "${user.firstName} ${user.lastName}";
  }

  Future<void> changeLanguage(String localeId) async {
    widget.onLocaleChange(Locale(localeId));
    AppSettingsManager.instance.setLanguage(localeId);
    // Warte auf rebuild
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      if (!mounted) return;
      await windowManager.setTitle(S.of(context).application_name);
      setState(() {});
    });
  }

  @override
  void dispose() {
    socketListener.dispose();
    super.dispose();
  }

  Widget _buildUserTile(User user, int index,bool isList) {
    return CustomerTile(
      isListView: isList,
      key: ObjectKey(user),
      user: user,
      click: () => openStatPage(user),
      delete: () async {
        await DatabaseHelper().deleteUser(user.id);
        setState(() {
          _userList.removeAt(index);
        });
      },
      update: () => addOrEditUser(user),
    ).animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.2, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    var languages = [
      LanguageOption(code: "de", label: S.of(context).language_de, onPressed: () => changeLanguage("de")),
      LanguageOption(code: "en", label: S.of(context).language_en, onPressed: () => changeLanguage("en")),
      LanguageOption(code: "ru", label: S.of(context).language_ru, onPressed: () => changeLanguage("ru")),
      //Here one can add new Languages if necessary (code = Country-Code from http://www.lingoes.net/en/translator/langcode.htm)
    ];
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(child: Padding(
        padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              if(_bannerImage != null) Image.file(_bannerImage!),
              Container(
                width: double.infinity, // Ensure finite width
                padding: EdgeInsets.symmetric(horizontal: 10 ,vertical: 0),
                child: Row(
                  spacing: 8,
                  children: [
                    if (!_isMobile)
                      ActionChip(
                        avatar: _fullScreenIcon,
                        label: Text(S.of(context).main_page_fullScreen),
                        onPressed: () async {
                          bool isFullScreen = await windowManager.isFullScreen();
                          windowManager.setFullScreen(!isFullScreen);
                          setState(() {
                            _fullScreenIcon = !isFullScreen
                                ? Icon(Icons.close_fullscreen)
                                : Icon(Icons.aspect_ratio);
                          });
                        },
                      ),
                    Spacer(),
                    ActionChip(
                      avatar: !(Theme.of(context).brightness == Brightness.dark)
                          ? Icon(Icons.dark_mode)
                          : Icon(Icons.light_mode),
                      label: Text(S.of(context).main_page_theme((Theme.of(context).brightness == Brightness.dark))),
                      onPressed: () async {
                        if(context.mounted){
                          bool themeBool = Theme.of(context).brightness == Brightness.dark;
                          MyApp.of(context).changeTheme(themeBool ? ThemeMode.light : ThemeMode.dark);
                          AppSettingsManager.instance.setDarkMode(!themeBool);
                          setState(() {});
                        }
                      },
                    ),
                    MenuAnchor(
                        style: MenuStyle(
                          padding: WidgetStateProperty.all(
                            EdgeInsets.all(5),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        menuChildren: languages.map((lang) {
                          return MenuItemButton(
                            onPressed: lang.onPressed,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CountryFlag.fromLanguageCode(lang.code, height: 15, width: 25),
                                const SizedBox(width: 5),
                                Text(lang.label),
                              ],
                            ),
                          );
                        }).toList(),
                        builder: (BuildContext context, MenuController controller, Widget? child) {
                          return Stack(
                            fit: StackFit.passthrough,
                            children: [
                              ActionChip(
                                label: Row(
                                  children: [
                                    Text(S.of(context).main_page_languages),
                                    SizedBox(width: 10,)
                                  ],
                                ),
                                //backgroundColor: Color.fromRGBO(169, 171, 25, 0.3),
                                avatar: Icon(Icons.language),
                                onPressed: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                },
                              ),
                              Positioned(
                                right: 5,
                                top: 0,
                                bottom: 0,
                                child: IgnorePointer( // <-- hier
                                  child: Icon(
                                    controller.isOpen ? Icons.expand_less : Icons.expand_more,
                                    size: 18,
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                        child: Icon(Icons.language)
                    ),
                    ActionChip(
                        label: Text("Settings", ),
                        avatar: Icon(Icons.settings),
                        onPressed: () async {
                          _blockScan = true;
                          var result = await showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context){
                                return  SettingsPage(
                                  changeColor: (Color color){
                                    setState(() {
                                      _selectedColor = color;
                                      //MyApp.of(context).changeSeedColor(color);
                                    });
                                  },
                                );
                              });
                           if(result != null){
                             loadSettings();
                           }
                           _blockScan = false;
                        },
                    )
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: 32,
                ),
                height: MediaQuery.of(context).size.height*0.1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 2,
                          child: !_isMobile && width > 850 ? TextButton.icon(
                            onPressed: (){
                              addOrEditUser();
                            },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: _selectedColor, //Color.fromRGBO(169, 171, 25, 1.0),
                                foregroundColor: Colors.black87,
                                minimumSize: Size(double.infinity, 64)
                            ),
                            label: Text(S.of(context).main_page_add),
                            icon: Icon(Icons.person_add_alt_1, color: Colors.black87),
                          ) : IconButton(
                            onPressed: (){
                              addOrEditUser();
                            },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: _selectedColor, //Color.fromRGBO(169, 171, 25, 1.0),
                                foregroundColor: Colors.black87,
                                minimumSize: Size(double.infinity, 64)
                            ),
                            icon: Icon(Icons.person_add_alt_1, color: Colors.black87),
                          )
                      ),
                      Expanded(
                        flex: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(child: Stack(
                              children: [
                                Align(
                                  alignment: AlignmentGeometry.center,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText:S.of(context).main_page_searchUsers,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))
                                      ),
                                    ),
                                    onChanged: (ev){
                                      searchUsers(ev);
                                    },
                                    onTapOutside: (ev){
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        _searchController.text = "";
                                        _userList.clear();
                                      });
                                    },
                                    icon: Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                        backgroundColor: Colors.transparent
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            IconButton(
                                onPressed: () => searchUsers(_searchController.text),
                                //label: Text("Suchen"),
                                icon: Icon(Icons.search),
                                style: TextButton.styleFrom(
                                  backgroundColor: _selectedColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),

                                  ),
                                    minimumSize: Size(30, double.infinity)
                                ),
                            )
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(!_isMobile)Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                        onPressed: (){
                          setState(() {
                            _isListView = !_isListView;
                          });
                        },
                        icon: Icon(_isListView ? Icons.grid_on : Icons.list),
                      label: Text(S.of(context).main_page_isListView(_isListView)),
                    ),
                  ),
                  TextButton.icon(
                      onPressed: ()async{
                        _blockScan = true;
                        await showDialog(
                          context: context,
                          builder: (context) {
                                return StatisticPage();
                          },
                        );
                        _blockScan = false;
                      },
                      label: Text(S.of(context).main_page_statistic),
                      icon: Icon(Icons.bar_chart),
                  )
                ],
              ),
              Expanded(
                child: _userList.isEmpty
                    ? Center(
                  child: Text(S.of(context).main_page_emptyUserListText),
                )
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    final isList = constraints.maxWidth > 782 && _isListView;
                    return isList
                        ? ListView.builder(
                          itemCount: _userList.length,
                          itemBuilder: (context, index) {
                            return _buildUserTile(_userList[index], index, isList);
                            },
                          )
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                              (MediaQuery.of(context).size.width / 220).toInt(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 250,
                            ),
                            itemCount: _userList.length,
                            itemBuilder: (context, index) {
                              return _buildUserTile(_userList[index], index, isList);
                            },
                    );
                  },
                ),
              )
            ],
          ),
        )
      ),
      floatingActionButton: _isMobile ? ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(64, 64)
          ),
          onPressed: ()async{
            //HttpHelper().testAddCustomer(firstName: "Test", lastName: "Tester", birthday: DateTime(1970,2,1).toIso8601String(),);
            String? result = await showDialog(
                context: context,
                builder: (context){
                  return BarcodeScannerSmartPhoneCamera();
                });
            if(result != null) {openUserFromUuId(result);}
          },
          label: Text(S.of(context).main_page_scanQrCode),
          icon: Icon(Icons.qr_code_scanner)) : SizedBox.shrink(),
    );
  }

}

class LanguageOption {
  final String code;
  final String label;
  final VoidCallback onPressed;

  LanguageOption({required this.code, required this.label, required this.onPressed});
}

