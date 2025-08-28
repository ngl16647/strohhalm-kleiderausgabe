// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(visitMoreThan14Days) =>
      "${Intl.select(visitMoreThan14Days, {'true': 'Add new visit', 'false': 'Add Visit anyway'})}";

  static String m1(dateString) => "Last visited on <bold>${dateString}</bold>";

  static String m2(isListView) =>
      "${Intl.select(isListView, {'true': 'Show as tiles?', 'false': 'Show as list?'})}";

  static String m3(isDarkMode) =>
      "${Intl.select(isDarkMode, {'true': 'Light Theme', 'false': 'Dark Theme'})}";

  static String m4(cutOffNumber, overAllNumberOfCountries) =>
      "Show top ${cutOffNumber} countries of ${overAllNumberOfCountries}";

  static String m5(showYear) =>
      "${Intl.select(showYear, {'true': 'To month view', 'false': 'To year view'})}";

  static String m6(count) =>
      "${Intl.plural(count, one: 'Visit', other: 'Visits')}";

  static String m7(showYear) =>
      "${Intl.select(showYear, {'true': 'Month', 'false': 'Day'})}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "add_user_birthDay": MessageLookupByLibrary.simpleMessage(
      "Select birth date*",
    ),
    "add_user_deleteMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to permanently delete this person?",
    ),
    "add_user_firstName": MessageLookupByLibrary.simpleMessage("First name*"),
    "add_user_lastName": MessageLookupByLibrary.simpleMessage("Last name*"),
    "add_user_miscellaneous": MessageLookupByLibrary.simpleMessage(
      "Miscellaneous",
    ),
    "add_user_requiredFieldMissing": MessageLookupByLibrary.simpleMessage(
      "One of the required fields is empty",
    ),
    "add_user_requiredFields": MessageLookupByLibrary.simpleMessage(
      "* Required fields",
    ),
    "application_name": MessageLookupByLibrary.simpleMessage(
      "Strohhalm Clothing Distribution",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "barCode_scanner_error": MessageLookupByLibrary.simpleMessage(
      "Please scan a barcode",
    ),
    "barCode_scanner_success": MessageLookupByLibrary.simpleMessage(
      "Barcode scanned successfully",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "customer_tile_addNewEntry": m0,
    "customer_tile_deleteLastEntry": MessageLookupByLibrary.simpleMessage(
      "Delete entry",
    ),
    "customer_tile_lastVisit_never": MessageLookupByLibrary.simpleMessage(
      "Never <bold>visited</bold>",
    ),
    "customer_tile_lastVisit_onDate": m1,
    "customer_tile_lastVisit_today": MessageLookupByLibrary.simpleMessage(
      "Visited <bold>today</bold>",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "language_de": MessageLookupByLibrary.simpleMessage("German"),
    "language_en": MessageLookupByLibrary.simpleMessage("English"),
    "language_ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "main_page_add": MessageLookupByLibrary.simpleMessage("Add"),
    "main_page_emptyUserListText": MessageLookupByLibrary.simpleMessage(
      "Search by name or scan a code to display persons",
    ),
    "main_page_fullScreen": MessageLookupByLibrary.simpleMessage("Fullscreen"),
    "main_page_isListView": m2,
    "main_page_languages": MessageLookupByLibrary.simpleMessage("Languages"),
    "main_page_noUserWithUUID": MessageLookupByLibrary.simpleMessage(
      "No matching person found!",
    ),
    "main_page_scanQrCode": MessageLookupByLibrary.simpleMessage(
      "Scan QR Code",
    ),
    "main_page_searchUsers": MessageLookupByLibrary.simpleMessage(
      "Search persons",
    ),
    "main_page_statistic": MessageLookupByLibrary.simpleMessage("Statistics"),
    "main_page_theme": m3,
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "print": MessageLookupByLibrary.simpleMessage("Print"),
    "qr_code_print": MessageLookupByLibrary.simpleMessage("Print QR Code"),
    "qr_code_share": MessageLookupByLibrary.simpleMessage("Share QR Code"),
    "stat_page_alreadyGotToday": MessageLookupByLibrary.simpleMessage(
      "Already received something today",
    ),
    "stat_page_children": MessageLookupByLibrary.simpleMessage("Has children:"),
    "stat_page_country": MessageLookupByLibrary.simpleMessage(
      "Country of origin:",
    ),
    "stat_page_lastTimeTookClothes": MessageLookupByLibrary.simpleMessage(
      "Last time clothes borrowed:",
    ),
    "stat_page_miscellaneous": MessageLookupByLibrary.simpleMessage(
      "Miscellaneous:",
    ),
    "stat_page_removeLastVisit": MessageLookupByLibrary.simpleMessage(
      "Delete last\nvisit",
    ),
    "stat_page_removeLastVisitConfirmation":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to delete the last visit?",
        ),
    "stat_page_savedVisit": MessageLookupByLibrary.simpleMessage(
      "Visit recorded!",
    ),
    "stat_page_visits": MessageLookupByLibrary.simpleMessage("Total visits:"),
    "statistic_page_numberOfVisits": MessageLookupByLibrary.simpleMessage(
      "Number of visits",
    ),
    "statistic_page_show_top_countries": m4,
    "statistic_page_switchYearDisplay": m5,
    "statistic_page_visits": m6,
    "statistic_page_xAxis": m7,
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
