import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/create_qr_code.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/user_and_visit.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:styled_text/styled_text.dart';
import 'generated/l10n.dart';
import 'http_helper.dart';

///Display of Customers on the main_page
class CustomerTile extends StatefulWidget {
  final bool isListView;
  final User user;
  final VoidCallback click;
  final VoidCallback updatedVisit;
  final VoidCallback update;

  const CustomerTile({
    super.key,
    required this.isListView,
    required this.user,
    required this.click,
    required this.updatedVisit,
    required this.update,
  });

  @override
  CustomerTileState createState() => CustomerTileState();
}

class CustomerTileState extends State<CustomerTile>{
  bool _mouseIsOver = false;
  bool _uploading = false;
  bool _useServer = false;

  bool _allowAdding = false;
  bool _allowDeleting = false;
  int _cutOffNumber = 14;

  @override
  void initState() {
    var settings = AppSettingsManager.instance.settings;
    _useServer = settings.useServer ?? false;
    _allowAdding = settings.allowAdding ?? false;
    _allowDeleting = settings.allowDeleting ?? false;
    _cutOffNumber = settings.cutOffDayNumber ?? 14;
    _cutOffNumber = _cutOffNumber-1;
    super.initState();
  }

  bool get visitIsMoreThan14Days => widget.user.lastVisit != null
      ? !_useServer
        ?  DateTime.now().difference(widget.user.lastVisit!).inHours > _cutOffNumber*24+12
        :  DateTime.now().difference(widget.user.lastVisit!).inDays > _cutOffNumber
      : true;

  ///Creates the Text that displays the lastVisit status
  String _buildLastVisitStyledText() {
    //print(DateTime.now().difference(widget.user.lastVisit!).inDays);
    //print("Cuttoff $_cutOffNumber");
    //print("----------------");
    if (widget.user.lastVisit == null) {
      // Never visited
      return S.of(context).customer_tile_lastVisit_never;
    } else if (Utilities.isSameDay(DateTime.now(), widget.user.lastVisit!)) {
      // visited today
      return S.of(context).customer_tile_lastVisit_today;
    } else {
      // Visited on !today
      final dateString = DateFormat("dd.MM.yyyy").format(widget.user.lastVisit!);
      return S.of(context).customer_tile_lastVisit_onDate(dateString);
    }
  }

  ///Creates the available buttons depending on the lastVisit
  Widget? _buildVisitActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //If user should be able to book anyway: if(!visitMoreThan14Days)
        if(_allowDeleting
            ? !visitIsMoreThan14Days
            : widget.user.lastVisit != null && Utilities.isSameDay(DateTime.now(), widget.user.lastVisit!)) Expanded(
          child:  TextButton(
            onPressed: () async {
              String? newLastTime;
              _useServer
                  ? newLastTime = await HttpHelper().deleteVisit(customerId: widget.user.id)
                  : newLastTime = await DatabaseHelper().deleteLatestAndReturnPrevious(widget.user);
              if(newLastTime == "-1") return;
              DateTime? newVisitTime = newLastTime == null ? null : DateTime.parse(newLastTime);
              setState(() {
                widget.user.lastVisit = newVisitTime;
              });
              widget.updatedVisit();
            },
            style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
                backgroundColor: Color.fromRGBO(169, 171, 25, 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                )
            ),
            child: Text(S.of(context).customer_tile_deleteLastEntry, textAlign: TextAlign.center,),
          ),
        ),

        if(_allowAdding && !visitIsMoreThan14Days && !Utilities.isSameDay(DateTime.now(), widget.user.lastVisit!)) SizedBox(width: 5,),
        //if(widget.user.lastVisit == null || visitIsMoreThan14Days) //If user should be able to book anyway: if(widget.user.lastVisit == null || !Utilities.isSameDay(DateTime.now(), widget.user.lastVisit!))
        if(_allowAdding
            ? widget.user.lastVisit == null || !Utilities.isSameDay(DateTime.now(), widget.user.lastVisit!)
            : widget.user.lastVisit == null || visitIsMoreThan14Days)
          Expanded(
            child: TextButton(
              onPressed: () async {
                setState(() {
                  _uploading = true;
                });

                Visit? newLastVisit = await Utilities.addVisit(widget.user, context, true);
                setState(() {
                  if(newLastVisit != null){
                    widget.user.lastVisit = newLastVisit.tookTime;
                  }
                  _uploading = false;
                });
                if(!mounted) return;
                widget.updatedVisit();
              },
              style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 45),
                  backgroundColor: Color.fromRGBO(169, 171, 25, 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  )
              ),
              child: _uploading ? SizedBox(
                height: 24, // kleiner als 40
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ) : Text(S.of(context).customer_tile_addNewEntry(visitIsMoreThan14Days), textAlign: TextAlign.center,),
            ),
          ),
      ],
    );
  }

  ///Creates a ListItem of the customer
  Widget buildListTile(){
    return Padding(
        padding: EdgeInsets.all(_mouseIsOver ? 4 : 2),
        child: Row(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(),
            SizedBox(
              width: 32,
              child:  Text(widget.user.id.toString(),textAlign: TextAlign.start,),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: "${widget.user.firstName} ${widget.user.lastName}",
                    child: Text("${widget.user.firstName} ${widget.user.lastName}", style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 2,),
                  ),
                  Row(
                    spacing: 0,
                    children: [
                      Flexible(
                        child: Text(
                          DateFormat("dd.MM.yyyy").format(widget.user.birthDay),
                          style: TextStyle(color: Theme.of(context).textTheme.headlineSmall!.color?.withAlpha(170))
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Tooltip(
                          message: Utilities.getLocalizedCountryNameFromCode(context, widget.user.country),
                          child: Text(
                            Utilities.getLocalizedCountryNameFromCode(context, widget.user.country),
                            style: TextStyle(color: Theme.of(context).textTheme.headlineSmall!.color?.withAlpha(170)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: visitIsMoreThan14Days ? Colors.green.withAlpha(170) : Colors.red.withAlpha(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(visitIsMoreThan14Days ? Icons.check_circle : Icons.error),
                      SizedBox(width: 5),
                      Flexible(
                        child: StyledText(
                          text: _buildLastVisitStyledText(),
                          tags: {
                            "bold": StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
                          },
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                )
            ),
            Expanded(
              flex: 3 ,
              child: Container(
                padding: EdgeInsets.all(2),
                child: _buildVisitActions(),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    CreateQRCode().printQrCode(context, widget.user);
                  },
                  icon: Icon(Icons.print),
                ),
                IconButton(
                  onPressed: () {
                    widget.update();
                  },
                  icon: Icon(Icons.edit),
                ),
              ],
            )
          ],
        )
    );
  }

  ///Creates a gridTile of a customer
  Widget buildGridTile(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text("#${widget.user.id}"),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${widget.user.firstName} ${widget.user.lastName}", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(DateFormat("dd.MM.yyyy").format(widget.user.birthDay), style: TextStyle(color: Colors.grey)),
                  Text(Utilities.getLocalizedCountryNameFromCode(context, widget.user.country), style: TextStyle(color: Colors.grey))
                ],
              )

            ],
          ),
        ),
        Container(
          margin: EdgeInsets.all(5),
          padding:  EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: visitIsMoreThan14Days ? Colors.green.withAlpha(170) : Colors.red.withAlpha(100),
          ),
          constraints: BoxConstraints(minHeight: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(visitIsMoreThan14Days ? Icons.check_circle : Icons.error),
              SizedBox(width: 5),
              Expanded(
                child: StyledText(
                  text: _buildLastVisitStyledText(),
                  tags: {
                    "bold": StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
                  },
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: _buildVisitActions(),
        ),
        Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  CreateQRCode().printQrCode(context, widget.user);
                },
                icon: Icon(Icons.print),
              ),
              IconButton(
                  onPressed: (){
                    widget.update();
                  },
                  icon: Icon(Icons.edit)),
            ],
          ),
        ),
        SizedBox(height: 5,),
      ],
    );
  }

  ///handels display as Tile/grid depending on screenWidth/Mobile
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _mouseIsOver ? 1 : 3, horizontal: 3),
      child: InkWell(
        borderRadius:  BorderRadius.circular(12),
        onTap: (){
          //openStatPage(user);
          widget.click();
        },
        onHover: (isHovering){
          setState(() {
            _mouseIsOver = isHovering;
          });
        },
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).listTileTheme.tileColor?.withAlpha(_mouseIsOver ? 255 : 200),
          child: widget.isListView
              ? buildListTile()
              : buildGridTile()
        ),
      ),
    );
  }
}