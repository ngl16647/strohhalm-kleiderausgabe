import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/create_qr_code.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';

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
    required this.delete, required this.update
  });

  @override
  CustomerListviewItemState createState() => CustomerListviewItemState();
}

class CustomerListviewItemState extends State<CustomerListviewItem>{
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
      padding: EdgeInsets.symmetric(vertical: mouseIsOver ? 1 : 3, horizontal: 3),
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
                            child: Text.rich(
                              softWrap: true,
                              TextSpan(
                                children: [
                                  TextSpan(text: S.of(context).customer_tile_lastVisit_1),
                                  if (user.lastVisit != -1)
                                    Utilities().isSameDay(DateTime.now(), lastVisit)
                                        ? TextSpan(text:  S.of(context).customer_tile_lastVisit_2, style: TextStyle(fontWeight: FontWeight.bold))
                                        : TextSpan(text:  S.of(context).customer_tile_lastVisit_3),
                                  if (user.lastVisit != -1 && !Utilities().isSameDay(DateTime.now(), lastVisit))
                                    TextSpan(
                                      text: DateFormat("dd.MM.yyyy").format(lastVisit),
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  if (user.lastVisit == -1) TextSpan(text: S.of(context).customer_tile_lastVisit_4, style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: S.of(context).customer_tile_lastVisit_5),
                                ],
                              ),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    )
                ),
                Expanded(
                  flex: 2 ,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 10),
                        Expanded(
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
                                    backgroundColor: Color.fromRGBO(169, 171, 25, 0.4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)
                                    )
                                ),
                                child: Text(S.of(context).customer_tile_deleteLastEntry, textAlign: TextAlign.center,),
                              )
                            : TextButton(
                                onPressed: () async {
                                  setState(() {
                                    user.updateLastVisit(DateTime.now().millisecondsSinceEpoch);
                                  });
                                  await DatabaseHelper().addVisit(user.id, false);
                                },
                                style: TextButton.styleFrom(
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