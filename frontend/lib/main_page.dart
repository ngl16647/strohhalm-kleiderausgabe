import 'dart:async';
import 'dart:io';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:strohhalm_app/add_user_dialog.dart';
import 'package:strohhalm_app/auto_close_dialog.dart';
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
import 'package:strohhalm_app/user_and_visit.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:window_manager/window_manager.dart';
import 'app_settings.dart';
import 'barcode_scanner_phone_camera.dart';
import 'check_connection.dart';
import 'generated/l10n.dart';
import 'main.dart';


///Main/Start-Page
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
  ///userLists
  List<User> _userList = [];          //SearchResults
  List<User> oldUserList = [];        //Users older than a year
  ///UI-State-Variables
  Icon _fullScreenIcon = Icon(Icons.fullscreen, size: 20,);
  Color _selectedColor = Color.fromRGBO(169, 171, 25, 1.0); //AccentColor defaults to lime
  bool _isListView = true;
  bool _isMobile = false;
  bool _blockScan = false;            //blocks additional scans when a Dialog is open
  bool _isAdmin = false;
  ///Banner-Variables
  bool _useBannerDesigner = true;     //use a self-composed banner or just one image
  File? _bannerImage;                 //the one image
  BannerImage? _bannerMap;            //the Objekt with the self-composed elements

  ///Server-Variables
  bool _useServer = false;            //offline or online-Mode
  static const int pageSize = 10;     //length of first results when searching online
  int _page = 1;                      //offset for online-search
  final bool _isLoadingMore = false;

  @override
  void initState(){
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    listenForScanner();
    loadPage();
    super.initState();
  }

  void loadPage()async{
    await loadSettings();
  }

  ///Loads all Settings
  Future<void> loadSettings() async {
    await AppSettingsManager.instance.load();
    var settings = AppSettingsManager.instance.settings;
    bool lastUseServer = _useServer;
    _useServer = settings.useServer ?? false;
    if(_useServer != lastUseServer){ //To not compromise either Database
      _searchController.text = "";
      _userList.clear();
      oldUserList.clear();
      if(mounted) context.read<ConnectionProvider>().periodicCheckConnection();
    }
    if(!_useServer && mounted){
      context.read<ConnectionProvider>().setStatus(ConnectionStatus.connected); //If not using server status should always be connected
    }
    setState(() {
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
    });
    if(_useServer != lastUseServer && _isAdmin){
      checkForOldUsers();
    }
  }

  ///Checks the relevant Database for users where lastVisit is older than one year
  Future<void> checkForOldUsers() async {
  if(_useServer) {
    if(mounted){
    oldUserList = await HttpHelper().searchCustomers(lastVisitBefore: DateTime.now().subtract(Duration(days: 365)), size: 100) ?? [];
    oldUserList.removeWhere((item) => item.lastVisit == null); //Check since HttpRequest also returns Customers where lastVisit == null
    }
  } else {
    if(mounted) context.read<ConnectionProvider>().cancelCheck();
    if(mounted) context.read<ConnectionProvider>().setStatus(ConnectionStatus.connected);
    oldUserList = await DatabaseHelper().getUsers(lastVisitBefore: DateTime.now().subtract(Duration(days: 365)), size: 9999);
  }
  setState(() {
    oldUserList;
  });
}

///Starts listening for scanner-Input and displays results
  void listenForScanner(){
    void scanSuccess(scannedValue) async {
      openUserFromUuId(scannedValue);
    }

    void uuIdFail(){
      DialogHelper.dialogConfirmation(
          context: context,
          message: S.of(context).uuId_fail_keyboard,
          hasChoice: false);
    }
    socketListener = BarcodeScannerListener(
        context: context,
        onSuccessScan: scanSuccess,
        onFailedUuIdCheck: uuIdFail
    );
    if(!_isMobile) socketListener.listenForScan();
  }

  ///Starts search after no input since 0.6 Seconds and search-length longer than 3. So HTTP-Request are more precise
  void searchChanged(String query) {
    if (_searchWaitTimer?.isActive ?? false) _searchWaitTimer!.cancel();
    if(!_useServer){
      searchUsers(query);
      return;
    }
    if(query.length <= 3){
      setState(() {
        _userList.clear();
      });
    }
    _searchWaitTimer = Timer(Duration(milliseconds: 600), () {
      if(query.length > 3 || query == "*"){
        searchUsers(query);
      }
    });
  }

  ///Gets Users with the firstName/Lastname LIKE the searchTerm. "*" gets all
  Future<void> searchUsers(String searchTerm) async {
      _page = 1;
      _userList.clear();
      if(searchTerm.trim().isNotEmpty) { //WhiteSpaces get removed so a SPACE doesn't just retrieve All
        _useServer
            ? _userList = (await HttpHelper().searchCustomers(query: searchTerm == "*" ? "" : searchTerm, size: pageSize)) ?? []
            : _userList = await DatabaseHelper().getUsers(search: searchTerm == "*" ? " " : searchTerm, size: pageSize);
      }

    setState(() {
      if(_userList.length < pageSize) _page = 0;
      _userList;
    });
  }

  ///Makes the next request after initial search
  Future<void> loadMore() async {
    _page++;
    String searchTerm = _searchController.text;
    List<User> additionalUsers = _useServer
        ? (await HttpHelper().searchCustomers(query: searchTerm == "*" ? "" : searchTerm, size: pageSize, page: _page)) ?? []
        : await DatabaseHelper().getUsers(search: searchTerm == "*" ? " " : searchTerm, size: pageSize, page: _page);

    setState(() {
      if(additionalUsers.length < pageSize) _page = 0;
      _userList.addAll(additionalUsers);
    });
  }

  ///Adds or edits a User (if you want to edit, you have to give it the existing User)
  Future<void> addOrEditUser([User? user]) async {
    _blockScan = true;
    AddUserReturn? result = await AddUserDialog.showAddUpdateUserDialog(
       context: context,
       user: user,
    );
    if(result != null){
      User? alteredOrNewUser = result.user;
      bool delete = result.deleted;

      if(delete) {
        bool result;
        _useServer
          ? result = await HttpHelper().deleteCustomer(id: alteredOrNewUser.id)
          : result = await DatabaseHelper().deleteUser(alteredOrNewUser.id);
        oldUserList.removeWhere((item) => item.id == alteredOrNewUser.id);
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
            showUserInSearchBar(alteredOrNewUser);
            openStatPage(alteredOrNewUser);
          }
      }
    }
    _blockScan = false;
  }

  ///Opens the page of a Customer with more Details
  Future<void> openStatPage(User user, [bool? addNewVisit]) async {
    _blockScan = true;
    User? updatedUser = await StatPage.showStatPageDialog(
        context: context,
        user: user
    );
    int i = _userList.indexWhere((item) => item.id == user.id);
    setState(() {
      _userList[i] = user.copyWith(lastVisit: updatedUser?.lastVisit, notes: updatedUser?.notes); //new Objekt so the ListView can update through ObjectKey(user)
    });
    checkIfUserGotOld(_userList[i]);
    _blockScan = false;
  }

  ///clears the searchbar and displays a newly added or a Customer found by uuid on the mainPage
  void showUserInSearchBar(User user){
    _page = 0;
    _userList.clear();
    setState(() {
      _userList.add(user);
    });
    _searchController.text = "${user.firstName} ${user.lastName}";
  }

  ///searches for a Customer by Uuid and opens its stat page
  Future<void> openUserFromUuId(String uuIdString) async {
    if(_blockScan) return;
    User? user;
    _useServer
        ? user = await HttpHelper().getCustomerByUUID(uuIdString)
        : user = await DatabaseHelper().getUsers(uuid: uuIdString).then((item) =>  item.firstOrNull);

    if(user != null && mounted){
      showUserInSearchBar(user); //TODO: Should this be?
      Visit? newLastVisit = await Utilities.addVisit(user, context, false);
      if (newLastVisit != null) {
        user.lastVisit = newLastVisit.tookTime;
        _userList.firstWhere((item) => item.id == user?.id).lastVisit = newLastVisit.tookTime;
      }
      if(!mounted) return;
      _blockScan = true;
      await AutoCloseDialog(
        durationInSeconds: newLastVisit != null ? 10 : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children:  [
            Icon(
              newLastVisit != null
                  ? Icons.check_circle
                  : Icons.error_rounded,
              size: 46,
              color: newLastVisit != null
                  ? Colors.green
                  : Colors.red,
            ),
            Text(
              newLastVisit != null
                  ? S.of(context).visit_added_success
                  : S.of(context).visit_added_error(DateTime.now().difference(user.lastVisit!).inDays),
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openStatPage(user!);
              },
              child: Text("Besucher Details anzeigen"),
            )
          ],
        ),
      ).showAutoCloseDialog(context);
      _blockScan = false;
    } else {
      if(mounted) {
        DialogHelper.dialogConfirmation(
            context: context,
            message: "${S.of(context).main_page_noUserWithUUID}:\n$uuIdString",
            hasChoice: false);
      }
    }
  }

  ///Changes the Language of the Application live
  Future<void> changeLanguage(String localeId) async {
    widget.onLocaleChange(Locale(localeId));
    AppSettingsManager.instance.setLanguage(localeId);

    // Warte auf rebuild
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      if (!mounted) return;
      if(!_isMobile) await windowManager.setTitle(S.of(context).window_title);
      setState(() {});
    });
  }

  @override
  void dispose() {
    socketListener.dispose();
    super.dispose();
  }

  ///creates a Customer-Tile and handles actions
  Widget _buildUserTile(User user, int index, bool isList) {
    var settings = AppSettingsManager.instance.settings;


    return CustomerTile(
        isListView: isList,
        key: ValueKey("${user.hashCode}-${settings.allowDeleting.hashCode}-${settings.allowAdding.hashCode}-${settings.cutOffDayNumber.hashCode}-${user.uuId}" ),
        user: user,
        click: () =>  openStatPage(user), //openUserFromUuId(user.uuId),
        updatedVisit: (){
          checkIfUserGotOld(user);
        },
        update: () => addOrEditUser(user),
      ).animate(delay: ((index * 15).clamp(0, 500)).ms)
          .fadeIn(duration: 300.ms)
          .slideX(begin: -0.2, end: 0);
  }

  ///Load-More widget for pagination
  Widget _buildLoadMoreTile(){
    if(_page == 0) return Center(child: Padding(padding: EdgeInsets.all(15),child: Text( S.of(context).load_more(""),),),);
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _isLoadingMore ? null : loadMore,
          icon: _isLoadingMore
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.autorenew),
          label: Text(
            S.of(context).load_more(_isLoadingMore),
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          ),
        ),
      ),
    );
  }

  ///Checks if a changes user now is older than a year again
  void checkIfUserGotOld(User user) {
    final index = oldUserList.indexWhere((item) => item.id == user.id);
    final isOld = user.lastVisit != null && user.lastVisit!.isBefore(DateTime.now().subtract(Duration(days: 365)));

    if (index != -1 && !isOld) { //If in oldUserList and not old anymore => remove
      setState(() => oldUserList.removeAt(index));
    } else if (index == -1 && isOld) { //If in oldUserList and old now => add
      setState(() => oldUserList.add(user));
    }
  }

  ///Drop-Down Menu for Languages. Makes it easy to add more
  Widget buildLanguageDropDown(bool showOnlyIcons) {
    var languages = [
      LanguageOption(code: "de", label: S.of(context).language_de, onPressed: () => changeLanguage("de")),
      LanguageOption(code: "en", label: S.of(context).language_en, onPressed: () => changeLanguage("en")),
      //LanguageOption(code: "ru", label: S.of(context).language_ru, onPressed: () => changeLanguage("ru")),
      //Here one can add new Languages if necessary (code = Country-Code from http://www.lingoes.net/en/translator/langcode.htm)
    ];

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
              label: showOnlyIcons
                  ? SizedBox.shrink()
                  : Row(
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
              child: IgnorePointer(
                child: Icon(
                  controller.isOpen ? Icons.expand_less : Icons.expand_more,
                  size: 17,
                ),
              ),
            )
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    double width = MediaQuery.of(context).size.width;
    bool showOnlyIcons = width < (_isAdmin ? 860 : 700) || _isMobile;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(255),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 10,
                children: [
                  if(!_useBannerDesigner && _bannerImage != null) Image.file(_bannerImage!),
                  if(_useBannerDesigner && _bannerMap != null) BannerWidget(bannerImage: _bannerMap),
                  Container(
                    width: double.infinity, // Ensure finite width
                    padding: EdgeInsets.symmetric(horizontal: 10 ,vertical: 0),
                    child: Row(
                      spacing: 8,
                      children: [
                        if (!_isMobile)
                          ActionChip(
                            avatar: showOnlyIcons ? null : _fullScreenIcon,
                            label: showOnlyIcons
                                ? _fullScreenIcon
                                : Text(S.of(context).main_page_fullScreen),
                            onPressed: () async {
                              bool isFullScreen = await windowManager.isFullScreen();
                              windowManager.setFullScreen(!isFullScreen);
                              setState(() {
                                _fullScreenIcon = !isFullScreen
                                    ? Icon(Icons.close_fullscreen, size: 17)
                                    : Icon(Icons.aspect_ratio, size: 17);
                              });
                            },
                          ),
                        Tooltip(
                          message: S.of(context).server_display_toolTip,
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: context.watch<ConnectionProvider>().status == ConnectionStatus.connected ? Colors.lightBlue.withAlpha(100) : Colors.red.withAlpha(100)
                            ),
                            padding: EdgeInsets.all(4),
                            child: Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(_useServer
                                    ?  context.watch<ConnectionProvider>().status == ConnectionStatus.connected ? Icons.cloud : Icons.cloud_off
                                    : Symbols.hard_drive_rounded, size: 20,),
                                if(!showOnlyIcons)Text(_useServer
                                    ? context.watch<ConnectionProvider>().status == ConnectionStatus.connected ? S.of(context).online_Database : S.of(context).settings_noConnection
                                    : S.of(context).offline_Database),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        ActionChip(
                          avatar: showOnlyIcons
                              ?  null
                              :  Icon(!(Theme.of(context).brightness == Brightness.dark) ? Icons.dark_mode : Icons.light_mode),
                          label: showOnlyIcons
                              ? Icon(!(Theme.of(context).brightness == Brightness.dark) ? Icons.dark_mode : Icons.light_mode, size: 17,)
                              : Text(S.of(context).main_page_theme((Theme.of(context).brightness == Brightness.dark))),
                          onPressed: () async {
                            if(context.mounted){
                              bool themeBool = Theme.of(context).brightness == Brightness.dark;
                              MyApp.of(context).changeTheme(themeBool ? ThemeMode.light : ThemeMode.dark);
                              AppSettingsManager.instance.setDarkMode(!themeBool);
                              setState(() {});
                            }
                          },
                        ),
                        buildLanguageDropDown(showOnlyIcons),
                        if(_isAdmin)ActionChip(
                            label: showOnlyIcons ?  Icon(Icons.settings, size: 17) : Text(S.of(context).settings),
                            avatar: showOnlyIcons ? null :Icon(Icons.settings),
                            onPressed: () async {
                              if(!mounted) return;
                              _blockScan = true;
                               if(mounted){
                                  !_isMobile
                                     ? await SettingsPage.showSettingsAsDialog(
                                         context: context,
                                         changeColor: (Color color){
                                           setState(() {
                                             _selectedColor = color;
                                             //MyApp.of(context).changeSeedColor(color);
                                           });
                                         },)
                                     : await Navigator.of(context).push(
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
                               }
                               loadPage(); //load page anyway to make sure Settings stay consistent
                               //if(_userList.isNotEmpty){
                               //  List<User> tempList = List.from(_userList);
                               //  setState(() {_userList.clear();});
                               //  //await Future.delayed(Duration(milliseconds:100));
                               //  setState(() {_userList.addAll(tempList);
                               //  });
                               //}
                               setState(() {
                                 _selectedColor = AppSettingsManager.instance.settings.selectedColor ?? _selectedColor;
                                 MyApp.of(context).changeSeedColor(_selectedColor);
                               });
                               _blockScan = false;
                            },
                        ),
                        ActionChip(
                          avatar: showOnlyIcons ? null : Icon(_isAdmin ? Icons.logout : Icons.login),
                          label: showOnlyIcons ? Icon(_isAdmin ? Icons.logout : Icons.login, size: 17,) :Text(S.of(context).admin_login(!_isAdmin)) ,
                          onPressed: () async {
                            if(_isAdmin){
                              setState(() {
                                _isAdmin = false;
                              });
                              return;
                            }
                            TextEditingController con = TextEditingController();
                            bool? confirmed = await showDialog<bool?>(
                              context: context,
                              builder: (context) {
                                bool error = false;
                                bool obscure = true;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      content: TextField(
                                        controller: con,
                                        obscureText: obscure,
                                        obscuringCharacter: "*",
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              onPressed: () async {
                                                setState(() {
                                                  obscure = !obscure;
                                                });
                                              },
                                              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)
                                          ),
                                          labelText: S.of(context).password,
                                          errorText: error ? S.of(context).password_false : null,
                                        ),
                                        onChanged: (value) {
                                          if (error) {
                                            setState(() {
                                              error = false;
                                            });
                                          }
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text(S.of(context).cancel),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (con.text == "admin123") { //TODO: For testing: Other approach?
                                              Navigator.of(context).pop(true);
                                            } else {
                                              setState(() {
                                                error = true;
                                              });
                                            }
                                          },
                                          child: Text(S.of(context).confirm),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                            if(confirmed != null && confirmed){
                              setState(() {
                                _isAdmin = true;
                                checkForOldUsers();
                              });
                            }
                          }
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 42,
                      maxHeight: 60
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
                                        mouseCursor: SystemMouseCursors.text,
                                        controller: _searchController,
                                        textAlignVertical: TextAlignVertical.bottom,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10), //No idea how to stretch the field vertically without content-padding
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
                                          hintText:S.of(context).main_page_searchUsers(_useServer),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))
                                          )
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
                          onPressed: () async{
                            _blockScan = true;
                            if(context.mounted) await StatisticPage.showStatisticDialog(context);
                            _blockScan = false;
                          },
                          label: Text(S.of(context).main_page_statistic(_useServer)),
                          icon: Icon(Icons.bar_chart), //_statLoading ? SizedBox(width: 10, height: 10, child: CircularProgressIndicator()) : Icon(Icons.bar_chart),
                      )
                    ],
                  ),
                  Expanded(
                    child: _userList.isEmpty
                        ? Center(
                            child: Text(_searchController.text.length > 3 ? S.of(context).no_users_found : S.of(context).main_page_emptyUserListText , textAlign: TextAlign.center,),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isList = constraints.maxWidth > 782 && _isListView;
                              return ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black,
                                        Colors.black,
                                        Colors.transparent,
                                      ],
                                      stops: [0.0, 0.02, 0.95, 1.0],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.dstIn, // Wichtig für den Maskeneffekt
                                  child: Scrollbar(
                                    thumbVisibility: !_isMobile,
                                    trackVisibility: !_isMobile,
                                    controller: scrollController,
                                    child: isList
                                        ? ListView.builder(
                                            padding: EdgeInsets.only(right: 15,bottom: 20),
                                            controller: scrollController,
                                            itemCount: _userList.length+1,
                                            itemBuilder: (context, index) {
                                              if(index == _userList.length) {
                                                return _buildLoadMoreTile();
                                              }
                                              return _buildUserTile(_userList[index], index, isList);
                                            },
                                          )
                                        : GridView.builder(
                                            padding: EdgeInsets.only(right: 15, bottom: 20),
                                            controller: scrollController,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                            (MediaQuery.of(context).size.width / 265).toInt(),
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            mainAxisExtent: 250,
                                          ),
                                          itemCount: _userList.length+1,
                                          itemBuilder: (context, index) {
                                            if(index == _userList.length) {
                                              return _buildLoadMoreTile();
                                            }
                                            return _buildUserTile(_userList[index], index, isList);
                                          },
                                        ),
                                  ),
                              );
                            },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: _isMobile ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if(oldUserList.isNotEmpty && _isAdmin) Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ActionChip(
                            onPressed: () async {
                              if(oldUserList.isEmpty) return;
                              DeleteRequestReturn? result = await DeleteDialog.showDeleteDialog(context, oldUserList);
                              if(result == null) return;
                              setState(() {
                                if(result.deletedUsersId.isNotEmpty){
                                  for(int d in result.deletedUsersId){
                                    _userList.removeWhere((item) => item.id == d);
                                    oldUserList.removeWhere((item) => item.id == d);
                                  }
                                }
                                if(result.resetUsersId.isNotEmpty){
                                  for(int d in result.resetUsersId){
                                    _userList.firstWhere((item) => item.id == d).lastVisit = null;
                                    oldUserList.removeWhere((item) => item.id == d);
                                  }
                                }
                              });
                            },
                            label: Text(S.of(context).deletionRequest_buttonTitle),
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              height: 20,
                              constraints: BoxConstraints(minWidth: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${oldUserList.length}",
                                textAlign: TextAlign.center,
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
                  ),
                  if(context.watch<ConnectionProvider>().status != ConnectionStatus.connected) Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(70),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    height: 40,
                    width: double.infinity,
                    child: Row(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_rounded),
                        Text(
                            context.watch<ConnectionProvider>().status  == ConnectionStatus.noInternet
                            ? S.of(context).no_internet
                            : S.of(context).no_server)
                      ],
                    ),
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
              icon: Icon(Icons.qr_code_scanner),
              label: Text(S.of(context).main_page_scanQrCode),
            )
          : SizedBox.shrink(),
    );
  }
}

///Language options with displayName, language-Code and onClick function
class LanguageOption {
  final String code;
  final String label;
  final VoidCallback onPressed;

  LanguageOption({required this.code, required this.label, required this.onPressed});
}

///Widget for Displaying the Data from a single bannerImage or the Elements of the BannerImage-Object
class BannerWidget extends StatelessWidget {
  final BannerImage? bannerImage;
  const BannerWidget({
    super.key,
    required this.bannerImage
  });

  @override
  Widget build(BuildContext context) {
    if (bannerImage == null) return SizedBox.shrink();
    if(bannerImage!.isEmpty) return SizedBox.shrink();
    bool isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    double bannerHeight =isMobile ? MediaQuery.of(context).size.height*0.06 : MediaQuery.of(context).size.height * 0.11;
    double maxBannerWidth = isMobile ? MediaQuery.of(context).size.width*0.2 : MediaQuery.of(context).size.width*0.33;

    Color? selectedColor = AppSettingsManager.instance.settings.selectedColor;

    return Column(
      children: [
        Row(
          children: [
            if (bannerImage!.leftImage != null)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxBannerWidth,
                ),
                child: Image.file(
                  bannerImage!.leftImage!,
                  height: bannerHeight,
                  fit: BoxFit.contain, // optional, damit es sauber skaliert
                ),
              ),
            SizedBox(width: 15),
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
            if (bannerImage!.rightImage != null )ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxBannerWidth,
              ),
              child: Image.file(
                  bannerImage!.rightImage!,
                  height: bannerHeight),
            ),
          ],
        ),
        SizedBox(height: 3),
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


///Considerations when choosing between serial-Port scanner and HID-scanner
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