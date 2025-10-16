import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:strohhalm_app/database_helper.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/user_and_visit.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:uuid/uuid.dart';
import 'generated/l10n.dart';

///Class for Handling of CSV-Operations
class DataBaseExportFunctions{


  final Map<String, List<String>> aliases = {
    "Vorname": ["Vorname", "vorname", "firstName"],
    "Nachname": ["Nachname", "nachname","lastName"],
    "Geburtsdatum": ["Geburtsdatum", "Geburtstag", "birthday"],
    "Herkunftsland": ["Herkunftsland", "Land", "country"],
    "Notizen": ["Notizen", "Notes", "notes"],
    "Datum": ["Besuche", "Datum", "Besuch", "visits"],
    "UUID": ["uuid","UuId", "uuId", "UUID"]
  };



  ///Save a CSV in a chosen place
  static Future<void> saveCsv({
    required BuildContext context,
    required bool useServer,
    bool? detailedCSV
  }) async {
    String? csvString;
    if(context.mounted){
      csvString = useServer
          ? await HttpHelper().getCsv()
          : detailedCSV != null && detailedCSV ? await exportToCsv(context) : await generateCSVForExportToServer(context); //more details but could not upload to Server;
    }

    if(csvString == null && context.mounted){
      Utilities.showToast(context: context, title: S.of(context).fail, description: S.of(context).csv_conversion_failed);
      return;
    }
    final result = await FilePicker.platform.saveFile(
      dialogTitle: context.mounted ? S.of(context).settings_exportCsvDialogTitle : "Export",
      fileName: "CSV-Export.csv",
    );

    if (result != null && csvString != null) {
      final file = File(result);
      await file.writeAsString(csvString);
    }
  }

  ///Generates a detailed CSV from the local-Database
  static Future<String?> exportToCsv(BuildContext context) async {
    if(!context.mounted) return null;
      final db = await DatabaseHelper().database;
      final users = await db.query("customers");

      List<List<dynamic>> csvData = [];

      csvData.add([
        "id",
        "uuid",
        "Vorname",
        "Nachname",
        "Geburtsdatum",
        "Herkunftsland",
        "Notizen",
        "Anzahl an Besuchen",
        "Datum"
      ]);

      for (var user in users) {
        final visits = await db.query(
            "visits",
            where: "customerId = ?",
            whereArgs: [user["id"]],
            orderBy: "visitDate ASC"
        );
        final visitDates = visits.map((visitor) =>  DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(visitor["visitDate"] as String))).toList();

        final visitNumber = visits.length;

        String birthDayConverted = DateFormat("yyyy-MM-dd").format(DateTime.parse(user["birthday"] as String));
        //String lastVisitConverted = DateFormat("yyyy-MM-dd HH:MM").format(DateTime.parse(user["lastVisit"] as String));
        String countryConverted = user["country"] as String;
        if(context.mounted) countryConverted = Utilities.getLocalizedCountryNameFromCode(context, user["country"] as String);

        var row = [
          user["id"],
          user["uuid"],
          user["firstName"],
          user["lastName"],
          birthDayConverted,
          countryConverted,
          "${user["notes"]}",
          visitNumber,
        ];
        row.addAll(visitDates);

        csvData.add(row);
      }

      String csv = const ListToCsvConverter(fieldDelimiter: ",").convert(csvData);
      return csv;
  }



  ///Generate a less detailed CSV-String for upload on the Server
  static Future<String?> generateCSVForExportToServer(BuildContext context) async {
    if (!context.mounted) return null;
    final db = await DatabaseHelper().database;
    final users = await db.query("customers");

    List<List<dynamic>> csvData = [];

    List<String> headers = [
      "id",
      "Vorname",
      "Nachname",
      "Geburtsdatum",
      "Herkunftsland",
      "Notizen",
      "Datum"
    ];
    csvData.add(headers);

    for (var user in users) {
      String birthDayConverted = DateFormat("yyyy-MM-dd")
          .format(DateTime.parse(user["birthday"] as String));
      String countryConverted = user["country"] as String;
      if (context.mounted) {
        countryConverted = Utilities.getLocalizedCountryNameFromCode(
            context, user["country"] as String);
      }

      List<dynamic> row = [
        user["id"],
        user["firstName"],
        user["lastName"],
        birthDayConverted,
        countryConverted,
        "${user["notes"]}",
      ];

      final visits = await db.query(
        "visits",
        where: "customerId = ?",
        whereArgs: [user["id"]],
        orderBy: "visitDate ASC",
      );
      final visitDates = visits.map((v) => DateFormat("yyyy-MM-dd").format(DateTime.parse(v["visitDate"] as String))).toList();

      row.addAll(visitDates);

      csvData.add(row);
    }

    String csv = ListToCsvConverter(fieldDelimiter: ",").convert(csvData);
    return csv;
  }

  ///Imports a CSV into the local Database
  Future<void> importCSV(BuildContext context, [File? localCSVFile, Function(double progress)? done]) async {
    if(!context.mounted) return;

    String? csvString;
    if(localCSVFile == null){
      csvString = await HttpHelper().getCsv();
      if(csvString == null) return;
    } else {
      csvString = await localCSVFile.readAsString();
      if(csvString.isEmpty) return;
    }
    final firstLine = csvString.split("\n").first;

    final commaCount = ",".allMatches(firstLine).length;
    final semicolonCount = ";".allMatches(firstLine).length;
    final delimiter = commaCount >= semicolonCount ? "," : ";";

    List<List<dynamic>> rows = CsvToListConverter(eol: "\n", fieldDelimiter: delimiter).convert(csvString);

    var header = rows.first.map((e) => e.toString().trim()).toList();
    header = normalizeHeader(header);
    rows.removeAt(0);

    final Map<String, int> colIndex = {};
    for (int i = 0; i < header.length; i++){
        colIndex[header[i]] = i;
    }

    int count = 0;
    int total = rows.length;
    for (var row in rows) {
      count++;

      //if(row[colIndex["Geburtsdatum"]!] != null && row[colIndex["Geburtsdatum"]!].toString().isNotEmpty){
      //  debugPrint(tryParseCountry(row[colIndex["Herkunftsland"]!]));
      //}

      String uuid = colIndex["UUID"] != null && row[colIndex["UUID"]!] != null && row[colIndex["UUID"]!].toString().isNotEmpty
          ? row[colIndex["UUID"]!]
          : const Uuid().v4();

      User userWithoutValidId = User(
        id: -1,
        uuId: uuid,
        firstName: row[colIndex["Vorname"]!] ?? "",
        lastName: row[colIndex["Nachname"]!] ?? "",
        birthDay: row[colIndex["Geburtsdatum"]!] != null && row[colIndex["Geburtsdatum"]!].toString().isNotEmpty
            ? tryParseDate(row[colIndex["Geburtsdatum"]!]) ?? DateTime(1970, 1, 1)
            : DateTime(1970, 1, 1),
        country: row[colIndex["Herkunftsland"]!] != null && row[colIndex["Herkunftsland"]!].toString().isNotEmpty
            ? tryParseCountry(row[colIndex["Herkunftsland"]!])
            : "WW",
        notes: row[colIndex["Notizen"]!] ?? "",
        lastVisit: null,
      );
      AddUpdateUserReturnType? result = await DatabaseHelper().addUser(
          user: userWithoutValidId
      );
      if(result != null){
        int firstDatumIndex = header.indexWhere((colTitle) => colTitle.startsWith("Datum"));
        List<String> visits = [];
        for (int i = firstDatumIndex; i < row.length; i++) {
          if (row[i] != null && row[i].toString().isNotEmpty) {
            visits.add(row[i].toString());
          }
        }

        List<DateTime> dateTimeVisits = visits.map((v) => tryParseDate(v)).where((d) => d != null).map((d) => d!).toList();
        dateTimeVisits.sort((a, b) => a.compareTo(b));

        if(result.existed){
          //Its possible to import even into a full database, new Visits get checked against old
          User user = await DatabaseHelper().getUsers(id: result.id).then((item) => item.first);

          var existingVisits = await DatabaseHelper().getVisits(user.id);
          var existingSet = existingVisits.map((item) => item.tookTime.dateOnly).toSet();
          for (DateTime d in dateTimeVisits) {
            if(existingSet.contains(d.dateOnly)) continue;
              Visit? visit = await DatabaseHelper().addVisit(user, d);
              if (visit != null && (user.lastVisit == null || user.lastVisit!.isBefore(visit.tookTime))) {
                user.lastVisit = visit.tookTime;
              }
          }
        } else {
          //If only importing into empty db
          User user = userWithoutValidId.copyWith(newId: result.id);
          await DatabaseHelper().addVisits(user, dateTimeVisits);
        }
      }
      if(done != null) done((count/total*100));
    }
  }

  ///Matches offline/online headers
  String normalizeHeaderName(String headerName) {
    for (final entry in aliases.entries) {
      if (entry.value.contains(headerName)) {
        return entry.key;
      }
    }
    return headerName;
  }

  List<String> normalizeHeader(List<String> originalHeader) {
    return originalHeader.map(normalizeHeaderName).toList();
  }

  String convertToRight(String csvString) {
    final firstLine = csvString.split("\n").first;

    final commaCount = ",".allMatches(firstLine).length;
    final semicolonCount = ";".allMatches(firstLine).length;
    final delimiter = commaCount >= semicolonCount ? "," : ";";
    List<List<dynamic>> rows = CsvToListConverter(eol: "\n", fieldDelimiter: delimiter).convert(csvString);

    var header = rows.first.map((e) => e.toString().trim()).toList();
    header = normalizeHeader(header);

    final Map<String, int> colIndex = {};
    for (int i = 0; i < header.length; i++){
      colIndex[header[i]] = i;
    }


    rows.removeAt(0);

    int firstDatumIndex = header.indexWhere((colTitle) => colTitle.startsWith("Datum"));
    for(var row in rows){
      if(row[colIndex["Herkunftsland"]!] != null && row[colIndex["Herkunftsland"]!].toString().isNotEmpty){
        row[colIndex["Herkunftsland"]!] = tryParseCountry(row[colIndex["Herkunftsland"]!]);
      }

      if(row[colIndex["Geburtsdatum"]!] != null && row[colIndex["Geburtsdatum"]!].toString().isNotEmpty){
          DateTime? parsedTime = tryParseDate(row[colIndex["Geburtsdatum"]!]);
          if(parsedTime != null) row[colIndex["Geburtsdatum"]!] = DateFormat("yyyy-MM-dd").format(parsedTime);
      }
      else{
        row[colIndex["Geburtsdatum"]!] = "1970-01-01";
      }

      for (int i = firstDatumIndex; i < row.length; i++) {
        if (row[i] != null && row[i].toString().isNotEmpty) {
          DateTime? parsedTime = tryParseDate(row[i]);
          if(parsedTime != null) row[i] = DateFormat("yyyy-MM-dd").format(parsedTime);
        }
      }
    }

    rows.insert(0, header); //reinsert header after manipulating rows

    return ListToCsvConverter().convert(rows);
  }

  ///Tries to parse a country and returns the original String if not successful
  String tryParseCountry(String s){
    if(s == "Keine Angabe" || s == "Not specified"){
      return "WW";
    }
    Country? c =  Country.tryParse(s);
    if(c != null) return c.countryCode;
    return s;
  }

  ///tries to parse date in several formats to increase data-Integrity
  DateTime? tryParseDate(String s) {
    s = s.trim();
    if (s.isEmpty) return null;

    try {
      return DateTime.parse(s);
    } catch (_) {}

    try {
      return DateFormat("dd.MM.yyyy").parse(s);
    } catch (_) {}

    try {
      return DateFormat("yyyy-MM-dd HH:mm").parse(s);
    } catch (_) {}

    return null;
  }

}