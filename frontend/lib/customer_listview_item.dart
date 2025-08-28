import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/create_qr_code.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:styled_text/styled_text.dart';

import 'generated/l10n.dart';

//TODO: Maybe combine List and Grid_Tile in a single Class
class CustomerListviewItem extends StatefulWidget {
  final User user;
  final VoidCallback click;
  final VoidCallback delete;
  final VoidCallback update;

  const CustomerListviewItem({
    super.key,
    required this.user,
    required this.click,
    required this.delete,
    required this.update,
  });

  @override
  CustomerListviewItemState createState() => CustomerListviewItemState();
}

class CustomerListviewItemState extends State<CustomerListviewItem>{
  late User user;
  bool mouseIsOver = false;
  int lastVisit = -1;

  @override
  void initState() {
    user = widget.user;
    if(widget.user.tookItems.isNotEmpty) lastVisit = user.tookItems.first.tookTime;
    super.initState();
  }

  DateTime get lastVisitDateTime => DateTime.fromMillisecondsSinceEpoch(lastVisit);
  bool get visitMoreThan14Days => DateTime.now().difference(lastVisitDateTime).inDays > 13;

  String _buildLastVisitStyledText() {
    if (lastVisit == -1) {
      // Noch nie da gewesen
      return S.of(context).customer_tile_lastVisit_never;
    } else if (Utilities().isSameDay(DateTime.now(), lastVisitDateTime)) {
      // Heute da gewesen
      return S.of(context).customer_tile_lastVisit_today;
    } else {
      // An einem anderen Tag da gewesen
      final dateString = DateFormat("dd.MM.yyyy").format(lastVisitDateTime);
      return S.of(context).customer_tile_lastVisit_onDate(dateString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mouseIsOver ? 1 : 3, horizontal: 3),
      child: InkWell(
        onTap: (){
          //openStatPage(user);
          widget.click();
        },
        onHover: (isHovering){
          setState(() {
            mouseIsOver = isHovering;
          });
        },
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).listTileTheme.tileColor?.withAlpha(mouseIsOver ? 255 : 200),
          child: Padding(
            padding: EdgeInsets.all(mouseIsOver ? 4 : 2),
            child: Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10),
                Text(user.id.toString()),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${user.firstName} ${user.lastName}", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            DateFormat("dd.MM.yyyy").format(DateTime.fromMillisecondsSinceEpoch(user.birthDay)),
                              style: TextStyle(color: Theme.of(context).textTheme.headlineSmall!.color?.withAlpha(170))
                          ),
                          SizedBox(width: 10),
                          Text(
                            Country.tryParse(user.birthCountry)!.name,
                            style: TextStyle(color: Theme.of(context).textTheme.headlineSmall!.color?.withAlpha(170)),
                          ),
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
                        color: visitMoreThan14Days ? Colors.green.withAlpha(170) : Colors.red.withAlpha(100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(visitMoreThan14Days ? Icons.check_circle : Icons.error),
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
                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 10),
                        if(!visitMoreThan14Days) Expanded( //TODO: adapt logic of buttons -> if lessThan14Days, last Entry should be deletable AND should be able to override, else dont show
                          child:  TextButton(
                            onPressed: () async {
                              int? newLastTime = await DatabaseHelper().deleteLatestAndReturnPrevious(user); //Deletes last entry and returns new last as millisecondsSinceEpoch
                              if(newLastTime == null) return;
                              setState(() {
                                lastVisit = newLastTime;
                                widget.user.tookItems.removeAt(0);
                                //lastVisit = widget.user.tookItems.isNotEmpty ? widget.user.tookItems.first.tookTime : -1; //TODO: Better? then deleteLatestAndReturnPrevious could be simpler
                              });
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
                        if(!visitMoreThan14Days && !Utilities().isSameDay(DateTime.now(), lastVisitDateTime.add(Duration(days: -1)))) SizedBox(width: 5,),
                        if(!Utilities().isSameDay(DateTime.now(), lastVisitDateTime.add(Duration(days: -1))))
                          Expanded(
                          child: TextButton(
                            onPressed: () async {
                              setState(() {
                                lastVisit = DateTime.now().millisecondsSinceEpoch;
                              });
                              TookItem item = await DatabaseHelper().addVisit(user.id, false);
                              widget.user.tookItems.insert(0, item);
                            },
                            style: TextButton.styleFrom(
                                minimumSize: Size(double.infinity, 45),
                                backgroundColor: Color.fromRGBO(169, 171, 25, 0.4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)
                                )
                            ),
                            child: Text(S.of(context).customer_tile_addNewEntry(visitMoreThan14Days), textAlign: TextAlign.center,),
                          ),
                        ),
                        SizedBox(width: 10,),
                        IconButton(
                          onPressed: () {
                            CreateQRCode().printQrCode(context, user);
                            //CreateQRCode().showQrCode(context, user);
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
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}