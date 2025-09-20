import 'dart:io';
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

class DataBaseExportFunctions{

  static Future<String?> exportToCsv(BuildContext context) async {
    if(!context.mounted) return null;
      final db = await DatabaseHelper().database;
      final users = await db.query("users");

      List<List<dynamic>> csvData = [];

      csvData.add([
        "ID",
        //"uuid",
        "Vorname",
        "Nachname",
        "Geburtstag",
        "Herkunftsland",
        //"lastVisit",
        "Notizen",
        "Anzahl an Besuchen",
        "Besuch"
      ]);

      for (var user in users) {
        final visits = await db.query(
            "visits",
            where: "customerId = ?",
            whereArgs: [user["id"]],
            orderBy: "visitDate ASC"
        );
        final visitDates = visits.map((visitor) =>  DateFormat("yyyy-MM-dd HH:MM").format(DateTime.parse(visitor["visitDate"] as String))).join(", ");
        final visitNumber = visits.length;

        String birthDayConverted = DateFormat("yyyy-MM-dd").format(DateTime.parse(user["birthday"] as String));
        //String lastVisitConverted = DateFormat("yyyy-MM-dd HH:MM").format(DateTime.parse(user["lastVisit"] as String));
        String countryConverted = user["country"] as String;
        if(context.mounted) countryConverted = Utilities.getLocalizedCountryNameFromCode(context, user["country"] as String);

        csvData.add([
          user["id"],
          //user["uuid"],
          user["firstName"],
          user["lastName"],
          birthDayConverted,
          countryConverted,
          //lastVisitConverted,
          "${user["notes"]}",
          visitNumber,
          visitDates,
        ]);
      }

      String csv = const ListToCsvConverter(fieldDelimiter: ",").convert(csvData);
      return csv;
  }

  static Future<void> saveCsv(BuildContext context, bool useServer) async {
      String? csvString;
      if(context.mounted){
        csvString = useServer
            ? await HttpHelper().getCsv()
            : await generateCSVForExportToServer(context); // Would be prettier but could not upload to Server await exportToCsv(context);
      }

      if(csvString == null && context.mounted){
        Utilities.showToast(context: context, title: S.of(context).fail, description: "failed to Convert Country codes");
      }
      final result = await FilePicker.platform.saveFile(
        dialogTitle: "Daten als CSV exportieren",
        fileName: "CSV-Export.csv",
      );

      if (result != null && csvString != null) {
        final file = File(result);
        await file.writeAsString(csvString);
      }
  }

  ///Generate a CSV-String for upload on the Server
  static Future<String?> generateCSVForExportToServer(BuildContext context) async {
    if(!context.mounted) return null;
    final db = await DatabaseHelper().database;
    final users = await db.query("users");

    List<List<dynamic>> csvData = [];

    csvData.add([
      "id",
      //"uuid",
      "Vorname",
      "Nachname",
      "Geburtstag",
      "Land",
      //"lastVisit",
      "Sonstiges",
      "Besuche"
    ]);

    for (var user in users) {
      final visits = await db.query(
          "visits",
          where: "customerId = ?",
          whereArgs: [user["id"]],
          orderBy: "visitDate ASC"
      );
      final visitDates = visits.map((visitor) =>  DateFormat("yyyy-MM-dd").format(DateTime.parse(visitor["visitDate"] as String))).join(",");
      final visitNumber = visits.length;

      String birthDayConverted = DateFormat("yyyy-MM-dd").format(DateTime.parse(user["birthday"] as String));
      String countryConverted = user["country"] as String;
      if(context.mounted) Utilities.getLocalizedCountryNameFromCode(context, user["country"] as String);

      csvData.add([
        user["id"],
        user["firstName"],
        user["lastName"],
        birthDayConverted,
        countryConverted,
        "${user["notes"]}",
        visitNumber,
        visitDates,
      ]);
    }

    String csv = const ListToCsvConverter(fieldDelimiter: ",").convert(csvData);
    return csv;
  }

  static Future<void> importCSVFromServer(BuildContext context) async {
    if(!context.mounted) return;

    String? csvString = await HttpHelper().getCsv();
    if(csvString == null) return;
    List<List<dynamic>> rows = CsvToListConverter(eol: "\n").convert(csvString);

    if (rows.isNotEmpty) {
      rows.removeAt(0);
    }

    for(var row in rows){
      final uuId = const Uuid().v4();
      User userWithoutValidId = User(
          id: -1,
          uuId: uuId,
          firstName: row[1],
          lastName: row[2],
          birthDay: row[3] != null && (row[3] as String).isNotEmpty ? DateTime.parse(row[3]) : DateTime(1970,1,1),
          country: row[4],
          notes: row[5] ?? "",
          lastVisit: null);


      AddUpdateUserReturnType? result = await DatabaseHelper().addUser(
          user: userWithoutValidId
      );
      if(result != null && !result.existed){
        User user = userWithoutValidId.copyWith(newId: result.id);

        List<String> visits = [];
        if (row.length > 6 && row[6].toString().isNotEmpty) {
          visits = row[6].toString().split(",");

          visits.sort((a, b) {
            final dateA = DateTime.parse(a);
            final dateB = DateTime.parse(b);
            return dateA.compareTo(dateB); // älteste zuerst
          });
        }

        //ClearVisits
        var existingVisits = await DatabaseHelper().getVisits(user.id);
        var existingSet = existingVisits.map((item) => item.tookTime.toIso8601String().substring(0, 10)).toSet(); //FUll iso8601 to just yyyy-MM-dd
        for (String v in visits) {

          if(existingSet.contains(v)) continue;
          await DatabaseHelper().addVisit(user, DateTime.parse(v));
        }
      }
    }
  }
}