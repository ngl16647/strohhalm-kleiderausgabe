import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';
import 'create_qr_code.dart';
import 'database_helper.dart';
import 'generated/l10n.dart';

class CustomerGridviewItem extends StatefulWidget {
  final User user;
  final VoidCallback click;
  final VoidCallback delete;
  final VoidCallback update;

  const CustomerGridviewItem({
    super.key,
    required this.user,
    required this.click,
    required this.delete, required this.update
  });

  @override
  CustomerListTileState createState() => CustomerListTileState();
}

class CustomerListTileState extends State<CustomerGridviewItem>{
  late User user;
  bool mouseIsOver = false;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  DateTime get lastVisit => DateTime.fromMillisecondsSinceEpoch(user.lastVisit);
  bool get visitMoreThan14Days => DateTime.now().difference(lastVisit).inDays > 13;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(mouseIsOver ? 2 : 4),
      child: InkWell(
        onTap: (){
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
            color: Theme.of(context).listTileTheme.tileColor?.withAlpha(mouseIsOver ? 255 : 220),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text("#${user.id}"),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${user.firstName} ${user.lastName}", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateFormat("dd.MM.yyyy").format(DateTime.fromMillisecondsSinceEpoch(user.birthDay)), style: TextStyle(color: Colors.grey)),
                          Text(Country.tryParse(user.birthCountry)!.name, style: TextStyle(color: Colors.grey))
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
                    color: visitMoreThan14Days ? Colors.green.withAlpha(170) : Colors.red.withAlpha(100),
                  ),
                  constraints: BoxConstraints(minHeight: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(visitMoreThan14Days ? Icons.check_circle : Icons.error),
                      SizedBox(width: 5),
                      Expanded(
                        child:
                        Text.rich(
                          softWrap: true,
                          textAlign: TextAlign.center,
                          TextSpan(
                            children: [
                              TextSpan(text: S.of(context).customer_tile_lastVisit_1),
                              if (user.lastVisit != -1)
                                Utilities().isSameDay(DateTime.now(), lastVisit)
                                    ? TextSpan(text:  S.of(context).customer_tile_lastVisit_2, style: TextStyle(fontWeight: FontWeight.bold))
                                    : TextSpan(text:  "${S.of(context).customer_tile_lastVisit_3}\n"),
                              if (user.lastVisit != -1 && !Utilities().isSameDay(DateTime.now(), lastVisit))
                                TextSpan(
                                  text: DateFormat("dd.MM.yyyy").format(lastVisit),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              if (user.lastVisit == -1) TextSpan(text: S.of(context).customer_tile_lastVisit_4, style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: S.of(context).customer_tile_lastVisit_5),
                            ],
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded( //TODO: adapt logic of buttons -> if lessThan14Days, last Entry should be deletable AND should be able to override, else dont show
                        child: Utilities().isSameDay(DateTime.now(), lastVisit)
                            ? TextButton(
                          onPressed: () async {
                            int? newLastTime = await DatabaseHelper().updateUserLastVisited(user); //Löscht den eintrag aus "TookItems" und update den User in "users"
                            if(newLastTime == null) return;
                            setState(() {
                              user.updateLastVisit(newLastTime);
                            });
                          },
                          style: TextButton.styleFrom(
                              minimumSize: Size(double.infinity, 45),
                              backgroundColor: Color.fromRGBO(169, 171, 25, 0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                              )
                          ),
                          child: Text(S.of(context).customer_tile_deleteLastEntry),
                        )
                            : TextButton(
                          onPressed: () async {
                            setState(() {
                              user.updateLastVisit(DateTime.now().millisecondsSinceEpoch);
                            });
                            await DatabaseHelper().addVisit(user.id, false);
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

                    ],
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          CreateQRCode().printQrCode(context, user);
                          //CreateQRCode().showQrCode(context, user);
                        },
                        icon: Icon(Icons.print),
                      ),
                      IconButton(
                          onPressed: (){
                            widget.update();
                          },
                          icon: Icon(Icons.edit)),
                      // TODO: Decide where to put delete-Button(s)
                      // IconButton(
                      //    onPressed: (){
                      //      widget.delete();
                      //    },
                      //    icon: Icon(Icons.delete))
                    ],
                  ),
                ),
                SizedBox(height: 5,),
              ],
            ),
          ),
        ),
    );
  }
}