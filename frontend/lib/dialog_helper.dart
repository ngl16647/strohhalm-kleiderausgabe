import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'generated/l10n.dart';

///Helper Class for Display of recurring dialogs
class DialogHelper{
  static Future<bool?> dialogConfirmation({
    required BuildContext context,
    required String message,
    required bool hasChoice,
    double? textSize,
    String? acceptString
  })async{
    textSize = textSize ?? 14;
    acceptString = acceptString ?? S.of(context).confirm;

    return await showDialog<bool>(
        context: context,
        builder: (context){
          return AlertDialog(
            content: StyledText(
              textAlign: TextAlign.center,
               text:  message,
              style: TextStyle(fontSize: textSize!),
              tags: {
                "bold": StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
                "bigger": StyledTextTag(style: TextStyle(fontSize: textSize+3)),
              },
            ),
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
                  child: Text(acceptString!))
            ],
          );
        });
  }
}