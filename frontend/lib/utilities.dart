import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:toastification/toastification.dart';

class Utilities{

  static bool isSameDay(DateTime dateTimeOne, DateTime dateTimeTwo){
    DateFormat dateFormat = DateFormat("dd.MM.yyyy");
    if(dateFormat.format(dateTimeOne) == dateFormat.format(dateTimeTwo)) return true;
    return false;
  }

  static String getLocalizedCountryNameFromCode(BuildContext context, String countryCode){
    if(countryCode == "WW") return "keine Angabe";
    return CountryLocalizations.of(context)?.countryName(countryCode: countryCode) ?? Country.tryParse(countryCode)!.name;
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
        autoCloseDuration: Duration(seconds: 4),
        alignment: Alignment.topCenter,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        borderSide: BorderSide(color: AppSettingsManager.instance.settings.selectedColor ?? Theme.of(context).listTileTheme.tileColor!),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        description: Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),

      );
    }
  }
}