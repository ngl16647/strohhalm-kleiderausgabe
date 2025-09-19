import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/dialog_helper.dart';
import 'package:strohhalm_app/user.dart';
import 'database_helper.dart';
import 'generated/l10n.dart';

class DeleteRequestReturn{
  final List<int> resetUsersId;
  final List<int> deletedUsersId;

  DeleteRequestReturn(
      this.resetUsersId,
      this.deletedUsersId
      );
}

class DeleteDialog extends StatefulWidget{
  final List<User> oldUserList;

  static Future<DeleteRequestReturn> showDeleteDialog(BuildContext context, List<User> oldUserList) async{
    return await showDialog(
        context: context,
        builder: (context){
          return DeleteDialog(oldUserList: oldUserList);
        });
  }

  const DeleteDialog({
    super.key,
    required this.oldUserList
  });

  @override
  State<DeleteDialog> createState() => DeleteDialogState();

}

class DeleteDialogState extends State<DeleteDialog>{
  List<User> oldUserList = [];
  DeleteRequestReturn requestReturn = DeleteRequestReturn([],[]);

  @override
  void initState() {
    oldUserList = widget.oldUserList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      List<int> deletedIds = [];
      return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (popped, ev){
                    if(!popped){
                      //To update List when barrier-dismissing Dialog
                      Navigator.of(context).pop(requestReturn);
                    }
                  },
                  child:  Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox.shrink(),
                                  Text(
                                    S.current.deletion_request_page_title,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: Icon(Icons.close),
                                  )
                                ],
                              ),
                              SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: oldUserList.length,
                                  itemBuilder: (context, index) {
                                    final u = oldUserList[index];
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 6),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person, color: Theme.of(context).primaryColor),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${u.firstName} ${u.lastName}",
                                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                "${DateFormat("dd.MM.yyyy").format(u.birthDay)}   ${CountryLocalizations.of(context)?.countryName(countryCode: u.country) ?? Country.tryParse(u.country)!.name}",
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                              SizedBox(height: 4),
                                            ],
                                          ),
                                          Spacer(),
                                          Text(
                                            "${S.of(context).deletion_request_page_lastVisit} ${DateFormat("dd.MM.yyyy").format(u.lastVisit!)}",
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          IconButton(
                                            tooltip: S.of(context).deletion_request_page_resetUser,
                                            onPressed: () async {
                                              await DatabaseHelper().updateUserLastVisit(u.id, null);
                                              requestReturn.resetUsersId.add(u.id);
                                              setState(() {
                                                oldUserList.removeAt(index);
                                              });
                                            },
                                            icon: Icon(Icons.autorenew),
                                          ),
                                          IconButton(
                                            tooltip: S.of(context).deletion_request_page_delete,
                                            onPressed: () async {
                                              bool confirmation = await DialogHelper.dialogConfirmation(context, S.of(context).add_user_deleteMessage, true) ?? false;
                                              if(confirmation){
                                                await DatabaseHelper().deleteUser(u.id);
                                                requestReturn.deletedUsersId.add(u.id);
                                                setState(() {
                                                  oldUserList.removeAt(index);
                                                });
                                              }
                                            },
                                            icon: Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Align(
                                alignment: AlignmentGeometry.bottomRight,
                                child: ActionChip(
                                  avatar: Icon(Icons.delete_sweep),
                                  label: Text(S.of(context).deletion_request_page_deleteAll),
                                  onPressed: () async {
                                    bool confirmation = await  DialogHelper.dialogConfirmation(context, S.of(context).deletion_request_page_deleteAllDesc, true) ?? false;
                                    if(confirmation){
                                      for(User u in oldUserList){
                                        await DatabaseHelper().deleteUser(u.id);
                                        deletedIds.add(u.id);
                                      }
                                      setState(() {
                                        oldUserList.clear();
                                      });
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                  ),
            );
  }
}