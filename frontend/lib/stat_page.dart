import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:styled_text/styled_text.dart';
import 'create_qr_code.dart';
import 'generated/l10n.dart';

class StatPage extends StatefulWidget {
  final User user;

  const StatPage({super.key, required this.user});

  @override
  StatPageState createState() => StatPageState();
}

class StatPageState extends State<StatPage>{
  List<TookItem> _tookItems = [];
  DateTime? _lastVisit;
  bool _changed = false;
  bool uploading = false;

  bool get isMoreThan14Days => _lastVisit != null ?  DateTime.now().difference(_lastVisit!) > Duration(days: 13) : true;

  @override
  void initState() {
    getVisits();
    super.initState();
  }

  Future<void> getVisits() async {
    _tookItems = widget.user.visits;
    setState(() {
      if(_tookItems.isNotEmpty) _lastVisit = _tookItems.first.tookTime;
    });

    //if (_tookItems.any((item) => item.wasBedSheet)) {
    //  lastBedSheetItem = _tookItems
    //      .where((item) => item.wasBedSheet)
    //      .reduce((a, b) => a.tookTime.isAfter(b.tookTime) ? a : b);
    //}
  }

  List<Widget> getVisitTiles(){
    return [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: _lastVisit == null //TODO: Gray or green?
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
                      text: _lastVisit == null
                          ? S.of(context).customer_tile_lastVisit_never
                          : "${DateFormat("dd.MM.yyyy HH:mm").format(_lastVisit!)} ${Utilities().isSameDay(DateTime.now(), _lastVisit!) ? " (${S.of(context).today})" : ""}",
                      style: TextStyle(fontSize: 18),

                    ),
                  ],
                ),
              ),
              _tookItems.isNotEmpty
                  ? TextButton.icon(
                onPressed: () async {
                  bool? result = await Utilities().dialogConfirmation(context, S.of(context).stat_page_removeLastVisitConfirmation);
                  if (result != null) {
                    DateTime? newVisit = await DatabaseHelper().deleteLatestAndReturnPrevious(widget.user);
                      setState(() {
                        //_tookItems.removeAt(0);
                        if(_tookItems.isNotEmpty) _tookItems.removeAt(0);
                        _lastVisit = newVisit;
                      });

                    _changed = true;
                  }
                },
                label: Text(S.of(context).stat_page_removeLastVisit),
                icon: Icon(Icons.delete),
              ) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
      /*Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: lastBedSheetItem == null
                ? Colors.grey
                : (DateTime.now().difference(
                DateTime.fromMillisecondsSinceEpoch(lastBedSheetItem!.tookTime)) >
                Duration(days: 13))
                ? Colors.lightGreen
                : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                lastBedSheetItem == null
                    ? Icons.help_outline
                    : (DateTime.now().difference(
                    DateTime.fromMillisecondsSinceEpoch(
                        lastBedSheetItem!.tookTime)) >
                    Duration(days: 13))
                    ? Icons.check_circle
                    : Icons.block,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Last Time took Bedsheets"),
                    Text(lastBedSheetItem != null ? DateFormat("dd.MM.yy HH:mm").format(DateTime.fromMillisecondsSinceEpoch(lastBedSheetItem!.tookTime)) : "Never", style: TextStyle(fontSize: 18),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),*/
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    return  Dialog(
          child:PopScope(
            canPop: false,
            onPopInvokedWithResult: (popped, ev){
              if(!popped){
                //To update List when barrier-dismissing Dialog
                Navigator.of(context).pop(_changed ? _tookItems : null);
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
                          GridView.count(
                            crossAxisCount: (MediaQuery.of(context).size.width / 180).floor().clamp(1, 10),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: isMobile ? 1.5 : 1,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              // Icon
                              Container(
                                  height: 40,
                                  width: 40,
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.fromBorderSide(BorderSide(width: 1, color: Colors.black87))
                                  ),
                                  child:Center(
                                    child: QrImageView(
                                      backgroundColor: Colors.white,
                                      version: QrVersions.auto,
                                      data: widget.user.uuId,
                                      //Icon(Icons.account_circle, size: 22),
                                    ),
                                  )
                              ),
                              // Name + Birthday
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10,),
                                  Text("${widget.user.firstName} ${widget.user.lastName}"),
                                  Text(
                                    DateFormat("dd.MM.yyyy").format(widget.user.birthDay),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              // Birth Country
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10,),
                                  Text(S.of(context).stat_page_country),
                                  Text(CountryLocalizations.of(context)?.countryName(countryCode: widget.user.birthCountry) ?? Country.tryParse(widget.user.birthCountry)!.name, style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              // Has Children
                              //Column(
                              //  crossAxisAlignment: CrossAxisAlignment.start,
                              //  mainAxisAlignment: MainAxisAlignment.start,
                              //  children: [
                              //    SizedBox(height: 10,),
                              //    Text(S.of(context).children),
                              //    Text(widget.user.hasChild ? "Ja" : "Nein", style: TextStyle(color: Colors.grey)),
                              //  ],
                              //),
                              //overallVisits
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10,),
                                  Text(S.of(context).stat_page_visits),
                                  Text(_tookItems.length.toString(), style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.of(context).stat_page_miscellaneous),
                              Text(widget.user.miscellaneous ?? "")
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => CreateQRCode().printQrCode(context, widget.user), //CreateQRCode().showQrCode(context, widget.user),
                            icon: Icon(Icons.qr_code),
                            label: Text(S.of(context).qr_code_print),
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.lime.withAlpha(70),
                                minimumSize: Size(double.infinity, 64)
                            ),
                          )
                        ],
                      ),)
                ),
                isMobile
                    ? Container(
                  constraints: BoxConstraints(maxHeight: 150),
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
                    /*Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Bedsheet"),
                        Checkbox(
                            value: takesBedsheet,
                            onChanged: (ev){
                              setState(() {
                                takesBedsheet = ev!;
                              });
                            })
                      ],
                    )),*/
                    Expanded(
                        flex: 2,
                        child: TextButton(
                            onPressed: ()async{
                              if(_tookItems.any((item) => Utilities().isSameDay(item.tookTime, DateTime.now()))) {
                                if(!context.mounted) return;
                                Utilities().showToast(context: context, title: "Already Visited Today", description: S.of(context).stat_page_alreadyGotToday, isError: true);
                                return;
                              }
                              setState(() {
                                uploading = true;
                              });
                              TookItem newestVisit = await DatabaseHelper().addVisit(widget.user.id);
                              _tookItems.insert(0,newestVisit);
                              setState(() {
                                _lastVisit = newestVisit.tookTime;
                                uploading = false;
                              });
                              _changed = true;
                              if(!context.mounted) return;
                              Utilities().showToast(context: context, title: "Success", description: S.of(context).stat_page_savedVisit);
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.lime.withAlpha(70),
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