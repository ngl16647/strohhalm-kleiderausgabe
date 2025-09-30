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

///Class for functions needed across the application
class Utilities{
  static Future<Visit?> addVisit(User user, BuildContext context, bool showToast) async {
    bool? useServer = AppSettingsManager.instance.settings.useServer;
    bool allowAdding = AppSettingsManager.instance.settings.allowAdding ?? false;
    int cutOffNumber = AppSettingsManager.instance.settings.cutOffDayNumber ?? 14;
    if(useServer == null) return null;

    Visit? newLastVisit;
    if(allowAdding || user.lastVisit == null || DateTime.now().difference(user.lastVisit!).inDays > cutOffNumber){
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

  ///Checks if two Dates(with different times) are the same Day
  static bool isSameDay(DateTime? dateTimeOne, DateTime? dateTimeTwo){
    if(dateTimeOne == null || dateTimeTwo == null) return false;
    DateFormat dateFormat = DateFormat("dd.MM.yyyy");
    if(dateFormat.format(dateTimeOne) == dateFormat.format(dateTimeTwo)) return true;
    return false;
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