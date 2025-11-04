import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'app_settings.dart';
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
            contentPadding: EdgeInsets.only(left: 24, top: 20, right: 24, bottom: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: StyledText(
              textAlign: TextAlign.center,
               text:  message,
              style: TextStyle(fontSize: textSize!),
              tags: {
                "bold": StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
                "bigger": StyledTextTag(style: TextStyle(fontSize: textSize+3)),
              },
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              if (hasChoice)
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    S.of(context).cancel,
                    style: TextStyle(fontSize: textSize),
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppSettingsManager.instance.settings.selectedColor!.withAlpha(150),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  acceptString ?? S.of(context).accept,
                  style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
  }
}