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

  static String m0(isAdmin) =>
      "${Intl.select(isAdmin, {'true': 'Admin', 'false': 'Logout', 'other': ' '})}";

  static String m1(countDown) => "Schließt in ${countDown} Sekunden";

  static String m2(visitMoreThan14Days) =>
      "${Intl.select(visitMoreThan14Days, {'true': 'Neuen Besuch vermerken', 'false': 'Trotzdem vermerken', 'other': ' '})}";

  static String m3(dateString) =>
      "War zuletzt am <bold>${dateString}</bold> da";

  static String m4(useServer) =>
      "Löschungsanträge für Besucher, die seit einem Jahr nicht mehr da waren.\nBegrenzt auf ${Intl.select(useServer, {'true': '1.000', 'false': '20.000', 'other': ' '})} Einträge.";

  static String m5(numberOfEntries) =>
      "Es werden jeweils ${numberOfEntries} Einträge angezeigt! Lösche die aktuellen, um die nächsten zu laden";

  static String m6(isLoading) =>
      "${Intl.select(isLoading, {'true': 'Lade...', 'false': 'Mehr laden...', 'other': 'Alles geladen!'})}";

  static String m7(isListView) =>
      "${Intl.select(isListView, {'true': 'Als Kacheln anzeigen?', 'false': 'Als Liste anzeigen?', 'other': ' '})}";

  static String m8(useServer) =>
      "${Intl.select(useServer, {'true': 'Personen durchsuchen (server, mindestens 4 Zeichen)', 'false': 'Personen durchsuchen (lokal)', 'other': ' '})}";

  static String m9(useServer) =>
      "${Intl.select(useServer, {'true': 'Statistiken (server)', 'false': 'Statistiken (lokal)', 'other': ' '})}";

  static String m10(isDarkMode) =>
      "${Intl.select(isDarkMode, {'true': 'Helle Ansicht', 'false': 'Dunkle Ansicht', 'other': ' '})}";

  static String m11(cutOffNumber, overAllNumberOfCountries) =>
      "Zeige die Top ${cutOffNumber} von ${overAllNumberOfCountries} Ländern";

  static String m12(showYear) =>
      "${Intl.select(showYear, {'true': 'zur Monatsansicht', 'false': 'zur Jahresansicht', 'other': ' '})}";

  static String m13(count) =>
      "${Intl.plural(count, one: 'Besuch', other: 'Besuche')}";

  static String m14(visitorCount, visitCount) =>
      "${Intl.plural(visitorCount, one: '${visitorCount} Besucher', other: '${visitorCount} Besucher')}\nmit ${visitCount} ${Intl.plural(visitCount, one: 'Besuch', other: 'Besuche')}";

  static String m15(showYear) =>
      "${Intl.select(showYear, {'true': 'Monat', 'false': 'Tag', 'other': ' '})}";

  static String m16(difference) =>
      "Fehler beim Eintragen\nBesucher war <bold>${Intl.plural(difference, zero: 'Heute', one: 'vor 1 Tag', other: 'vor ${difference} Tagen')}</bold> bereits da";

  static String m17(count) =>
      "${Intl.plural(count, one: 'Besuch', other: 'Besuche')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Akzeptieren"),
    "addUser_dateError": MessageLookupByLibrary.simpleMessage(
      "Bitte gültiges Datum eingeben",
    ),
    "addUser_dateExample": MessageLookupByLibrary.simpleMessage(
      "Bsp-Format: (01.01.1970 oder 1.1.70)",
    ),
    "addUser_nameError": MessageLookupByLibrary.simpleMessage(
      "Bitte Namen eingeben",
    ),
    "addUser_openDatePicker": MessageLookupByLibrary.simpleMessage(
      "Picker öffnen",
    ),
    "addUser_selectCountry": MessageLookupByLibrary.simpleMessage(
      "Herkunftsland auswählen",
    ),
    "add_failed": MessageLookupByLibrary.simpleMessage(
      "Hinzufügen fehlgeschlagen",
    ),
    "add_success": MessageLookupByLibrary.simpleMessage(
      "Hinzufügen erfolgreich",
    ),
    "add_user_birthDay": MessageLookupByLibrary.simpleMessage(
      "Geburtsdatum eintragen*",
    ),
    "add_user_deleteMessage": MessageLookupByLibrary.simpleMessage(
      "Bist du Sicher, dass du diese Person unwiderruflich löschen willst?",
    ),
    "add_user_firstName": MessageLookupByLibrary.simpleMessage(
      "Vorname eintragen*",
    ),
    "add_user_lastName": MessageLookupByLibrary.simpleMessage(
      "Nachname eintragen*",
    ),
    "add_user_miscellaneous": MessageLookupByLibrary.simpleMessage(
      "Sonstige Notizen",
    ),
    "add_user_requiredFieldMissing": MessageLookupByLibrary.simpleMessage(
      "Eines der Pflichtfelder ist leer",
    ),
    "add_user_requiredFields": MessageLookupByLibrary.simpleMessage(
      "* Pflicht Felder",
    ),
    "admin_login": m0,
    "allow_Adding": MessageLookupByLibrary.simpleMessage(
      "Hinzufügen trotz Tagesgrenze erlauben?",
    ),
    "allow_Deleting": MessageLookupByLibrary.simpleMessage("Löschen erlauben?"),
    "application_name": MessageLookupByLibrary.simpleMessage(
      "Strohhalm Kleiderausgabe",
    ),
    "apply": MessageLookupByLibrary.simpleMessage("Anwenden"),
    "back": MessageLookupByLibrary.simpleMessage("Zurück"),
    "banner_designer_bannerDesignerSubTitle":
        MessageLookupByLibrary.simpleMessage("Designer"),
    "banner_designer_bannerDesignerTitle": MessageLookupByLibrary.simpleMessage(
      "Banner Designer",
    ),
    "banner_designer_bannerImageSubTitle": MessageLookupByLibrary.simpleMessage(
      "Bild",
    ),
    "banner_designer_bannerImageTitle": MessageLookupByLibrary.simpleMessage(
      "Banner Bild",
    ),
    "banner_designer_delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "banner_designer_existing": MessageLookupByLibrary.simpleMessage(
      "Vorherige",
    ),
    "banner_designer_new": MessageLookupByLibrary.simpleMessage("Neu"),
    "banner_designer_noImage": MessageLookupByLibrary.simpleMessage(
      "Kein Bild ausgewählt",
    ),
    "banner_designer_pick": MessageLookupByLibrary.simpleMessage("Auswählen"),
    "banner_designer_picked": MessageLookupByLibrary.simpleMessage(
      "Gerade Ausgewählt!",
    ),
    "banner_designer_titleText": MessageLookupByLibrary.simpleMessage(
      "Überschrift",
    ),
    "banner_designer_uploadImage": MessageLookupByLibrary.simpleMessage(
      "Bild hochladen",
    ),
    "banner_designer_wrongAspectRatio": MessageLookupByLibrary.simpleMessage(
      "Das Seitenverhältnis des Bildes ist zu klein!\nSollte mindestens 6:1 sein",
    ),
    "barCode_scanner_error": MessageLookupByLibrary.simpleMessage(
      "Scanne einen BarCode!",
    ),
    "barCode_scanner_success": MessageLookupByLibrary.simpleMessage(
      "Barcode erfolgreich gescannt",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "close": MessageLookupByLibrary.simpleMessage("Schließen"),
    "closesIn": m1,
    "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
    "countryErrorButton": MessageLookupByLibrary.simpleMessage("Liste öffnen"),
    "countryErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Das Land konnte nicht automatisch erkannt werden.\nBitte wähle ein Land aus der nachfolgenden Liste aus.\n\nWenn du keine genaueren Angaben machen möchtest, wähle <bold>Weltweit</bold>.",
    ),
    "country_Name_worldWideReplacement": MessageLookupByLibrary.simpleMessage(
      "Keine Angabe",
    ),
    "country_enter": MessageLookupByLibrary.simpleMessage(
      "Klicken um Herkunftsland auszuwählen",
    ),
    "csv_conversion_failed": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Konvertieren zu CSV",
    ),
    "customer_tile_addNewEntry": m2,
    "customer_tile_deleteLastEntry": MessageLookupByLibrary.simpleMessage(
      "Vermerk löschen",
    ),
    "customer_tile_lastVisit_never": MessageLookupByLibrary.simpleMessage(
      "War <bold>noch nie</bold> da",
    ),
    "customer_tile_lastVisit_onDate": m3,
    "customer_tile_lastVisit_today": MessageLookupByLibrary.simpleMessage(
      "War <bold>heute</bold> da",
    ),
    "dark_mode": MessageLookupByLibrary.simpleMessage("Dunkler Modus"),
    "day_cutoff": MessageLookupByLibrary.simpleMessage(
      "Tage bis zu neuem Besuch (mind. 1)",
    ),
    "days": MessageLookupByLibrary.simpleMessage("Tage"),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deletionRequest_buttonTitle": MessageLookupByLibrary.simpleMessage(
      "Löschungs Anträge",
    ),
    "deletionRequest_restore": MessageLookupByLibrary.simpleMessage(
      "Wiederherstellen",
    ),
    "deletion_failed": MessageLookupByLibrary.simpleMessage(
      "Löschen fehlgeschlagen",
    ),
    "deletion_request_page_delete": MessageLookupByLibrary.simpleMessage(
      "Besucher löschen",
    ),
    "deletion_request_page_deleteAll": MessageLookupByLibrary.simpleMessage(
      "Alle löschen",
    ),
    "deletion_request_page_deleteAllDesc": MessageLookupByLibrary.simpleMessage(
      "Alle inaktiven Besucher auf einmal Löschen?",
    ),
    "deletion_request_page_lastVisit": MessageLookupByLibrary.simpleMessage(
      "Letzter Besuch:",
    ),
    "deletion_request_page_resetUser": MessageLookupByLibrary.simpleMessage(
      "Der letzte Besuch des Besuchers wird auf „Noch Nie“ gesetzt",
    ),
    "deletion_request_page_title": MessageLookupByLibrary.simpleMessage(
      "Inaktive Besucher",
    ),
    "deletion_request_toolTip": m4,
    "deletion_success": MessageLookupByLibrary.simpleMessage(
      "Löschen erfolgreich",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
    "fail": MessageLookupByLibrary.simpleMessage("Fehlschlag"),
    "language_de": MessageLookupByLibrary.simpleMessage("Deutsch"),
    "language_en": MessageLookupByLibrary.simpleMessage("Englisch"),
    "language_ru": MessageLookupByLibrary.simpleMessage("Russisch"),
    "limited_entries_warning": m5,
    "load_more": m6,
    "main_page_add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
    "main_page_emptyUserListText": MessageLookupByLibrary.simpleMessage(
      "Suche nach einem Namen oder Scanne einen Code um Besucher anzuzeigen",
    ),
    "main_page_fullScreen": MessageLookupByLibrary.simpleMessage("Vollbild"),
    "main_page_isListView": m7,
    "main_page_languages": MessageLookupByLibrary.simpleMessage("Sprachen"),
    "main_page_noUserWithUUID": MessageLookupByLibrary.simpleMessage(
      "Es konnte keine passende Person gefunden werden!",
    ),
    "main_page_scanQrCode": MessageLookupByLibrary.simpleMessage(
      "QR-Code scannen",
    ),
    "main_page_searchUsers": m8,
    "main_page_statistic": m9,
    "main_page_theme": m10,
    "no": MessageLookupByLibrary.simpleMessage("Nein"),
    "no_data": MessageLookupByLibrary.simpleMessage("Keine Daten verfügbar"),
    "no_internet": MessageLookupByLibrary.simpleMessage(
      "Keine Verbindung zum Internet",
    ),
    "no_server": MessageLookupByLibrary.simpleMessage(
      "Keine Verbindung zum Server",
    ),
    "no_users_found": MessageLookupByLibrary.simpleMessage(
      "Keine Besucher gefunden",
    ),
    "number_fail": MessageLookupByLibrary.simpleMessage(
      "Keine erlaubte Zahl!\nBitte gib eine korrekte Zahl ein",
    ),
    "offline_Database": MessageLookupByLibrary.simpleMessage(
      "offline Datenbank",
    ),
    "online_Database": MessageLookupByLibrary.simpleMessage("online Datenbank"),
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "password_false": MessageLookupByLibrary.simpleMessage("Falsches Passwort"),
    "pdf_preparing": MessageLookupByLibrary.simpleMessage(
      "Deine PDF wird vorbereitet. Bitte warte einen Moment, sie öffnet sich anschließend automatisch.",
    ),
    "print": MessageLookupByLibrary.simpleMessage("Drucken"),
    "print_height": MessageLookupByLibrary.simpleMessage("Höhe"),
    "print_pdf_tooltip": MessageLookupByLibrary.simpleMessage(
      "Öffnet die aktuell angezeigten Statistiken im Standard-PDF-Viewer.",
    ),
    "print_toolTip": MessageLookupByLibrary.simpleMessage(
      "Passe die Abmessungen an die Größe deines Mediums an (z. B. Kreditkartengröße 91 × 55 mm, Breite eines Labels, etc.),\num Verzerrungen zu vermeiden und den verfügbaren Platz optimal zu nutzen.\nUm die Druckdialog-Einstellungen für zukünftige Druckvorgänge beizubehalten, passe die Druckereinstellungen in deinem Betriebssystem an\n(Beispiel: In Windows „Drucker“ suchen > deinen Drucker auswählen > Druckereinstellungen anpassen)",
    ),
    "print_width": MessageLookupByLibrary.simpleMessage("Breite"),
    "qr_code_print": MessageLookupByLibrary.simpleMessage("QR-Code Drucken"),
    "qr_code_share": MessageLookupByLibrary.simpleMessage(
      "QR-Code Exportieren/Teilen",
    ),
    "reconnected": MessageLookupByLibrary.simpleMessage(
      "Verbindung wieder hergestellt",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
    "same_user_exists": MessageLookupByLibrary.simpleMessage(
      "Benutzer mit gleichen Daten existiert schon!",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "saved": MessageLookupByLibrary.simpleMessage("gespeichert"),
    "server_display_toolTip": MessageLookupByLibrary.simpleMessage(
      "Zeigt ob die lokale oder online-Datenbank verwendet wird",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "settings_banner_desc": MessageLookupByLibrary.simpleMessage(
      "Bild das oben auf der Seite dargestellt wird.\nWird außerdem als Header fürs drucken verwendet",
    ),
    "settings_banner_title": MessageLookupByLibrary.simpleMessage(
      "Banner / Bild",
    ),
    "settings_color_desc": MessageLookupByLibrary.simpleMessage(
      "Akzentfarbe für die Anwendung",
    ),
    "settings_color_title": MessageLookupByLibrary.simpleMessage("Farbe"),
    "settings_controlTitle": MessageLookupByLibrary.simpleMessage(
      "Kontroll-Variablen",
    ),
    "settings_controlToolTip": MessageLookupByLibrary.simpleMessage(
      "Variablen für die steuerung von Tageslimit und der Möglichkeit zu Löschen/Hinzuzufügen",
    ),
    "settings_downloadCSVFromServer": MessageLookupByLibrary.simpleMessage(
      "Downloade CSV-Datei (Excel)",
    ),
    "settings_downloadFromServer": MessageLookupByLibrary.simpleMessage(
      "Vom Server herunterladen",
    ),
    "settings_exportCsvDescription": MessageLookupByLibrary.simpleMessage(
      "Exportiere oder Importiere eine CSV-Datei\nDaten können nur importiert werden, wenn die Zieldatenbank leer ist!",
    ),
    "settings_exportCsvDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Daten als CSV exportieren",
    ),
    "settings_exportCsvFile": MessageLookupByLibrary.simpleMessage(
      "CSV-Import/-Export",
    ),
    "settings_exportCsvFromServer": MessageLookupByLibrary.simpleMessage(
      "CSV vom Server exportieren",
    ),
    "settings_exportCsvLocal": MessageLookupByLibrary.simpleMessage(
      "CSV lokal exportieren",
    ),
    "settings_exportDetailedCsvLocal": MessageLookupByLibrary.simpleMessage(
      "Detaillierte CSV lokal exportieren",
    ),
    "settings_exportLessDetailsToolTip": MessageLookupByLibrary.simpleMessage(
      "Exportiert eine CSV mit:\nid\nVorname\nNachname\nLand als Code\nNotizen\nBesuchen",
    ),
    "settings_exportToolTip": MessageLookupByLibrary.simpleMessage(
      "Exportiert eine CSV mit:\nid\nVorname\nNachname\nLand als ganzer Name\nNotizen\nAnzahl an Besuchen\nBesuche mit Uhrzeit",
    ),
    "settings_importCsv": MessageLookupByLibrary.simpleMessage(
      "Importiere eine CSV-Datei",
    ),
    "settings_importCsvToolTip": MessageLookupByLibrary.simpleMessage(
      "Importiere eine kompatible CSV-Datei",
    ),
    "settings_noConnection": MessageLookupByLibrary.simpleMessage(
      "Keine Verbindung!",
    ),
    "settings_pick_Color": MessageLookupByLibrary.simpleMessage("Farbe wählen"),
    "settings_saveServerSettings": MessageLookupByLibrary.simpleMessage(
      "Server-Einstellungen speichern, um Verbindung zu prüfen",
    ),
    "settings_server_desc": MessageLookupByLibrary.simpleMessage(
      "Falls ein Server verwendet werden soll können hier Url und API-Schlüssel eingegeben werden",
    ),
    "settings_server_switch": MessageLookupByLibrary.simpleMessage(
      "Server verwenden?",
    ),
    "settings_server_title": MessageLookupByLibrary.simpleMessage(
      "Server Einstellungen",
    ),
    "settings_server_tokenHint": MessageLookupByLibrary.simpleMessage(
      "Passwort",
    ),
    "settings_server_urlHint": MessageLookupByLibrary.simpleMessage(
      "Server Url / IP",
    ),
    "settings_switchWarningMessage": MessageLookupByLibrary.simpleMessage(
      "<bigger><bold>Achtung!</bold></bigger>\n\nDie Server-Datenbank und die lokale Datenbank sind getrennt.\nEs ist möglich die Datenbanken als CSV zu exportieren und importieren solange nicht bereits Einträge existieren!\n\n<bigger>Beim Umschalten gehen <bold>keine</bold> Daten verloren.</bigger>\n\nWillst du umschalten?",
    ),
    "settings_themeMode_Title": MessageLookupByLibrary.simpleMessage("Thema"),
    "settings_themeMode_desc": MessageLookupByLibrary.simpleMessage(
      "Heller oder Dunkler Modus",
    ),
    "settings_uploadCsvToServer": MessageLookupByLibrary.simpleMessage(
      "CSV zum Server hochladen",
    ),
    "settings_uploadCsvToServerToolTip": MessageLookupByLibrary.simpleMessage(
      "Importiere eine exportierte CSV-Datei in den Server. Geht nur, wenn die Server-Datenbank leer ist!",
    ),
    "showVisitorDetails": MessageLookupByLibrary.simpleMessage(
      "Besucher Details anzeigen",
    ),
    "stat_page_alreadyGotToday": MessageLookupByLibrary.simpleMessage(
      "Hat heute schon was bekommen",
    ),
    "stat_page_children": MessageLookupByLibrary.simpleMessage("Hat Kinder:"),
    "stat_page_country": MessageLookupByLibrary.simpleMessage("Herkunftsland:"),
    "stat_page_lastTimeTookClothes": MessageLookupByLibrary.simpleMessage(
      "Letzter Besuch am:",
    ),
    "stat_page_miscellaneous": MessageLookupByLibrary.simpleMessage("Notizen:"),
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
    "stat_page_visits": MessageLookupByLibrary.simpleMessage("Besuche:"),
    "statistic_page_noData": MessageLookupByLibrary.simpleMessage(
      "Keine Daten oder Internetverbindung.\nSobald wieder eine Verbindung hergestellt wurde, werden die Daten automatisch geladen!",
    ),
    "statistic_page_numberOfVisits": MessageLookupByLibrary.simpleMessage(
      "Anzahl an Besuchen",
    ),
    "statistic_page_show_top_countries": m11,
    "statistic_page_switchYearDisplay": m12,
    "statistic_page_visits": m13,
    "statistic_page_visitsPerPeriod": MessageLookupByLibrary.simpleMessage(
      "Besuche pro Monat/Jahr",
    ),
    "statistic_page_visitsPerPerson": MessageLookupByLibrary.simpleMessage(
      "Besucher pro Besuch-Anzahl",
    ),
    "statistic_page_visitsPerPerson_Persons":
        MessageLookupByLibrary.simpleMessage("Anzahl von Besuchern"),
    "statistic_page_visitsPerPerson_Visits":
        MessageLookupByLibrary.simpleMessage("Anzahl von Besuchen"),
    "statistic_page_visitsPerVisitor": m14,
    "statistic_page_xAxis": m15,
    "success": MessageLookupByLibrary.simpleMessage("Erfolg"),
    "today": MessageLookupByLibrary.simpleMessage("Heute"),
    "update": MessageLookupByLibrary.simpleMessage("Updaten"),
    "update_failed": MessageLookupByLibrary.simpleMessage(
      "Update fehlgeschlagen",
    ),
    "update_success": MessageLookupByLibrary.simpleMessage(
      "Update erfolgreich",
    ),
    "uuId_fail_keyboard": MessageLookupByLibrary.simpleMessage(
      "uuId-Check Fehlgeschlagen!!\nStelle sicher, dass die Tastatur/System-Sprache (Links-Alt + Links-Umschalt) die gleiche ist, die auch beim Scanner eingestellt ist!",
    ),
    "visit_added_error": m16,
    "visit_added_success": MessageLookupByLibrary.simpleMessage(
      "Besuch erfolgreich eingetragen!",
    ),
    "visit_plural": m17,
    "window_title": MessageLookupByLibrary.simpleMessage("Besucher Check-In"),
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
  };
}
