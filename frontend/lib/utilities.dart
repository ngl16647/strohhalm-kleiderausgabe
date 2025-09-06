import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'generated/l10n.dart';

class Utilities{

  bool isSameDay(DateTime dateTimeOne, DateTime dateTimeTwo){
    DateFormat dateFormat = DateFormat("dd.MM.yyyy");
    if(dateFormat.format(dateTimeOne) == dateFormat.format(dateTimeTwo)) return true;
    return false;
  }

  Future<bool?> dialogConfirmation(BuildContext context, String message)async{
    return await showDialog<bool>(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).cancel)),
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop(true);
                  },
                  child: Text(S.of(context).confirm))
            ],
          );
        });
  }

  void showToast({
     required BuildContext context,
     required String title,
     required String description,
     bool? isError,
    }){
    if(context.mounted){
      Toastification().show(
        padding: EdgeInsets.all(24),
        context: context,
        type: isError != null ? ToastificationType.error : ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium,),
        description: Text(description, style: Theme.of(context).textTheme.bodyMedium,),
        alignment: Alignment.topCenter,
      );
    }
  }
}