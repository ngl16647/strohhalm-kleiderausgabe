import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:strohhalm_app/add_user_dialog.dart';
import 'package:strohhalm_app/customer_listview_item.dart';
import 'package:strohhalm_app/customer_gridview_item.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/stat_page.dart';
import 'package:strohhalm_app/statistic_page.dart';
import 'package:strohhalm_app/user.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

import 'barcode_scanner_simple.dart';
import 'generated/l10n.dart';
import 'main.dart';

class MainPage extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  const MainPage({super.key, required this.onLocaleChange});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _userList = [];
  Icon fullScreenIcon = Icon(Icons.fullscreen);
  bool isListView = true;
  bool isMobile = false;

  @override
  void initState() {
    isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    super.initState();
  }

  ///Gets Users with the firstName/Lastname LIKE the searchTerm. "*" gets all
  Future<void> searchUsers(String searchTerm) async {
    //TODO: Probably include a Search-Button, so there are less unnecessary server-requests
      _userList.clear();
      if(searchTerm == "*"){
        _userList = await DatabaseHelper().getUsers("");
      } else if(searchTerm.trim().isNotEmpty) { //WhiteSpaces get removed so a SPACE doesn't just retrieve All
        _userList = await DatabaseHelper().getUsers(searchTerm);
      }
      //_userList.forEach((item) => print(item.tookItems.isNotEmpty ? item.tookItems.first.tookTime : "EMpty"));
    setState(() {
      _userList;
    });
  }

  ///Adds or edits a User (if you want to edit, you have to give it a existing User)
  Future<void> addOrEditUser([User? user]) async {
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
  }

  Future<void> openStatPage(User user) async {
    List<TookItem>? updated = await showDialog<List<TookItem>>(
        context: context,
        builder: (context){
          return StatPage(user: user);
        });
    if(updated != null){
      int i = _userList.indexOf(user);
      _userList[i] = user.copyWith(tookItems: updated); //new Objekt so the ListView can update throug Objectkey(user)
    }
  }

  void openUser(User user){
    //TODO: Ask how it would be best to update?
    _userList.clear();
    setState(() {
      _userList.add(user);
    });
    openStatPage(user);
    _searchController.text = "${user.firstName} ${user.lastName}";
  }

  Future<void> changeLanguage(String localeId) async {
    widget.onLocaleChange(Locale(localeId));

    // Warte auf rebuild
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      if (!mounted) return;
      await windowManager.setTitle(S.of(context).application_name);
      setState(() {});
    });
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
              Image.asset(
                isMobile
                    ? "assets/images/strohalm_header_image_mobile.png"
                    : "assets/images/strohalm_header_image.png",
                width: double.infinity,
              ),
              SizedBox(
                width: double.infinity, // Ensure finite width
                child: Row(
                  spacing: 8,
                  children: [
                    if (!isMobile)
                      ActionChip(
                        avatar: FutureBuilder<bool>(
                          future: windowManager.isFullScreen(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done &&
                                snapshot.hasData) {
                              return snapshot.data!
                                  ? Icon(Icons.close_fullscreen)
                                  : Icon(Icons.fullscreen);
                            }
                            return Icon(Icons.fullscreen); // Default icon while loading
                          },
                        ),
                        label: Text(S.of(context).main_page_fullScreen),
                        onPressed: () async {
                          bool isFullScreen = await windowManager.isFullScreen();
                          windowManager.setFullScreen(!isFullScreen);
                          setState(() {
                            fullScreenIcon = !isFullScreen
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
                        MyApp.of(context).changeTheme();
                        setState(() {});
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
                          return ActionChip(
                            label: Text(S.of(context).main_page_languages),
                            //backgroundColor: Color.fromRGBO(169, 171, 25, 0.3),
                            avatar: Icon(controller.isOpen ? Icons.expand_less : Icons.expand_more, size: 18),
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                          );
                        },
                        child: Icon(Icons.language)
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
                        flex: 10,
                        child: Stack(
                          children: [
                            Align(
                              alignment: AlignmentGeometry.center,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText:S.of(context).main_page_searchUsers,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)
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
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: !isMobile && width > 850 ? TextButton.icon(
                            onPressed: (){
                              addOrEditUser();
                            },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Color.fromRGBO(169, 171, 25, 1.0),
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
                                backgroundColor: Color.fromRGBO(169, 171, 25, 1.0),
                                foregroundColor: Colors.black87,
                                minimumSize: Size(double.infinity, 64)
                            ),
                            icon: Icon(Icons.person_add_alt_1, color: Colors.black87),
                          )
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(!isMobile)Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                        onPressed: (){
                          setState(() {
                            isListView = !isListView;
                          });
                        },
                        icon: Icon(isListView ? Icons.grid_on : Icons.list),
                      label: Text(S.of(context).main_page_isListView(isListView)),
                    ),
                  ),
                  TextButton.icon(
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, state) {
                                return  StatisticPage();
                              },
                            );
                          },
                        );
                      },
                      label: Text(S.of(context).main_page_statistic),
                      icon: Icon(Icons.bar_chart),
                  )
                ],
              ),
              Expanded(
                  child: _userList.isEmpty
                      ? Center(child: Text(S.of(context).main_page_emptyUserListText),)
                      : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 782 && isListView) {
                        return ListView.builder(
                            itemCount: _userList.length,
                            itemBuilder: (context, index){
                              User user = _userList[index];
                              return CustomerListviewItem(
                                key: ObjectKey(user),
                                user: user,
                                click: (){
                                  openStatPage(user);
                                },
                                delete: ()async{
                                  await DatabaseHelper().deleteUser(user.id);
                                  setState(() {
                                    _userList.removeAt(index);
                                  });
                                },
                                update: () {
                                  addOrEditUser(user);
                                },
                              ) .animate(delay: (index * 50).ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideX(begin: -0.2, end: 0);
                            }
                        );
                      } else {
                        return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: (MediaQuery.of(context).size.width / 220).toInt(),
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                mainAxisExtent: 250
                            ),
                            itemCount: _userList.length,
                            itemBuilder: (context, index){
                              User user = _userList[index];
                              return CustomerGridviewItem(
                                key: ObjectKey(user),
                                user: user,
                                click: (){
                                  openStatPage(user);
                                },
                                delete: ()async{
                                  await DatabaseHelper().deleteUser(user.id);
                                  setState(() {
                                    _userList.removeAt(index);
                                  });
                                },
                                update: () {
                                  addOrEditUser(user);
                                },
                              ) .animate(delay: (index * 50).ms)
                                  .fadeIn(duration: 500.ms)
                                  .slideX(begin: -0.2, end: 0);
                            }
                        );
                      }
                    },
                  )
              )
            ],
          ),
        )
      ),
      floatingActionButton: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(64, 64)
          ),
          onPressed: ()async{
            String? result = await showDialog(
                context: context,
                builder: (context){
                  return isMobile ? BarcodeScannerSimple() : Dialog(child: SizedBox.expand(),); //TODO: Barcode-Scanner for Windows(or allow scanning at any time?)
                });
            if(result != null){
              if(Uuid.isValidUUID(fromString: result)){
                var user = await DatabaseHelper().getUserByUuid(result);
                if(user != null){
                  openUser(user);
                } else {
                  if(context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          content: Text(S.of(context).main_page_noUserWithUUID),
                          actions: [
                            TextButton(
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                child: Text(S.of(context).close))
                          ],
                        );
                      });
                  }
                }
              }
            }
          },
          label: Text(S.of(context).main_page_scanQrCode),
          icon: Icon(Icons.qr_code_scanner)),
    );
  }
}

class LanguageOption {
  final String code;
  final String label;
  final VoidCallback onPressed;

  LanguageOption({required this.code, required this.label, required this.onPressed});
}

