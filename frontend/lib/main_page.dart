import 'dart:async';
import 'dart:io';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:strohhalm_app/add_user_dialog.dart';
import 'package:strohhalm_app/banner_designer.dart';
import 'package:strohhalm_app/barcode_scanner_hardware_listener.dart';
import 'package:strohhalm_app/customer_tile.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/deletion_request_dialog.dart';
import 'package:strohhalm_app/dialog_helper.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/settings.dart';
import 'package:strohhalm_app/stat_page.dart';
import 'package:strohhalm_app/statistic_page.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:window_manager/window_manager.dart';
import 'app_settings.dart';
import 'barcode_scanner_phone_camera.dart';
import 'generated/l10n.dart';
import 'main.dart';

/*
TODO:
- pagination
 */

class MainPage extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  const MainPage({super.key, required this.onLocaleChange});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchWaitTimer;
  late BarcodeScannerListener socketListener;
  List<User> _userList = [];
  List<User> oldUserList = [];
  Icon _fullScreenIcon = Icon(Icons.fullscreen);
  bool _isListView = true;
  bool _isMobile = false;
  bool _useServer = false;
  bool _blockScan = false;
  Color _selectedColor = Color.fromRGBO(169, 171, 25, 1.0);
  bool _useBannerDesigner = true;
  File? _bannerImage;
  BannerImage? _bannerMap;
  bool _isAdmin = false;

  @override
  void initState(){
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    loadPage();
    listenForScanner();

    super.initState();
  }

  void loadPage()async{
    await loadSettings();
    final oneYearAgo = DateTime.now().subtract(Duration(days: 365));
    _useServer
        ? oldUserList = await HttpHelper().searchCustomers(lastVisitBefore: oneYearAgo) ?? []
        : oldUserList = await DatabaseHelper().getUsers(lastVisitBefore: oneYearAgo);
    setState(() {});

  }

  Future<void> loadSettings() async {
    await AppSettingsManager.instance.load();
    var settings = AppSettingsManager.instance.settings;
    bool lastUseServer = _useServer;
    _useServer = settings.useServer ?? false;
    if(_useServer != lastUseServer){ //TO not compromise either Database
      _searchController.text = "";
      _userList.clear();
    }
    _selectedColor = settings.selectedColor ?? Color.fromRGBO(169, 171, 25, 1.0);
    _useBannerDesigner = settings.useBannerDesigner ?? true;
    _bannerMap = settings.bannerDesignerImageContainer;
    _bannerImage = settings.bannerSingleImage;

    String languageCode = settings.languageCode ?? "de";

    changeLanguage(languageCode);
    if(mounted){
      MyApp.of(context).changeSeedColor(_selectedColor);
      MyApp.of(context).changeTheme(settings.darkMode! ? ThemeMode.dark : ThemeMode.light);
    }
    setState(() {});
  }

  void listenForScanner(){
    void scanSuccess(scannedValue) async {
      openUserFromUuId(scannedValue);
    }

    void uuIdFail(){
      DialogHelper.dialogConfirmation(context, S.of(context).uuId_fail_keyboard, false);
    }
    socketListener = BarcodeScannerListener(
        context: context,
        onSuccessScan: scanSuccess,
        onFailedUuIdCheck: uuIdFail
    );
    if(!_isMobile) socketListener.listenForScan();
  }

  ///Starts search after no input since 0.6Seconds and search-length longer than 3. So HTTP-Request are more precise
  void searchChanged(String query) {
    if (_searchWaitTimer?.isActive ?? false) _searchWaitTimer!.cancel();
    if(query.length <= 4){
      setState(() {
        _userList.clear();
      });
    }
    _searchWaitTimer = Timer(Duration(milliseconds: 600), () {
      if(query.length > 4 || query == "*"){
        searchUsers(query);
      }
    });
  }

  ///Gets Users with the firstName/Lastname LIKE the searchTerm. "*" gets all
  Future<void> searchUsers(String searchTerm) async {
      _userList.clear();
      if(searchTerm.trim().isNotEmpty) { //WhiteSpaces get removed so a SPACE doesn't just retrieve All
        _useServer
            ? _userList = (await HttpHelper().searchCustomers(query: searchTerm == "*" ? "" : searchTerm)) ?? []
            : _userList = await DatabaseHelper().getUsers(search: searchTerm == "*" ? " " : searchTerm);
      }
    setState(() {
      _userList;
    });
  }

  ///Adds or edits a User (if you want to edit, you have to give it the existing User)
  Future<void> addOrEditUser([User? user]) async {
    _blockScan = true;
    AddUserReturn? result = await AddUserDialog.showAddUpdateUserDialog(context, user);
    if(result != null){
      User? alteredOrNewUser = result.user;
      bool delete = result.deleted;

      if(delete) {
        bool result;
        _useServer
          ? result = await HttpHelper().deleteCustomer(id: alteredOrNewUser.id)
          : result = await DatabaseHelper().deleteUser(alteredOrNewUser.id);
        if(mounted) {
          Utilities.showToast(
            context: context,
            title:  result ? S.of(context).success : S.of(context).fail,
            description: result ? S.of(context).deletion_success :  S.of(context).deletion_failed,
            isError: !result
          );
        }
        if(result) setState(() => _userList.removeWhere((listUser) => listUser.id == user?.id));
      } else {
          int index = _userList.indexWhere((item) => item.id == alteredOrNewUser.id);
          if(index != -1){ //Update existing user if id exists in _userList
            setState(() => _userList[index] = alteredOrNewUser);
          } else { //open new User
            openUser(alteredOrNewUser);
          }
      }
    }
    _blockScan = false;
  }

  Future<void> openStatPage(User user) async {
    _blockScan = true;
    User? updatedUser = await StatPage.showStatPageDialog(context, user);
    int i = _userList.indexOf(user);
    setState(() {
      _userList[i] = user.copyWith(lastVisit: updatedUser?.lastVisit, notes: updatedUser?.notes); //new Objekt so the ListView can update through ObjectKey(user)
    });
    checkOldUserList(_userList[i]);
    _blockScan = false;
  }

  Future<void> openUserFromUuId(String uuIdString) async {
    if(_blockScan) return;
    Utilities.showToast(context: context, title: S.of(context).success, description: uuIdString);
    //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erfolgreich gescannt : $uuIdString")));
    User? user;
    _useServer
        ? user = await HttpHelper().getCustomerByUUID(uuIdString)
        : user = await DatabaseHelper().getUsers(uuid: uuIdString).then((item) => item.first);
    if(user != null){
      openUser(user);
    } else {
      if(mounted) {
        DialogHelper.dialogConfirmation(context, "${S.of(context).main_page_noUserWithUUID}:\n$uuIdString", false);
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
      if(!_isMobile) await windowManager.setTitle(S.of(context).application_name);
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
      updatedVisit: (){
        checkOldUserList(user);
      },
      update: () => addOrEditUser(user),
    ).animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.2, end: 0);
  }

  void checkOldUserList(User user) {
    final index = oldUserList.indexWhere((item) => item.id == user.id);
    final isOld = user.lastVisit != null && user.lastVisit!.isBefore(DateTime.now().subtract(Duration(days: 365)));

    if (index != -1 && !isOld) { //If in oldUserList and not old anymore => remove
      setState(() => oldUserList.removeAt(index));
    } else if (index == -1 && isOld) { //If in oldUserList and old now => add
      setState(() => oldUserList.add(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    var languages = [
      LanguageOption(code: "de", label: S.of(context).language_de, onPressed: () => changeLanguage("de")),
      LanguageOption(code: "en", label: S.of(context).language_en, onPressed: () => changeLanguage("en")),
      //LanguageOption(code: "ru", label: S.of(context).language_ru, onPressed: () => changeLanguage("ru")),
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
              if(!_useBannerDesigner) Image.file(_bannerImage!),
              if(_useBannerDesigner && _bannerMap != null) BannerWidget(bannerImage: _bannerMap),
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
                    if(!_isMobile)ActionChip(
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
                    LanguageMenu(languages: languages),
                    if(_isAdmin)ActionChip(
                        label: Text("Settings", ),
                        avatar: Icon(Icons.settings),
                        onPressed: () async {
                          _blockScan = true;
                          var result = !_isMobile
                              ? await SettingsPage.showSettingsAsDialog(
                                  context: context,
                                  changeColor: (Color color){
                                  setState(() {
                                    _selectedColor = color;
                                    //MyApp.of(context).changeSeedColor(color);
                                  });
                                },)
                              : navigatorKey.currentState?.push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    SettingsPage(
                                      changeColor: (Color color){
                                        setState(() {
                                          _selectedColor = color;
                                          //MyApp.of(context).changeSeedColor(color);
                                        });
                                      },
                                    ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const curve = Curves.easeInOut;
                                  final tween = Tween<Offset>(
                                    begin: const Offset(-1, 0), //x geht -1 bis 1
                                    end: Offset.zero,
                                  ).chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              )
                          );
                           if(result != null){
                             loadPage();
                           }
                           setState(() {
                             _selectedColor = AppSettingsManager.instance.settings.selectedColor ?? _selectedColor;
                             MyApp.of(context).changeSeedColor(_selectedColor);
                           });
                           _blockScan = false;
                        },
                    )
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: 42,
                ),
                height: MediaQuery.of(context).size.height*0.07,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                //minimumSize: Size(double.infinity, double.infinity)
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
                                //minimumSize: Size(double.infinity, double.infinity)
                            ),
                            icon: Icon(Icons.person_add_alt_1, color: Colors.black87),
                          )
                      ),
                      Expanded(
                        flex: 10,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: _isMobile ? 6 : 9,
                                child: TextField(
                                    controller: _searchController,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(20),
                                    suffixIcon: IconButton(
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
                                      hintText:S.of(context).main_page_searchUsers,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))
                                      ),
                                    ),
                                    onChanged: searchChanged,
                                    onTapOutside: (ev){
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                onPressed: () => searchUsers(_searchController.text),
                                //label: Text("Suchen"),
                                icon: Icon(Icons.search),
                                style: TextButton.styleFrom(
                                  backgroundColor: _selectedColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                                  ),
                                  //minimumSize: Size(30, double.infinity)
                                ),
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
                        StatisticPage.showStatisticDialog(context);
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
                  child: Text(S.of(context).main_page_emptyUserListText, textAlign: TextAlign.center,),
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
              ),
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAdmin = !_isAdmin;
                        });
                      },
                      child: Text(
                        "Admin",
                        style: TextStyle(
                          color: _isAdmin ? Colors.blue.shade800 : Colors.blue.shade400,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  if(oldUserList.isNotEmpty) Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ActionChip(
                        onPressed: () async {
                          if(oldUserList.isEmpty) return;
                          DeleteRequestReturn result = await DeleteDialog.showDeleteDialog(context, oldUserList);
                          setState(() {
                            if(result.deletedUsersId.isNotEmpty){
                              for(int d in result.deletedUsersId){
                                _userList.removeWhere((item) => item.id == d);
                              }
                            }
                            if(result.resetUsersId.isNotEmpty){
                              for(int d in result.resetUsersId){
                                _userList.firstWhere((item) => item.id == d).lastVisit = null;
                              }
                            }
                          });
                        },
                        label: Text("Deletion Request"),
                      ),
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${oldUserList.length}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        )
      ),
      floatingActionButton: _isMobile
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await BarcodeScannerSmartPhoneCamera.showBarcodeScannerDialog(context);
                if (result != null) openUserFromUuId(result);
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(S.of(context).main_page_scanQrCode),
            )
          : SizedBox.shrink(),
    );
  }
}

class LanguageOption {
  final String code;
  final String label;
  final VoidCallback onPressed;

  LanguageOption({required this.code, required this.label, required this.onPressed});
}

class BannerWidget extends StatelessWidget {
  final BannerImage? bannerImage;


  const BannerWidget({super.key, required this.bannerImage});

  @override
  Widget build(BuildContext context) {
    if (bannerImage == null) return const SizedBox.shrink();
    double bannerHeight = MediaQuery.of(context).size.height * 0.11;
    Color? selectedColor = AppSettingsManager.instance.settings.selectedColor;

    return Column(
      children: [
        Row(
          children: [
            if (bannerImage!.leftImage != null)
              Image.file(bannerImage!.leftImage!, height: bannerHeight),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                bannerImage!.title ?? "",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: selectedColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            if (bannerImage!.rightImage != null )
              Image.file(bannerImage!.rightImage!, height: bannerHeight),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: selectedColor,
          ),
        )
      ],
    );
  }
}

class LanguageMenu extends StatelessWidget {
  final List<LanguageOption> languages;
  const LanguageMenu({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: languages.map((lang) {
        return MenuItemButton(
          onPressed: lang.onPressed,
          child: Row(
            children: [
              CountryFlag.fromLanguageCode(lang.code, height: 15, width: 25),
              SizedBox(width: 5),
              Text(lang.label),
            ],
          ),
        );
      }).toList(),
      builder: (context, controller, child) {
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
                controller.isOpen ? controller.close() : controller.open();
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
    );
  }
}

//HID or COM-Serial
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