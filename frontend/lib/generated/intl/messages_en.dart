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

  static String m0(isAdmin) =>
      "${Intl.select(isAdmin, {'true': 'Admin', 'false': 'Logout', 'other': ' '})}";

  static String m1(countDown) => "Closes in ${countDown} seconds";

  static String m2(visitMoreThan14Days) =>
      "${Intl.select(visitMoreThan14Days, {'true': 'Add new visit', 'false': 'Add Visit anyway', 'other': ' '})}";

  static String m3(dateString) => "Last visited on <bold>${dateString}</bold>";

  static String m4(useServer) =>
      "Deletion requests for visitors who haven’t been here for a year.\nLimited to ${Intl.select(useServer, {'true': '1.000', 'false': '20.000', 'other': ' '})} entries.";

  static String m5(numberOfEntries) =>
      "Only ${numberOfEntries} entries are shown at a time! Delete the current ones to see the next set";

  static String m6(isLoading) =>
      "${Intl.select(isLoading, {'true': 'loading...', 'false': 'Load more...', 'other': 'Everything loaded!'})}";

  static String m7(isListView) =>
      "${Intl.select(isListView, {'true': 'Show as tiles?', 'false': 'Show as list?', 'other': ' '})}";

  static String m8(useServer) =>
      "${Intl.select(useServer, {'true': 'Search persons (server)', 'false': 'Search persons (lokal)', 'other': ' '})}";

  static String m9(useServer) =>
      "${Intl.select(useServer, {'true': 'Statistics (server)', 'false': 'Statistics (lokal)', 'other': ' '})}";

  static String m10(isDarkMode) =>
      "${Intl.select(isDarkMode, {'true': 'Light Theme', 'false': 'Dark Theme', 'other': ' '})}";

  static String m11(cutOffNumber, overAllNumberOfCountries) =>
      "Show top ${cutOffNumber} countries of ${overAllNumberOfCountries}";

  static String m12(showYear) =>
      "${Intl.select(showYear, {'true': 'To month view', 'false': 'To year view', 'other': ' '})}";

  static String m13(count) =>
      "${Intl.plural(count, one: 'Visit', other: 'Visits')}";

  static String m14(visitorCount, visitCount) =>
      "${Intl.plural(visitorCount, one: '${visitorCount} Visitor', other: '${visitorCount} Visitors')}\nhave ${visitCount} ${Intl.plural(visitCount, one: 'Visit', other: 'Visits')}";

  static String m15(showYear) =>
      "${Intl.select(showYear, {'true': 'Month', 'false': 'Day', 'other': ' '})}";

  static String m16(difference) =>
      "Error adding visit\nVisitor was already here ${Intl.plural(difference, zero: 'today', one: '1 day', other: '${difference} days')} ago";

  static String m17(count) =>
      "${Intl.plural(count, one: 'Visit', other: 'Visits')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "addUser_dateError": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid date",
    ),
    "addUser_dateExample": MessageLookupByLibrary.simpleMessage(
      "Example format: (01/01/1970 or 1/1/70)",
    ),
    "addUser_nameError": MessageLookupByLibrary.simpleMessage(
      "Please enter a name",
    ),
    "addUser_openDatePicker": MessageLookupByLibrary.simpleMessage(
      "Open picker",
    ),
    "addUser_selectCountry": MessageLookupByLibrary.simpleMessage(
      "Select country of origin",
    ),
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
    "admin_login": m0,
    "allow_Adding": MessageLookupByLibrary.simpleMessage(
      "Allow adding despite day limit?",
    ),
    "allow_Deleting": MessageLookupByLibrary.simpleMessage("Allow deleting?"),
    "application_name": MessageLookupByLibrary.simpleMessage(
      "Strohhalm Clothing Distribution",
    ),
    "apply": MessageLookupByLibrary.simpleMessage("Apply"),
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
    "closesIn": m1,
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "countryErrorButton": MessageLookupByLibrary.simpleMessage("Open List"),
    "countryErrorMessage": MessageLookupByLibrary.simpleMessage(
      "We couldn’t detect your country automatically.\nPlease select a country from the following list.\n\nIf you don’t want to provide details, choose <bold>Worldwide</bold>.",
    ),
    "country_Name_worldWideReplacement": MessageLookupByLibrary.simpleMessage(
      "Not specified",
    ),
    "country_enter": MessageLookupByLibrary.simpleMessage(
      "Click to select country of origin",
    ),
    "csv_conversion_failed": MessageLookupByLibrary.simpleMessage(
      "Failed to convert to CSV",
    ),
    "customer_tile_addNewEntry": m2,
    "customer_tile_deleteLastEntry": MessageLookupByLibrary.simpleMessage(
      "Delete entry",
    ),
    "customer_tile_lastVisit_never": MessageLookupByLibrary.simpleMessage(
      "Never <bold>visited</bold>",
    ),
    "customer_tile_lastVisit_onDate": m3,
    "customer_tile_lastVisit_today": MessageLookupByLibrary.simpleMessage(
      "Visited <bold>today</bold>",
    ),
    "dark_mode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "day_cutoff": MessageLookupByLibrary.simpleMessage("Days until new visit"),
    "days": MessageLookupByLibrary.simpleMessage("Days"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deletionRequest_buttonTitle": MessageLookupByLibrary.simpleMessage(
      "Deletion\nRequests",
    ),
    "deletionRequest_restore": MessageLookupByLibrary.simpleMessage("Restore"),
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
    "deletion_request_toolTip": m4,
    "deletion_success": MessageLookupByLibrary.simpleMessage(
      "Deletion successful",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "fail": MessageLookupByLibrary.simpleMessage("Failure"),
    "language_de": MessageLookupByLibrary.simpleMessage("German"),
    "language_en": MessageLookupByLibrary.simpleMessage("English"),
    "language_ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "limited_entries_warning": m5,
    "load_more": m6,
    "main_page_add": MessageLookupByLibrary.simpleMessage("Add"),
    "main_page_emptyUserListText": MessageLookupByLibrary.simpleMessage(
      "Search by name or scan a code to display persons",
    ),
    "main_page_fullScreen": MessageLookupByLibrary.simpleMessage("Fullscreen"),
    "main_page_isListView": m7,
    "main_page_languages": MessageLookupByLibrary.simpleMessage("Languages"),
    "main_page_noUserWithUUID": MessageLookupByLibrary.simpleMessage(
      "No matching person found!",
    ),
    "main_page_scanQrCode": MessageLookupByLibrary.simpleMessage(
      "Scan QR Code",
    ),
    "main_page_searchUsers": m8,
    "main_page_statistic": m9,
    "main_page_theme": m10,
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "no_data": MessageLookupByLibrary.simpleMessage("No data available"),
    "no_internet": MessageLookupByLibrary.simpleMessage(
      "No Connection to Internet",
    ),
    "no_server": MessageLookupByLibrary.simpleMessage(
      "No Connection to Server",
    ),
    "no_users_found": MessageLookupByLibrary.simpleMessage(
      "Didn\'t find anything",
    ),
    "number_fail": MessageLookupByLibrary.simpleMessage(
      "Invalid number!\nPlease enter a correct number",
    ),
    "offline_Database": MessageLookupByLibrary.simpleMessage(
      "offline Database",
    ),
    "online_Database": MessageLookupByLibrary.simpleMessage("online Database"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "password_false": MessageLookupByLibrary.simpleMessage(
      "Incorrect Password",
    ),
    "pdf_preparing": MessageLookupByLibrary.simpleMessage(
      "Your PDF is being prepared. Please wait a moment; it will open automatically once ready",
    ),
    "print": MessageLookupByLibrary.simpleMessage("Print"),
    "print_height": MessageLookupByLibrary.simpleMessage("Height"),
    "print_pdf_tooltip": MessageLookupByLibrary.simpleMessage(
      "Opens the currently displayed statistics in the default PDF viewer",
    ),
    "print_toolTip": MessageLookupByLibrary.simpleMessage(
      "Adjust the dimensions to match your medium (e.g., credit card size 91 × 55 mm, height of a label, etc.)\nto avoid distortions and make optimal use of the available space.\nTo keep your print dialog settings for future use, adjust your printer settings in your operating system. (Example: In Windows, search for “Printers” > select your printer > adjust the printer settings)",
    ),
    "print_width": MessageLookupByLibrary.simpleMessage("Width"),
    "qr_code_print": MessageLookupByLibrary.simpleMessage("Print QR Code"),
    "qr_code_share": MessageLookupByLibrary.simpleMessage("Share QR Code"),
    "reconnected": MessageLookupByLibrary.simpleMessage("Reconnected!"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "same_user_exists": MessageLookupByLibrary.simpleMessage(
      "User with same Data already existed!",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saved": MessageLookupByLibrary.simpleMessage("saved"),
    "server_display_toolTip": MessageLookupByLibrary.simpleMessage(
      "Shows you if the local or online-Database is used",
    ),
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
    "settings_controlTitle": MessageLookupByLibrary.simpleMessage(
      "Control-Variables",
    ),
    "settings_controlToolTip": MessageLookupByLibrary.simpleMessage(
      "Variables for control of the rules",
    ),
    "settings_downloadCSVFromServer": MessageLookupByLibrary.simpleMessage(
      "Download a CSV file (Excel)",
    ),
    "settings_downloadFromServer": MessageLookupByLibrary.simpleMessage(
      "Download from server",
    ),
    "settings_exportCsvDescription": MessageLookupByLibrary.simpleMessage(
      "Export a CSV file (which can be imported in e.g. Excel)\nIf the database on the server is empty, a CSV file can be uploaded.",
    ),
    "settings_exportCsvDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Export data as CSV",
    ),
    "settings_exportCsvFile": MessageLookupByLibrary.simpleMessage(
      "Export CSV file",
    ),
    "settings_exportCsvFromServer": MessageLookupByLibrary.simpleMessage(
      "Export CSV from server",
    ),
    "settings_exportCsvLocal": MessageLookupByLibrary.simpleMessage(
      "Export CSV locally\n(Server compatible)",
    ),
    "settings_exportDetailedCsvLocal": MessageLookupByLibrary.simpleMessage(
      "Export detailed CSV locally\n(Server incompatible)",
    ),
    "settings_exportLessDetailsToolTip": MessageLookupByLibrary.simpleMessage(
      "Exports a CSV with:\nid\nFirst name\nLast name\nCountry as code\nNotes\nVisits",
    ),
    "settings_exportToolTip": MessageLookupByLibrary.simpleMessage(
      "Exports a CSV with:\nid\nFirst name\nLast name\nCountry as full name\nNotes\nNumber of visits\nVisits with timestamp",
    ),
    "settings_importCsv": MessageLookupByLibrary.simpleMessage(
      "Import a compatible CSV-File",
    ),
    "settings_importCsvToolTip": MessageLookupByLibrary.simpleMessage(
      "Import a compatible CSV-File (CSV with less Details!)",
    ),
    "settings_noConnection": MessageLookupByLibrary.simpleMessage(
      "No connection!",
    ),
    "settings_pick_Color": MessageLookupByLibrary.simpleMessage("Pick color"),
    "settings_saveServerSettings": MessageLookupByLibrary.simpleMessage(
      "Save server settings to check for connection",
    ),
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
    "settings_switchWarningMessage": MessageLookupByLibrary.simpleMessage(
      "<bigger><bold>Warning!</bold></bigger>\n\nThe server database and the local database are separate.\nIt is possible to add the server database to the local one – but <bold>not</bold> the other way around!\n\n<bigger>No data will be lost when switching.</bigger>\n\nDo you want to switch?",
    ),
    "settings_themeMode_Title": MessageLookupByLibrary.simpleMessage("Theme"),
    "settings_themeMode_desc": MessageLookupByLibrary.simpleMessage(
      "Light or Dark mode",
    ),
    "settings_uploadCsvToServer": MessageLookupByLibrary.simpleMessage(
      "Upload CSV to server",
    ),
    "settings_uploadCsvToServerToolTip": MessageLookupByLibrary.simpleMessage(
      "Importiere a exported CSV-File to the Server. Online possible if server-Database is empty!",
    ),
    "showVisitorDetails": MessageLookupByLibrary.simpleMessage(
      "Show Visitor Details",
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
      "No data or internet connection.\nData will automatically load once internet is available!",
    ),
    "statistic_page_numberOfVisits": MessageLookupByLibrary.simpleMessage(
      "Number of visits",
    ),
    "statistic_page_show_top_countries": m11,
    "statistic_page_switchYearDisplay": m12,
    "statistic_page_visits": m13,
    "statistic_page_visitsPerPeriod": MessageLookupByLibrary.simpleMessage(
      "Visits per Month/Year",
    ),
    "statistic_page_visitsPerPerson": MessageLookupByLibrary.simpleMessage(
      "Visitors per Visit-Number",
    ),
    "statistic_page_visitsPerPerson_Persons":
        MessageLookupByLibrary.simpleMessage("Number of Visitors"),
    "statistic_page_visitsPerPerson_Visits":
        MessageLookupByLibrary.simpleMessage("Number of Visits"),
    "statistic_page_visitsPerVisitor": m14,
    "statistic_page_xAxis": m15,
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "update_failed": MessageLookupByLibrary.simpleMessage("Update failed"),
    "update_success": MessageLookupByLibrary.simpleMessage("Update successful"),
    "uuId_fail_keyboard": MessageLookupByLibrary.simpleMessage(
      "Failed UuId Check!\nMake sure your Keyboard-Language (Left-Alt + Left-Shift) is the same as the Barcode-Scanner!",
    ),
    "visit_added_error": m16,
    "visit_added_success": MessageLookupByLibrary.simpleMessage(
      "Visit added successfully!",
    ),
    "visit_plural": m17,
    "window_title": MessageLookupByLibrary.simpleMessage("Visitor Check-In"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
