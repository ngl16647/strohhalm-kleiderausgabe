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

  static String m7(visitorCount, visitCount) =>
      "${Intl.plural(visitorCount, one: '# Visitor', other: '# Visitors')}\nhave ${visitCount} ${Intl.plural(visitCount, one: 'Visit', other: 'Visits')}";

  static String m8(showYear) =>
      "${Intl.select(showYear, {'true': 'Month', 'false': 'Day'})}";

  static String m9(count) =>
      "${Intl.plural(count, one: 'Visit', other: 'Visits')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "add_failed": MessageLookupByLibrary.simpleMessage("Adding failed"),
    "add_success": MessageLookupByLibrary.simpleMessage("Adding successful"),
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
    "banner_designer_bannerDesignerSubTitle":
        MessageLookupByLibrary.simpleMessage("Designer"),
    "banner_designer_bannerDesignerTitle": MessageLookupByLibrary.simpleMessage(
      "Banner Designer",
    ),
    "banner_designer_bannerImageSubTitle": MessageLookupByLibrary.simpleMessage(
      "Image",
    ),
    "banner_designer_bannerImageTitle": MessageLookupByLibrary.simpleMessage(
      "Banner Image",
    ),
    "banner_designer_delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "banner_designer_existing": MessageLookupByLibrary.simpleMessage(
      "Existing",
    ),
    "banner_designer_new": MessageLookupByLibrary.simpleMessage("New"),
    "banner_designer_noImage": MessageLookupByLibrary.simpleMessage(
      "No image selected",
    ),
    "banner_designer_pick": MessageLookupByLibrary.simpleMessage("Select"),
    "banner_designer_picked": MessageLookupByLibrary.simpleMessage(
      "Just selected!",
    ),
    "banner_designer_titleText": MessageLookupByLibrary.simpleMessage("Title"),
    "banner_designer_uploadImage": MessageLookupByLibrary.simpleMessage(
      "Upload image",
    ),
    "banner_designer_wrongAspectRatio": MessageLookupByLibrary.simpleMessage(
      "The image\'s aspect ratio is too small!\nIt should be at least 6:1",
    ),
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
    "deletion_failed": MessageLookupByLibrary.simpleMessage("Deletion failed"),
    "deletion_request_page_delete": MessageLookupByLibrary.simpleMessage(
      "delete Visitor",
    ),
    "deletion_request_page_deleteAll": MessageLookupByLibrary.simpleMessage(
      "Delete All",
    ),
    "deletion_request_page_deleteAllDesc": MessageLookupByLibrary.simpleMessage(
      "Delete All old Customers at once",
    ),
    "deletion_request_page_lastVisit": MessageLookupByLibrary.simpleMessage(
      "Last Visit:",
    ),
    "deletion_request_page_resetUser": MessageLookupByLibrary.simpleMessage(
      "reset Visitor",
    ),
    "deletion_request_page_title": MessageLookupByLibrary.simpleMessage(
      "inactive Visitors",
    ),
    "deletion_success": MessageLookupByLibrary.simpleMessage(
      "Deletion successful",
    ),
    "fail": MessageLookupByLibrary.simpleMessage("Failure"),
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
    "no_internet": MessageLookupByLibrary.simpleMessage(
      "Keine Verbindung zum Internet",
    ),
    "no_server": MessageLookupByLibrary.simpleMessage(
      "Keine Verbindung zum Server",
    ),
    "number_fail": MessageLookupByLibrary.simpleMessage(
      "Invalid number!\nPlease enter a correct number",
    ),
    "print": MessageLookupByLibrary.simpleMessage("Print"),
    "qr_code_print": MessageLookupByLibrary.simpleMessage("Print QR Code"),
    "qr_code_share": MessageLookupByLibrary.simpleMessage("Share QR Code"),
    "reconnected": MessageLookupByLibrary.simpleMessage(
      "Verbindung wieder hergestellt!",
    ),
    "same_user_exists": MessageLookupByLibrary.simpleMessage(
      "User with same Data already existed!",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settings_banner_desc": MessageLookupByLibrary.simpleMessage(
      "Image displayed at the top of the page.\\nAlso used as header for printing",
    ),
    "settings_banner_title": MessageLookupByLibrary.simpleMessage(
      "Banner / Image",
    ),
    "settings_color_desc": MessageLookupByLibrary.simpleMessage(
      "Accent color for the application",
    ),
    "settings_color_title": MessageLookupByLibrary.simpleMessage("Color"),
    "settings_pick_Color": MessageLookupByLibrary.simpleMessage("Pick color"),
    "settings_server_desc": MessageLookupByLibrary.simpleMessage(
      "If a server is to be used, URL and password can be entered here",
    ),
    "settings_server_switch": MessageLookupByLibrary.simpleMessage(
      "Use server?",
    ),
    "settings_server_title": MessageLookupByLibrary.simpleMessage(
      "Server Settings",
    ),
    "settings_server_tokenHint": MessageLookupByLibrary.simpleMessage(
      "Password",
    ),
    "settings_server_urlHint": MessageLookupByLibrary.simpleMessage(
      "Server URL / IP",
    ),
    "settings_themeMode_Title": MessageLookupByLibrary.simpleMessage("Theme"),
    "settings_themeMode_desc": MessageLookupByLibrary.simpleMessage(
      "Light or Dark mode",
    ),
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
    "stat_page_visits": MessageLookupByLibrary.simpleMessage("Visits:"),
    "statistic_page_noData": MessageLookupByLibrary.simpleMessage(
      "Keine Daten oder Internetverbindung.\nSobald wieder Internet verfügbar ist werden die Daten automatisch geladen!",
    ),
    "statistic_page_numberOfVisits": MessageLookupByLibrary.simpleMessage(
      "Number of visits",
    ),
    "statistic_page_show_top_countries": m4,
    "statistic_page_switchYearDisplay": m5,
    "statistic_page_visitDesc": MessageLookupByLibrary.simpleMessage(
      "Besucher\nhaben",
    ),
    "statistic_page_visits": m6,
    "statistic_page_visitsPerPerson": MessageLookupByLibrary.simpleMessage(
      "Besucher pro Besuch-Anzahl",
    ),
    "statistic_page_visitsPerPerson_Persons":
        MessageLookupByLibrary.simpleMessage("Anzahl von Besuchern"),
    "statistic_page_visitsPerPerson_Visits":
        MessageLookupByLibrary.simpleMessage("Anzahl von Besuchern"),
    "statistic_page_visitsPerVisitor": m7,
    "statistic_page_xAxis": m8,
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "update_failed": MessageLookupByLibrary.simpleMessage("Update failed"),
    "update_success": MessageLookupByLibrary.simpleMessage("Update successful"),
    "uuId_fail_keyboard": MessageLookupByLibrary.simpleMessage(
      "Failed UuId Check!\nMake sure your Keyboard-Language (Left-Alt + Left-Shift) is the same as the Barcode-Scanner!",
    ),
    "visit_plural": m9,
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
