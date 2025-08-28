import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
    // More reliable way to detect mobile platforms
    isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    searchUsers("");
    super.initState();
  }

  ///Gets Users with the firstName/Lastname LIKE the searchTerm. "*" gets all
  Future<void> searchUsers(String searchTerm) async {
    //TODO: Probably include a Search-Button, so there are less unnecessary server-requests
    _userList.clear();
    if (searchTerm == "*") {
      _userList = await DatabaseHelper().getUsers("");
    } else if (searchTerm.trim().isNotEmpty) {
      //WhiteSpaces get removed so a SPACE doesn't just retrieve All
      _userList = await DatabaseHelper().getUsers(searchTerm);
    }
    setState(() {
      _userList;
    });
  }

  ///Opens the detailed View of a User
  Future<void> openStatPage(User user) async {
    bool? updated = await showDialog<bool>(
        context: context,
        builder: (context) {
          return Dialog(
            child: StatPage(user: user),
          );
        });

    if (updated != null) {
      searchUsers(_searchController.text);
    }
  }

  ///Adds or edits a User (if you want to edit, you have to give it a existing User)
  Future<void> addOrEditUser([User? user]) async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddUserDialog(user: user);
        });
    if (result != null) {
      User? newUser = result[0];
      bool delete = result[1];

      if (delete) {
        await DatabaseHelper().deleteUser(newUser!.id);
        setState(() {
          _userList.removeWhere((listUser) => listUser.id == user?.id);
        });
      } else {
        //Here so there doesn't have to be a extra Call to the Database
        if (newUser != null) {
          int index = _userList.indexWhere((item) => item.id == newUser.id);
          if (index != -1) {
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

  void openUser(User user) {
    _userList.clear();
    openStatPage(user);
    setState(() {
      _userList.add(user);
    });
    _searchController.text = "${user.firstName} ${user.lastName}";
  }

  @override
  Widget build(BuildContext context) {
    var languages = [
      LanguageOption(
          code: "de",
          label: S.of(context).language_de,
          onPressed: () {
            widget.onLocaleChange(Locale("de"));
          }),
      LanguageOption(
          code: "gb",
          label: S.of(context).language_en,
          onPressed: () {
            widget.onLocaleChange(Locale("en"));
          }),
      // LanguageOption(code: "ru", label: "Russisch", onPressed: () {}),
      // LanguageOption(code: "ro", label: "Rumänien", onPressed: () {}),
      // Here one can add new Languages if necessary (code = Country-Code from http://www.lingoes.net/en/translator/langcode.htm)
    ];

    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     Image.asset(
      //       isMobile
      //           ? "assets/images/strohalm_header_image_mobile.png"
      //           : "assets/images/strohalm_header_image.png",
      //     ),
      //   ],
      // ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          children: [
            SizedBox(
              width: double.infinity, // Ensure infinite width
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.start,
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
                          return Icon(
                              Icons.fullscreen); // Default icon while loading
                        },
                      ),
                      label: Text(S.of(context).fullscreen),
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
                  ActionChip(
                    avatar: (Theme.of(context).brightness == Brightness.dark)
                        ? Icon(Icons.dark_mode)
                        : Icon(Icons.light_mode),
                    label: Text(S.of(context).theme),
                    onPressed: () async {
                      MyApp.of(context).changeTheme();
                      setState(() {});
                    },
                  ),
                  ...languages.map((lang) => ActionChip(
                        avatar: CountryFlag.fromCountryCode(
                          lang.code,
                          height: 12,
                          width: 16,
                        ),
                        label: Text(lang.label),
                        onPressed: lang.onPressed,
                      ))
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(
                minHeight: 32,
              ),
              height: MediaQuery.of(context).size.height * 0.1,
              child: Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 10,
                    child: Stack(
                      children: [
                        Align(
                          // alignment: AlignmentGeometry.center,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: S.of(context).search_hint,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (ev) {
                              searchUsers(ev);
                            },
                            onTapOutside: (ev) {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.text = "";
                                _userList.clear();
                              });
                            },
                            icon: Icon(Icons.close),
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: !isMobile
                          ? TextButton.icon(
                              onPressed: () {
                                addOrEditUser();
                              },
                              style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  backgroundColor:
                                      Color.fromRGBO(169, 171, 25, 1.0),
                                  foregroundColor: Colors.black87,
                                  minimumSize: Size(double.infinity, 64)),
                              label: Text(S.of(context).add_user),
                              icon: Icon(Icons.person_add_alt_1,
                                  color: Colors.black87),
                            )
                          : IconButton(
                              onPressed: () {
                                addOrEditUser();
                              },
                              style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  backgroundColor:
                                      Color.fromRGBO(169, 171, 25, 1.0),
                                  foregroundColor: Colors.black87,
                                  minimumSize: Size(double.infinity, 64)),
                              icon: Icon(Icons.person_add_alt_1,
                                  color: Colors.black87),
                            ))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isMobile)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isListView = !isListView;
                        });
                      },
                      icon: Icon(isListView ? Icons.grid_on : Icons.list),
                      label: Text(isListView
                          ? S.of(context).tiles
                          : S.of(context).list),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, state) {
                            final size = MediaQuery.of(context).size;
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: SizedBox(
                                width: size.width * 0.9,
                                height: size.height * 0.9,
                                child: StatisticPage(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  label: Text(S.of(context).statistics),
                  icon: Icon(Icons.bar_chart),
                )
              ],
            ),
            Expanded(
                child: _userList.isEmpty
                    ? Center(
                        child: Text(S.of(context).no_items_text),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 682 && isListView) {
                            return ListView.builder(
                                itemCount: _userList.length,
                                itemBuilder: (context, index) {
                                  User user = _userList[index];
                                  return CustomerListviewItem(
                                    key: ObjectKey(user),
                                    user: user,
                                    click: () {
                                      openStatPage(user);
                                    },
                                    delete: () async {
                                      await DatabaseHelper()
                                          .deleteUser(user.id);
                                      setState(() {
                                        _userList.removeAt(index);
                                      });
                                    },
                                    update: () {
                                      addOrEditUser(user);
                                    },
                                  )
                                      .animate(delay: (index * 50).ms)
                                      .fadeIn(duration: 500.ms)
                                      .slideX(begin: -0.2, end: 0);
                                });
                          } else {
                            return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            (MediaQuery.of(context).size.width /
                                                    220)
                                                .toInt(),
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        mainAxisExtent: 250),
                                itemCount: _userList.length,
                                itemBuilder: (context, index) {
                                  User user = _userList[index];
                                  return CustomerTile(
                                    key: ObjectKey(user),
                                    user: user,
                                    click: () {
                                      openStatPage(user);
                                    },
                                    delete: () async {
                                      await DatabaseHelper()
                                          .deleteUser(user.id);
                                      setState(() {
                                        _userList.removeAt(index);
                                      });
                                    },
                                    update: () {
                                      addOrEditUser(user);
                                    },
                                  )
                                      .animate(delay: (index * 50).ms)
                                      .fadeIn(duration: 500.ms)
                                      .slideX(begin: -0.2, end: 0);
                                });
                          }
                        },
                      ))
          ],
        ),
      )),
      floatingActionButton: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(minimumSize: Size(64, 64)),
          onPressed: () async {
            String? result = await showDialog(
                context: context,
                builder: (context) {
                  return isMobile
                      ? BarcodeScannerSimple()
                      : Dialog(
                          child: SizedBox.expand(),
                        ); //TODO: Barcode-Scanner for Windows(or allow scanning at any time?)
                });
            if (result != null) {
              if (Uuid.isValidUUID(fromString: result)) {
                var user = await DatabaseHelper().getUserByUuid(result);
                if (user != null) {
                  openUser(user);
                } else {
                  if (context.mounted) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(S.of(context).no_items_text),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(S.of(context).dialog_cancel))
                            ],
                          );
                        });
                  }
                }
              }
            }
          },
          label: Text(S.of(context).scan_code),
          icon: Icon(Icons.qr_code_scanner)),
    );
  }
}

class LanguageOption {
  final String code;
  final String label;
  final VoidCallback onPressed;

  LanguageOption(
      {required this.code, required this.label, required this.onPressed});
}

//Maybe over the SearchBar? I dont like the Positioning of the Fullscreen, darkmode, languages...
// TM: Find ich gut
