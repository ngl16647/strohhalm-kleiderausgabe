import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/dialog_helper.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/user_and_visit.dart';
import 'package:strohhalm_app/utilities.dart';
import 'database_helper.dart';
import 'generated/l10n.dart';

class DeleteRequestReturn{
  final List<int> resetUsersId;
  final Set<int> deletedUsersId;

  DeleteRequestReturn(
      this.resetUsersId,
      this.deletedUsersId
      );
}

class DeleteDialog extends StatefulWidget{
  final List<User> oldUserList;

  static Future<DeleteRequestReturn?> showDeleteDialog(BuildContext context, List<User> oldUserList) async{
    return await showDialog<DeleteRequestReturn>(
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
  List<int> actuallyDeleted = [];
  DeleteRequestReturn deletionReturnResult = DeleteRequestReturn([], {});
  bool _useServer = false;

  @override
  void initState() {
    _useServer = AppSettingsManager.instance.settings.useServer ?? false;
    oldUserList = widget.oldUserList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      //Set<int> deletedIds = {};
      return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (popped, ev){
                    if(!popped){
                      //To update List when barrier-dismissing Dialog
                      Navigator.of(context).pop(deletionReturnResult);
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
                                    "${S.current.deletion_request_page_title}: ${oldUserList.length}",
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
                                    bool onDeleteList = actuallyDeleted.contains(u.id);
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 6),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: onDeleteList
                                            ? Theme.of(context).colorScheme.surface.withAlpha(120)
                                            : Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(125)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Opacity(
                                              opacity: onDeleteList ? 0.5 : 1.0,
                                              child:Icon(Icons.person, color: Theme.of(context).colorScheme.primary)),
                                          SizedBox(width: 12),
                                          Opacity(
                                                opacity: onDeleteList ? 0.5 : 1.0,
                                                child:Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${u.firstName} ${u.lastName}",
                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "${DateFormat("dd.MM.yyyy").format(u.birthDay)}   ${Utilities.getLocalizedCountryNameFromCode(context, u.country)}",
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                  SizedBox(height: 4),
                                                ],
                                              ),
                                          ),
                                          Spacer(),
                                          if(onDeleteList) Text("Will be Deleted!", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.redAccent.shade400.withAlpha(200)),),
                                          if(onDeleteList)SizedBox(width: 40,),
                                          Opacity(
                                          opacity: onDeleteList ? 0.5 : 1.0,
                                          child:Text(
                                            "${S.of(context).deletion_request_page_lastVisit} ${DateFormat("dd.MM.yyyy").format(u.lastVisit!)}",
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                          ),
                                          SizedBox(width: 10,),
                                          Tooltip(
                                            message: S.of(context).deletion_request_page_resetUser,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.autorenew),
                                              label: Text(onDeleteList ? "" : "Zurücksetzen"),
                                              onPressed: onDeleteList ? null : () async {
                                                _useServer
                                                    ? await HttpHelper().addVisit(userId: u.id, visitTime: DateTime.now().subtract(Duration(days: 14)).toIso8601String())
                                                    : await DatabaseHelper().updateUserLastVisit(u.id, null);
                                                deletionReturnResult.resetUsersId.add(u.id);
                                                setState(() {
                                                  oldUserList.removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                          Tooltip(
                                            message: S.of(context).deletion_request_page_delete,
                                            child: ElevatedButton.icon(
                                              label: Text(onDeleteList ? "Wiederherstellen" : "Löschen"),
                                              onPressed: () async {
                                                if(actuallyDeleted.contains(u.id)){
                                                  setState(()=>actuallyDeleted.remove(u.id));
                                                } else {
                                                  //bool confirmation = await DialogHelper.dialogConfirmation(context, S.of(context).add_user_deleteMessage, true) ?? false;
                                                  //if(confirmation){
                                                  //TODO: Direkt löschen?
                                                  setState(()=> actuallyDeleted.add(u.id));
                                                  //setState(() {
                                                  //  oldUserList.removeAt(index);
                                                  //});
                                                  //}
                                                }
                                              },
                                              icon: Icon(onDeleteList ? Icons.restore : Icons.delete),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Row(
                                children: [
                                  ActionChip(
                                      avatar: Icon(Icons.delete_sweep),
                                      label: Text(S.of(context).deletion_request_page_deleteAll),
                                      onPressed: () async {
                                        //bool confirmation = await  DialogHelper.dialogConfirmation(context, S.of(context).deletion_request_page_deleteAllDesc, true) ?? false;
                                        //if(confirmation){
                                          setState(() {
                                            for(User u in oldUserList){
                                              actuallyDeleted.add(u.id);
                                            }
                                          });
                                        //}
                                      },
                                  ),
                                  Spacer(),
                                  ActionChip(
                                    avatar: Icon(Icons.cancel),
                                    label: Text(S.of(context).cancel),
                                    onPressed: () async {
                                        deletionReturnResult.deletedUsersId.clear();
                                        Navigator.of(context).pop(deletionReturnResult);
                                    },
                                  ),
                                  ActionChip(
                                      avatar: Icon(Icons.download_done),
                                      label: Text(S.of(context).confirm),
                                      onPressed: () async {
                                        if(actuallyDeleted.isEmpty && context.mounted) {
                                          Navigator.of(context).pop(deletionReturnResult);
                                          return;
                                        }
                                        bool confirmation = await  DialogHelper.dialogConfirmation(context, "Bist du sicher, dass du die markierten Besucher löschen willst?", true) ?? false;
                                        if(confirmation){
                                          for(int id in actuallyDeleted){
                                            _useServer
                                                ? await HttpHelper().deleteCustomer(id: id)
                                                : await DatabaseHelper().deleteUser(id);
                                            deletionReturnResult.deletedUsersId.add(id);
                                          }

                                          if(context.mounted)Navigator.of(context).pop(deletionReturnResult);
                                        }
                                      },
                                    )
                                ],
                              ),
                            ],
                          ),
                        )
                  ),
            );
  }
}

/* Differenct Approach:
ListView.builder(
                                  itemCount: oldUserList.length,
                                  itemBuilder: (context, index) {
                                    final u = oldUserList[index];
                                    bool onDeleteList = deletionReturnResult.deletedUsersId.contains(u.id);
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 6),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: onDeleteList
                                            ? Theme.of(context).colorScheme.surface.withAlpha(120)
                                            : Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(125)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Opacity(
                                              opacity: onDeleteList ? 0.5 : 1.0,
                                              child:Icon(Icons.person, color: Theme.of(context).colorScheme.primary)),
                                          SizedBox(width: 12),
                                          Opacity(
                                                opacity: onDeleteList ? 0.5 : 1.0,
                                                child:Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${u.firstName} ${u.lastName}",
                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "${DateFormat("dd.MM.yyyy").format(u.birthDay)}   ${Utilities.getLocalizedCountryNameFromCode(context, u.country)}",
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                  SizedBox(height: 4),
                                                ],
                                              ),
                                          ),
                                          Spacer(),
                                          if(onDeleteList) Text("Will be Deleted!", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.redAccent.shade400.withAlpha(200)),),
                                          if(onDeleteList)SizedBox(width: 40,),
                                          Opacity(
                                          opacity: onDeleteList ? 0.5 : 1.0,
                                          child:Text(
                                            "${S.of(context).deletion_request_page_lastVisit} ${DateFormat("dd.MM.yyyy").format(u.lastVisit!)}",
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                          ),
                                          SizedBox(width: 10,),
                                          Tooltip(
                                            message: S.of(context).deletion_request_page_resetUser,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.autorenew),
                                              label: Text(onDeleteList ? "" : "Zurücksetzen"),
                                              onPressed: onDeleteList ? null : () async {
                                                await DatabaseHelper().updateUserLastVisit(u.id, null);
                                                deletionReturnResult.resetUsersId.add(u.id);
                                                setState(() {
                                                  oldUserList.removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                          Tooltip(
                                            message: S.of(context).deletion_request_page_delete,
                                            child: ElevatedButton.icon(
                                              label: Text(onDeleteList ? "Wiederherstellen" : "Löschen"),
                                              onPressed: () async {
                                                if(deletionReturnResult.deletedUsersId.contains(u.id)){
                                                  setState(()=> deletionReturnResult.deletedUsersId.remove(u.id));
                                                } else {
                                                  //bool confirmation = await DialogHelper.dialogConfirmation(context, S.of(context).add_user_deleteMessage, true) ?? false;
                                                  //if(confirmation){
                                                  //TODO: Direkt löschen?
                                                  setState(()=> deletionReturnResult.deletedUsersId.add(u.id));
                                                  //setState(() {
                                                  //  oldUserList.removeAt(index);
                                                  //});
                                                  //}
                                                }
                                              },
                                              icon: Icon(onDeleteList ? Icons.restore : Icons.delete),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
 */