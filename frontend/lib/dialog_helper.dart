import 'package:flutter/material.dart';
import 'generated/l10n.dart';

class DialogHelper{
  static Future<bool?> dialogConfirmation(BuildContext context, String message, bool hasChoice)async{
    return await showDialog<bool>(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Text(message),
            actions: [
              if(hasChoice)TextButton(
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
}