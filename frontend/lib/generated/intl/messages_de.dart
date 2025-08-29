// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(visitMoreThan14Days) =>
      "${Intl.select(visitMoreThan14Days, {'true': 'Neuen Besuch vermerken', 'false': 'Trotzdem vermerken'})}";

  static String m1(dateString) =>
      "War zuletzt am <bold>${dateString}</bold> da";

  static String m2(isListView) =>
      "${Intl.select(isListView, {'true': 'Als Kacheln anzeigen?', 'false': 'Als Liste anzeigen?'})}";

  static String m3(isDarkMode) =>
      "${Intl.select(isDarkMode, {'true': 'Helle Ansicht', 'false': 'Dunkle Ansicht'})}";

  static String m4(cutOffNumber, overAllNumberOfCountries) =>
      "Zeige die Top ${cutOffNumber} Länder von ${overAllNumberOfCountries}";

  static String m5(showYear) =>
      "${Intl.select(showYear, {'true': 'zur Monatsansicht', 'false': 'zur Jahresansicht'})}";

  static String m6(count) =>
      "${Intl.plural(count, one: 'Besuch', other: 'Besuche')}";

  static String m7(showYear) =>
      "${Intl.select(showYear, {'true': 'Monat', 'false': 'Tag'})}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Akzeptieren"),
    "add_user_birthDay": MessageLookupByLibrary.simpleMessage(
      "Geburtsdatum wählen*",
    ),
    "add_user_deleteMessage": MessageLookupByLibrary.simpleMessage(
      "Bist du Sicher, dass du diese Person unwiderruflich löschen willst?",
    ),
    "add_user_firstName": MessageLookupByLibrary.simpleMessage("Vorname*"),
    "add_user_lastName": MessageLookupByLibrary.simpleMessage("Nachname*"),
    "add_user_miscellaneous": MessageLookupByLibrary.simpleMessage("Sonstiges"),
    "add_user_requiredFieldMissing": MessageLookupByLibrary.simpleMessage(
      "Eines der Pflichtfelder ist leer",
    ),
    "add_user_requiredFields": MessageLookupByLibrary.simpleMessage(
      "* Pflicht Felder",
    ),
    "application_name": MessageLookupByLibrary.simpleMessage(
      "Strohhalm Kleiderausgabe",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Zurück"),
    "barCode_scanner_error": MessageLookupByLibrary.simpleMessage(
      "Scanne einen BarCode!",
    ),
    "barCode_scanner_success": MessageLookupByLibrary.simpleMessage(
      "Barcode erfolgreich gescannt",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "close": MessageLookupByLibrary.simpleMessage("Schließen"),
    "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
    "customer_tile_addNewEntry": m0,
    "customer_tile_deleteLastEntry": MessageLookupByLibrary.simpleMessage(
      "Vermerk löschen",
    ),
    "customer_tile_lastVisit_never": MessageLookupByLibrary.simpleMessage(
      "War <bold>noch nie</bold> da",
    ),
    "customer_tile_lastVisit_onDate": m1,
    "customer_tile_lastVisit_today": MessageLookupByLibrary.simpleMessage(
      "War <bold>heute</bold> da",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "language_de": MessageLookupByLibrary.simpleMessage("Deutsch"),
    "language_en": MessageLookupByLibrary.simpleMessage("Englisch"),
    "language_ru": MessageLookupByLibrary.simpleMessage("Russisch"),
    "main_page_add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
    "main_page_emptyUserListText": MessageLookupByLibrary.simpleMessage(
      "Suche nach einem Namen oder Scanne einen Code um Besucher anzuzeigen",
    ),
    "main_page_fullScreen": MessageLookupByLibrary.simpleMessage("Vollbild"),
    "main_page_isListView": m2,
    "main_page_languages": MessageLookupByLibrary.simpleMessage("Sprachen"),
    "main_page_noUserWithUUID": MessageLookupByLibrary.simpleMessage(
      "Es konnte keine passende Person gefunden werden!",
    ),
    "main_page_scanQrCode": MessageLookupByLibrary.simpleMessage(
      "QR-Code scannen",
    ),
    "main_page_searchUsers": MessageLookupByLibrary.simpleMessage(
      "Personen durchsuchen",
    ),
    "main_page_statistic": MessageLookupByLibrary.simpleMessage("Statistiken"),
    "main_page_theme": m3,
    "no": MessageLookupByLibrary.simpleMessage("Nein"),
    "print": MessageLookupByLibrary.simpleMessage("Drucken"),
    "qr_code_print": MessageLookupByLibrary.simpleMessage("QR-Code Drucken"),
    "qr_code_share": MessageLookupByLibrary.simpleMessage("QR-Code Teilen"),
    "stat_page_alreadyGotToday": MessageLookupByLibrary.simpleMessage(
      "Hat heute schon was bekommen",
    ),
    "stat_page_children": MessageLookupByLibrary.simpleMessage("Hat Kinder:"),
    "stat_page_country": MessageLookupByLibrary.simpleMessage("Herkunftsland:"),
    "stat_page_lastTimeTookClothes": MessageLookupByLibrary.simpleMessage(
      "Das letzte mal Kleidung ausgeliehen am:",
    ),
    "stat_page_miscellaneous": MessageLookupByLibrary.simpleMessage(
      "Sonstiges:",
    ),
    "stat_page_removeLastVisit": MessageLookupByLibrary.simpleMessage(
      "Letzten\nBesuch löschen",
    ),
    "stat_page_removeLastVisitConfirmation":
        MessageLookupByLibrary.simpleMessage(
          "Bist du sicher, dass du den letzten Besuch löschen willst?",
        ),
    "stat_page_savedVisit": MessageLookupByLibrary.simpleMessage(
      "Besuch eingetragen!",
    ),
    "stat_page_visits": MessageLookupByLibrary.simpleMessage(
      "Besuche insgesamt:",
    ),
    "statistic_page_numberOfVisits": MessageLookupByLibrary.simpleMessage(
      "Anzahl an Besuchen",
    ),
    "statistic_page_show_top_countries": m4,
    "statistic_page_switchYearDisplay": m5,
    "statistic_page_visits": m6,
    "statistic_page_xAxis": m7,
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
  };
}
