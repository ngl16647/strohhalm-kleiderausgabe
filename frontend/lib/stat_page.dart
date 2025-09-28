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
  bool uploading = false;
  bool _isMobile = false;
  bool _useServer = false;

  bool saving = false;
  bool editText = false;
  TextEditingController noteEditController = TextEditingController();
  ScrollController noteScrollController = ScrollController();

  bool get isMoreThan14Days => widget.user.lastVisit != null ?  DateTime.now().difference(widget.user.lastVisit!) > Duration(days: 13) : true;

  @override
  void initState() {
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    _useServer = AppSettingsManager.instance.settings.useServer ?? false;
    noteEditController.text = widget.user.notes ?? "";
    getVisits();
    super.initState();
  }

  Future<void> getVisits() async {
    _useServer
        ? _tookItems = await HttpHelper().getALlVisitsFromUser(id: widget.user.id)
        : _tookItems = await DatabaseHelper().getVisits(widget.user.id);
    setState(() {_tookItems;});

  }

  List<Widget> getVisitTiles(){
    return [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: widget.user.lastVisit == null
                ? Colors.grey
                : (isMoreThan14Days)
                ? Colors.green.withAlpha(170)
                : Colors.red.withAlpha(170),
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
                  bool? result = await DialogHelper.dialogConfirmation(
                      context: context,
                      message: S.of(context).stat_page_removeLastVisitConfirmation,
                      hasChoice: true);
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
                label: Text(_isMobile ? "" : S.of(context).stat_page_removeLastVisit, style: TextStyle(color: Colors.black87)),
                icon: Icon(Icons.delete, color: Colors.black87,),
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


  @override
  Widget build(BuildContext context) {
    final isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    return Dialog(
        backgroundColor: Theme.of(context).listTileTheme.tileColor,
        constraints: BoxConstraints(
            maxWidth: isMobile
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width*0.8
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
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
                                Text(S.of(context).stat_page_miscellaneous),
                                Flexible(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 5,
                                          left: 0,
                                          right: 0,
                                          child: AnimatedOpacity(
                                            opacity: saving ? 1.0 : 0.0,
                                            duration: 3.seconds,
                                            curve: Curves.fastLinearToSlowEaseIn,
                                            child: AnimatedSlide(
                                              duration: 3.seconds,
                                              curve: Curves.fastLinearToSlowEaseIn,
                                              offset: saving ? Offset( 0, 0.1) : Offset(0, 0),
                                              child: Container(
                                                height: 40,
                                                alignment: Alignment.bottomCenter,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                                  color: Colors.teal.withAlpha(120),
                                                ),
                                                child: Text("Saved", textAlign: TextAlign.center),
                                              ),
                                            ),
                                            onEnd: () => setState(() => saving = false),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 20),
                                          child: TextField(
                                            selectionControls: materialTextSelectionControls,
                                            scrollController: noteScrollController,
                                            controller: noteEditController,
                                            onTapOutside: (ev) async {
                                              FocusScope.of(context).unfocus();
                                              if(widget.user.notes == noteEditController.text) return;
                                              bool? result;
                                              _useServer
                                                  ? result = await HttpHelper().updateCustomer(widget.user)
                                                  : result = await DatabaseHelper().updateUser(widget.user);
                                              widget.user.notes = noteEditController.text;
                                              if(result != null) setState(() => saving = true);
                                            },
                                            minLines: 1,
                                            maxLines: _isMobile ? 3 : 5,
                                            decoration: InputDecoration(
                                              fillColor: Theme.of(context).listTileTheme.tileColor,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                )
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => CreateQRCode().printQrCode(context, widget.user), //CreateQRCode().showQrCode(context, widget.user),
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
                  Row(
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
            ),
          ).animate().fadeIn(duration: 500.ms),
        )
    );
  }
}