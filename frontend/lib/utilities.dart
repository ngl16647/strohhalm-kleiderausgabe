import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/user_and_visit.dart';
import 'package:styled_text/styled_text.dart';
import 'package:toastification/toastification.dart';
import 'database_helper.dart';
import 'generated/l10n.dart';
import 'http_helper.dart';


extension DateTimeUtils on DateTime {
  ///Turns a dateTime to the date only (yeah, month, day)
  DateTime get dateOnly => DateTime(year, month, day);

  ///Checks if two Dates(with different times) are the same Day
  bool isSameDay(DateTime? other) {
    if(other == null) return false;
    return dateOnly == other.dateOnly;
  }

  /// Checks if the difference between today and the dayLimit is reached
  bool get isBeyondCutOffNumber {
    final today = DateTime.now().dateOnly;
    final cutOff = AppSettingsManager.instance.settings.cutOffDayNumber ?? 14;
    final diff = today.difference(dateOnly).inDays;
    return diff >= cutOff;
  }
}

///Class for functions needed across the application
class Utilities{
  ///Adds a Visit (now) to a user. Optionally shows a toast
  static Future<Visit?> addVisit({
    required User user,
    required BuildContext context,
    required bool showToast,
  }) async {
    bool? useServer = AppSettingsManager.instance.settings.useServer;
    bool? allowAddingAnyway = AppSettingsManager.instance.settings.allowAdding ?? false;
    if(useServer == null) return null;

    Visit? newLastVisit;
    if(allowAddingAnyway || (user.lastVisit?.isBeyondCutOffNumber ?? true)){
      newLastVisit = useServer
          ? await HttpHelper().addVisit(userId: user.id)
          : await DatabaseHelper().addVisit(user);
      if(newLastVisit != null){
        if(context.mounted && showToast) Utilities.showToast(context: context, title: S.of(context).success, description: S.of(context).stat_page_savedVisit);
      } else {
        if(context.mounted && showToast) Utilities.showToast(context: context, title: S.of(context).fail, description: S.of(context).add_failed, isError: true);
      }
    } else{
      if(context.mounted && showToast) Utilities.showToast(context: context, title: S.of(context).fail, description: S.of(context).customer_tile_lastVisit_onDate(DateFormat("dd.MM.yy HH:mm").format(user.lastVisit!)), isError: true);
    }

    return newLastVisit;
  }

  ///Turns a country-code into a localized String
  static String getLocalizedCountryNameFromCode(BuildContext context, String countryCode) {
    if (countryCode == "WW") {
      return S.of(context).country_Name_worldWideReplacement;
    }

    return CountryLocalizations.of(context)?.countryName(countryCode: countryCode)
        ?? Country.tryParse(countryCode)?.name
        ?? countryCode;
  }

  ///Shows a toast at the top of the screen
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
        description: StyledText(
          text: description,
          style: Theme.of(context).textTheme.bodyMedium,
          tags: {
            "bold": StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
          },
        ),
      );
    }
  }
}