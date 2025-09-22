import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class Utilities{

  static bool isSameDay(DateTime dateTimeOne, DateTime dateTimeTwo){
    DateFormat dateFormat = DateFormat("dd.MM.yyyy");
    if(dateFormat.format(dateTimeOne) == dateFormat.format(dateTimeTwo)) return true;
    return false;
  }

  static void showToast({
     required BuildContext context,
     required String title,
     required String description,
     bool? isError,
    }){
    if(context.mounted){
      Toastification().show(
        padding: EdgeInsets.all(24),
        context: context,
        type: isError != null && isError ? ToastificationType.error : ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium,),
        description: Text(description, style: Theme.of(context).textTheme.bodyMedium,),
        alignment: Alignment.topCenter,
      );
    }
  }
}