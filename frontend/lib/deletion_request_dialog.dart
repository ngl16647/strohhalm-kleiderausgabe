// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/dialog_helper.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/main.dart';
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
  DeleteRequestReturn deletionReturnResult = DeleteRequestReturn([], {});
  bool _useServer = false;
  bool _isMobile = false;

  @override
  void initState() {
    _useServer = AppSettingsManager.instance.settings.useServer ?? false;
    _isMobile = MyApp().getDeviceType() == DeviceType.mobile;
    oldUserList = widget.oldUserList;
    super.initState();
  }

  List<Widget> buildListViewItems(User u, int index){
    return [
      Row(
        children: [
          Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
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
                  "${DateFormat("dd.MM.yyyy").format(u.birthDay)}   ${Utilities.getLocalizedCountryNameFromCode(context, u.country)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 4),
              ],
          ),
        ],
      ),
      if(_isMobile)Spacer(),
      //if(onDeleteList) Text("Will be Deleted!", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.redAccent.shade400.withAlpha(200)),),
      //if(onDeleteList)SizedBox(width: 40,),
      Text(
        "${S.of(context).deletion_request_page_lastVisit} ${DateFormat("dd.MM.yyyy").format(u.lastVisit!)}",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(width: 10,),
      Row(spacing: 10, children: actionButtons(u, index),)
    ];
  }

  List<Widget> actionButtons(User u, int index){
    return [
      Tooltip(
        message: S.of(context).deletion_request_page_resetUser,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.autorenew),
          label: Text(S.of(context).reset),
          onPressed: () async {
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
          label: Text(S.of(context).delete),
          onPressed: () async {
            bool confirmation = await DialogHelper.dialogConfirmation(
                context: context,
                message: S.of(context).add_user_deleteMessage,
                hasChoice: true) ?? false;
            if(confirmation){
              _useServer
                  ? await HttpHelper().deleteCustomer(id: u.id)
                  : await DatabaseHelper().deleteUser(u.id);
              deletionReturnResult.deletedUsersId.add(u.id);
              setState(() {
                oldUserList.removeAt(index);
              });
            }
            //setState(()=> actuallyDeleted.add(u.id));
          },
          icon: Icon(Icons.delete),
        ),
      )
    ];
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
                                child: Scrollbar(
                                  child: ListView.builder(
                                    itemCount: oldUserList.length ,
                                    itemBuilder: (context, index) {
                                      final u = oldUserList[index];
                                      return Container(
                                        margin: EdgeInsets.symmetric(vertical: 6),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(125)),
                                        ),
                                        child: MyApp().getDeviceType() == DeviceType.mobile
                                            ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: buildListViewItems(u, index),
                                              )
                                            : Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: buildListViewItems(u, index),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  ActionChip(
                                      avatar: Icon(Icons.delete_sweep),
                                      label: Text(S.of(context).deletion_request_page_deleteAll),
                                      onPressed: () async {
                                        bool confirmation = await  DialogHelper.dialogConfirmation(
                                            context:context,
                                            message:S.of(context).deletion_request_page_deleteAllDesc,
                                            hasChoice:true) ?? false;
                                        if(confirmation){
                                          if(_useServer){
                                            for(User u in oldUserList){
                                              await HttpHelper().deleteCustomer(id: u.id);
                                              deletionReturnResult.deletedUsersId.add(u.id);
                                            }
                                          } else {
                                            deletionReturnResult.deletedUsersId.addAll(
                                                await DatabaseHelper().deleteUsers(oldUserList.map((u) => u.id).toList())
                                            );
                                          }
                                          setState(() {
                                             oldUserList.clear();
                                          });
                                        }
                                      },
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ],
                          ),
                        )
                  ),
            );
  }
}

/* Different Approach (mark for deletion and then delete when confirming):
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
}*/