import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user_and_visit.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:styled_text/styled_text.dart';
import 'create_qr_code.dart';
import 'dialog_helper.dart';
import 'generated/l10n.dart';

class StatPage extends StatefulWidget {
  final User user;
  //final VoidCallback onFail;

  static Future<User?> showStatPageDialog({
  required BuildContext context,
  required User user,
  }) async{
    return await showDialog<User>(
        context: context,
        builder: (context){
          return StatPage(user: user);
        });
  }

  const StatPage({super.key, required this.user});

  @override
  StatPageState createState() => StatPageState();
}

class StatPageState extends State<StatPage>{
  List<Visit> _tookItems = [];
  //DateTime? _lastVisit;
  bool uploading = false;
  bool _isMobile = false;
  bool _useServer = false;

  bool get isMoreThan14Days => widget.user.lastVisit != null ?  DateTime.now().difference(widget.user.lastVisit!) > Duration(days: 13) : true;

  @override
  void initState() {
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    _useServer = AppSettingsManager.instance.settings.useServer ?? false;
    getVisits();
    super.initState();
  }

  Future<void> getVisits() async {
    _useServer
        ? _tookItems = await HttpHelper().getALlVisitsFromUser(id: widget.user.id)
        : _tookItems = await DatabaseHelper().getVisits(widget.user.id);
    setState(() {
      //if(_tookItems.isNotEmpty) _lastVisit = _tookItems.first.tookTime;
      //widget.user.lastVisit = widget.user.lastVisit;
    });

  }

  List<Widget> getVisitTiles(){
    return [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: widget.user.lastVisit == null
                ? Colors.grey
                : (isMoreThan14Days)
                ? Colors.lightGreen
                : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon((isMoreThan14Days) ? Icons.check_circle : Icons.block),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).stat_page_lastTimeTookClothes),
                    StyledText(
                      text: widget.user.lastVisit == null
                          ? S.of(context).customer_tile_lastVisit_never
                          : "${DateFormat(_useServer ? "dd.MM.yyyy" : "dd.MM.yyyy HH:mm").format(widget.user.lastVisit!)} ${Utilities.isSameDay(DateTime.now(), widget.user.lastVisit!) && !_isMobile ? " (${S.of(context).today})" : ""}",
                      style: TextStyle(fontSize: 18),

                    ),
                  ],
                ),
              ),
              _tookItems.isNotEmpty
                  ? TextButton.icon(
                onPressed: () async {
                  bool? result = await DialogHelper.dialogConfirmation(context, S.of(context).stat_page_removeLastVisitConfirmation, true);
                  if (result != null) {

                    String? newLastTime;
                    _useServer
                        ? newLastTime = await HttpHelper().deleteVisit(customerId: widget.user.id)
                        : newLastTime = await DatabaseHelper().deleteLatestAndReturnPrevious(widget.user);

                    setState(() {
                      if(_tookItems.isNotEmpty) _tookItems.removeAt(0);
                      DateTime? newVisitTime = newLastTime == null ? null : DateTime.parse(newLastTime);
                      widget.user.lastVisit = newVisitTime;
                    });
                  }
                },
                label: Text(_isMobile ? "" : S.of(context).stat_page_removeLastVisit),
                icon: Icon(Icons.delete),
              ) : SizedBox.shrink(),
            ],
          ),
        ),
      )
    ];
  }

  Widget buildInfo({required Text title, required Text value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        title,
        value
      ],
    );
  }

  bool editText = false;
  TextEditingController noteEditController = TextEditingController();
  ScrollController noteScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    return Dialog(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width*0.8
          ),
          child:PopScope(
            canPop: false,
            onPopInvokedWithResult: (popped, ev){
              if(!popped){
                //To update List when barrier-dismissing Dialog
                Navigator.of(context).pop(widget.user);
              }
            },
            child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Card(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 20,
                            children: [
                              Container(
                                  height: 90,
                                  width: 90,
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.fromBorderSide(BorderSide(width: 1, color: Colors.black87))
                                  ),
                                  child:Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: QrImageView(
                                        backgroundColor: Colors.white,
                                        version: QrVersions.auto,
                                        data: widget.user.uuId,
                                        //Icon(Icons.account_circle, size: 22),
                                      ),
                                    ),
                                  )
                              ),
                              Expanded(
                                child: Wrap(
                                  spacing: 20,
                                  runSpacing: 15,
                                  children: [
                                    buildInfo(
                                        title: Text("${widget.user.firstName} ${widget.user.lastName}", softWrap: true,),
                                        value: Text(DateFormat("dd.MM.yyyy").format(widget.user.birthDay), style: TextStyle(color: Colors.grey), softWrap: false, overflow: TextOverflow.visible,)
                                    ),
                                    // Birth Country
                                    ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 150),
                                        child: buildInfo(
                                            title: Text(S.of(context).stat_page_country),
                                            value: Text(Utilities.getLocalizedCountryNameFromCode(context, widget.user.country), style: TextStyle(color: Colors.grey))
                                        )
                                    ),
                                    //overallVisits
                                    buildInfo(
                                            title: Text(S.of(context).stat_page_visits),
                                            value: Text(_tookItems.length.toString(), style: TextStyle(color: Colors.grey),)
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 30,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(S.of(context).stat_page_miscellaneous),
                                    if(!editText)TextButton.icon(
                                      onPressed: (){
                                        setState(() {
                                          noteEditController.text = widget.user.notes ?? "";
                                          editText = true;
                                        });
                                      },
                                      icon: Icon(!editText ? Icons.edit : Icons.check_circle),
                                      label: Text(!editText ? S.of(context).edit : S.of(context).confirm),
                                    ),
                                  ],
                                ),
                              ),
                              !editText
                                  ? ConstrainedBox(
                                      constraints : BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height*0.2,
                                        minWidth: double.infinity,
                                      ),
                                      child: Container(
                                          width: double.infinity,

                                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.fromBorderSide(BorderSide(width: 1, color: Colors.black45))
                                          ),
                                          child:Scrollbar(
                                        thumbVisibility: true,
                                        controller: noteScrollController,
                                        child: ShaderMask(
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
                                                stops: [0.0, 0.05, 0.95, 1.0],
                                              ).createShader(bounds);
                                            },
                                            blendMode: BlendMode.dstIn, // Wichtig für den Maskeneffekt
                                            child:SingleChildScrollView(
                                          controller: noteScrollController,
                                          child: GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                noteEditController.text = widget.user.notes ?? "";
                                                editText = true;
                                              });
                                            },
                                            child:  Text(widget.user.notes ?? "", style: TextStyle(height: 1.4, fontSize: 17),),
                                            )
                                          ),
                                        ))
                                      ),
                                    )
                                  : TextField(
                                    controller: noteEditController,
                                    minLines: 1,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                              ),
                             if(editText)SizedBox(height: 2),
                             editText ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                spacing: 10,
                                children: [
                                  if(!_isMobile)Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        noteEditController.text = widget.user.notes ?? "";
                                        editText = false;
                                      });
                                    },
                                    icon: Icon(Icons.cancel),
                                    label: Text(S.of(context).cancel),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      maximumSize: _isMobile ? Size(MediaQuery.of(context).size.width*0.27, 50) : null,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      setState(() {
                                        widget.user.notes = noteEditController.text;
                                        editText = false;
                                      });
                                      bool? result;
                                      _useServer
                                        ? result = await HttpHelper().updateCustomer(widget.user)
                                        : result = await DatabaseHelper().updateUser(widget.user);

                                      if(context.mounted){
                                        Utilities.showToast(
                                            context: context,
                                            title: result != null ? S.of(context).success : S.of(context).fail,
                                            description: result != null ? S.of(context).update_success : S.of(context).update_failed,
                                            isError: result == null
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.check),
                                    label: Text(S.of(context).save),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      backgroundColor: Colors.green.withAlpha(120),
                                      maximumSize: _isMobile ? Size(MediaQuery.of(context).size.width*0.27, 50) : null,
                                    ),
                                  ),
                                ],
                              ) : SizedBox(height: 25,)
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => CreateQRCode.printQrCode(context, widget.user), //CreateQRCode().showQrCode(context, widget.user),
                            icon: Icon(Icons.qr_code),
                            label: Text(S.of(context).qr_code_print),
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primaryFixed.withAlpha(120),
                                minimumSize: Size(double.infinity, 64)
                            ),
                          )
                        ],
                      ),)
                ),
                isMobile
                    ? Container(
                  constraints: BoxConstraints(maxHeight: 100),
                  child: Column(
                    spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    children: getVisitTiles(),
                  ),
                )
                    : Row(
                  spacing: 10,
                  children: getVisitTiles(),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                        flex: 2,
                        child: TextButton(
                            onPressed: ()async{
                              if(widget.user.lastVisit != null && Utilities.isSameDay(widget.user.lastVisit!, DateTime.now())) {
                                if(context.mounted) Utilities.showToast(context: context, title:  S.of(context).fail, description: S.of(context).stat_page_alreadyGotToday, isError: true);
                                return;
                              }
                              setState(() {
                                uploading = true;
                              });
                              Visit? newLastVisit = await Utilities.addVisit(widget.user, context, true);
                              setState(() {
                                if(newLastVisit != null) {
                                  widget.user.lastVisit = newLastVisit.tookTime;
                                 _tookItems.insert(0, newLastVisit);
                                 }
                                uploading = false;
                              });
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primaryFixed.withAlpha(120),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: Size(double.infinity, 75)
                            ),
                            child: uploading ? Center(child: CircularProgressIndicator()) : Text( S.of(context).customer_tile_addNewEntry(isMoreThan14Days))))
                  ],
                )
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
        )
    );
  }
}

/* Dialog for showAllVisits
TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 42),
                backgroundColor: Colors.lime.withAlpha(70),
              ),
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (context){
                        return StatefulBuilder(
                            builder: (context, state){
                              return AlertDialog(
                                constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width * 0.5
                                ),
                                content:  Scaffold(
                                  body: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _tookItems.length,
                                        itemBuilder: (context, index){
                                          TookItem item = _tookItems[index];
                                          return ListTile(
                                            title: Text(DateFormat("dd.MM.yyyy HH:mm").format(DateTime.fromMillisecondsSinceEpoch(item.tookTime))),
                                            trailing: IconButton(
                                                onPressed: () async {
                                                  late TookItem itemToDelete;
                                                  state(() {
                                                    itemToDelete = _tookItems.removeAt(index);
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                        duration: Duration(seconds: 3),
                                                        content: Text("Löschen rückgängig machen?"),
                                                        action: SnackBarAction(
                                                            label: "Undo",
                                                            onPressed: (){
                                                              setState(() {
                                                                _tookItems.insert(index, itemToDelete);
                                                              });
                                                            })
                                                    ),
                                                  );
                                                  await Future.delayed(Duration(seconds: 3));
                                                  if(_tookItems.contains(item)) return;
                                                  int? newLastDate = await DatabaseHelper().updateUserLastVisited(widget.user.id, item.tookTime);
                                                  setState(() {
                                                    if(newLastDate != null){
                                                      widget.user.updateLastVisit(newLastDate);
                                                    }
                                                  });
                                                },
                                                icon: Icon(Icons.delete)),
                                          );
                                        }),
                                  ),
                                );
                            }
                        );
                      });
                },
                child: Text("Show all Visists")),*/