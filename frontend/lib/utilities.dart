import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                  child: Text("Cancel")),
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Confirm"))
            ],
          );
        });
  }

}