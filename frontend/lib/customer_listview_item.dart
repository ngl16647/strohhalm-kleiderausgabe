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
  late User _user;
  bool _mouseIsOver = false;
  DateTime? _lastVisit;

  @override
  void initState() {
    _user = widget.user;
    if(widget.user.visits.isNotEmpty) _lastVisit = _user.visits.first.tookTime;
    super.initState();
  }

  bool get visitMoreThan14Days => _lastVisit != null ? DateTime.now().difference(_lastVisit!).inDays > 13 : true;

  String _buildLastVisitStyledText() {
    if (_lastVisit == null) {
      // Noch nie da gewesen
      return S.of(context).customer_tile_lastVisit_never;
    } else if (Utilities().isSameDay(DateTime.now(), _lastVisit!)) {
      // Heute da gewesen
      return S.of(context).customer_tile_lastVisit_today;
    } else {
      // An einem anderen Tag da gewesen
      final dateString = DateFormat("dd.MM.yyyy").format(_lastVisit!);
      return S.of(context).customer_tile_lastVisit_onDate(dateString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _mouseIsOver ? 1 : 3, horizontal: 3),
      child: InkWell(
        onTap: (){
          //openStatPage(user);
          widget.click();
        },
        onHover: (isHovering){
          setState(() {
            _mouseIsOver = isHovering;
          });
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: Theme.of(context).listTileTheme.tileColor?.withAlpha(255),
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).listTileTheme.tileColor?.withAlpha(220),
          child: Padding(
            padding: EdgeInsets.all(_mouseIsOver ? 4 : 2),
            child: Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10),
                Text(_user.id.toString()),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${_user.firstName} ${_user.lastName}", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            DateFormat("dd.MM.yyyy").format(_user.birthDay),
                              style: TextStyle(color: Theme.of(context).textTheme.headlineSmall!.color?.withAlpha(170))
                          ),
                          SizedBox(width: 10),
                          Text(
                            CountryLocalizations.of(context)?.countryName(countryCode: _user.birthCountry) ?? Country.tryParse(_user.birthCountry)!.name,
                            style: TextStyle(color: Theme.of(context).textTheme.headlineSmall!.color?.withAlpha(170)),
                            overflow: TextOverflow.ellipsis,
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
                              DateTime? newLastTime = await DatabaseHelper().deleteLatestAndReturnPrevious(_user); //Deletes last entry and returns new last as millisecondsSinceEpoch
                              setState(() {
                                _lastVisit = newLastTime;
                                if(widget.user.visits.isNotEmpty) widget.user.visits.removeAt(0);
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
                        //TODO nullcheck?
                        if(!visitMoreThan14Days && !Utilities().isSameDay(DateTime.now(), _lastVisit!)) SizedBox(width: 5,),
                        if(_lastVisit == null || !Utilities().isSameDay(DateTime.now(), _lastVisit!))
                          Expanded(
                          child: TextButton(
                            onPressed: () async {
                              TookItem item = await DatabaseHelper().addVisit(_user.id);
                              widget.user.visits.insert(0, item);
                              setState(() {
                                _lastVisit = item.tookTime;
                              });
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
                            CreateQRCode().printQrCode(context, _user);
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