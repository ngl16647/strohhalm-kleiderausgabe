// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user_and_visit.dart';
import 'app_settings.dart';

class HttpHelper {
  static const String defaultPort = "8080";
  static const String defaultScheme = "http";


  bool get useServer => AppSettingsManager.instance.settings.useServer!;
  String get baseUrl => AppSettingsManager.instance.settings.url!;
  String? get key => AppSettingsManager.instance.authToken;

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup("example.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      print("not connected");
    }
    return false;
  }

  Future<bool> isServerOnline() async {
    try {
      final socket = await Socket.connect(baseUrl, int.parse(defaultPort), timeout: Duration(seconds: 5));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<int?> addCustomer({
    required User user
  }) async {
    if(!useServer || baseUrl.isEmpty) return null;
    final uri = buildUri(
      //host: baseUrl,
        path: "/customers",
    );

    final body = jsonEncode({
      "uuid": user.uuId,
      "firstName":  user.firstName,
      "lastName":  user.lastName,
      "birthday":  user.birthDay.toIso8601String(),
      if(user.country.isNotEmpty) "country" : user.country,
      if (user.notes != null) "notes":  user.notes,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $key",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //TODO: Look for Entries where updated_on > lastSync => lastSync = DateTime.now();
        final data = jsonDecode(response.body);
        print("Added Customer $data");
        return data["id"];
        //return User.fromMap(data);
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      connectionProvider.periodicCheckConnection();
      print("Exception: $e");
      return null;
    }
  }

  Future<bool> deleteCustomer({
    required int id,
  }) async {
    if(!useServer || baseUrl.isEmpty) return false;

    final uri = buildUri(
      //host: baseUrl,
      path: "/customers/$id",
    );

    try {
      final response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $key",

        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      connectionProvider.periodicCheckConnection();
      print("Exception: $e");
      return false;
    }
  }

  //TODO: Search pagination
  //Idea: http Request adds LIMIT and OFFSET to search like:
  // LIMIT 50 OFFSET 0 => then loadMore-Button requests LIMIT 50 OFFSET 50 => then loadMore-Button request LIMIT 50 OFFSET 100, etc
  // for full control in frontend return would maybe be good like this:
  //{
  //   "totalFound": 215,
  //   "customers": [
  //     {customer1},
  //     {customer2},
  //     ...
  //   ]
  // }
  // => then add new results to existing userList => if(userList.length == totalFound) hide loadMore-Button TODO: reduce animationtime the longer the list
  Future<List<User>?> searchCustomers({
    String? query,
    DateTime? lastVisitBefore}) async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
        //host: baseUrl,
        path: "/customers",
        queryParams: {
          if(query != null && query.isNotEmpty) "query": query,
          if(lastVisitBefore != null) "last_visit_before" : DateFormat("yyyy-MM-dd").format(lastVisitBefore)
        }
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $key",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Found Customer: $data");
        List<User> userList = [];
        for(var item in data){
          User user = User.fromMap(item);
          userList.add(user);
        }
        return userList;
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      connectionProvider.periodicCheckConnection();
      print("Exception: $e");
      return null;
    }
  }

  Future<User?> getCustomerByUUID(String uuid) async {
    if(!useServer || baseUrl.isEmpty) return null;
    final uri = buildUri(
        //host: baseUrl,
        path: "/customers/uuid/$uuid",
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $key",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if(data == null) return data;
        return User.fromMap(data);
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      connectionProvider.periodicCheckConnection();
      print("Exception: $e");
      return null;
    }
  }

  Future<bool?> updateCustomer(User user) async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
        //host: baseUrl,
        path: "/customers/${user.id}");

    final body = jsonEncode({
      "uuid": user.uuId,
      "firstName": user.firstName,
      "lastName": user.lastName,
      "birthday": user.birthDay.toIso8601String(),
      if(user.country.isNotEmpty) "country" : user.country,
      if (user.notes != null) "notes": user.notes,
    });

    try {
      final response = await http.put(
        uri,
        headers: {
          "Authorization": "Bearer $key",
          "Content-Type": "application/json"
        },
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        //Look for Entries where updated_on > lastSync => lastSync = DateTime.now();
        return true;
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      connectionProvider.periodicCheckConnection();
      print("Exception: $e");
      return null;
    }
  }

  Future<Visit?> addVisit({
    required int userId,
    String? visitTime,
    String? notes,
  }) async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
        //host: baseUrl,
        path: "/customers/$userId/visits"
    );

    //visitTime = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: Random().nextInt(100) + 365)));
    final body = jsonEncode({
      if(visitTime != null) "visitDate" : visitTime,
      if (notes != null) "notes": notes,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $key",
          "Content-Type": "application/json"
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //TODO: Look for Entries where updated_on > lastSync => lastSync = DateTime.now();
        final data = jsonDecode(response.body);
        print("Added Visit $data");
        return Visit.fromMap(data);
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      connectionProvider.periodicCheckConnection();
      print("Exception: $e");
      return null;
    }
  }

  Future<List<Visit>> getALlVisitsFromUser({required int id}) async {
    if(!useServer || baseUrl.isEmpty) return [];

    final uri = buildUri(
      //host: baseUrl,
      path: "/customers/$id/visits",
    );

    final response = await http.get(
        uri,
      headers: {
        "Authorization": "Bearer $key",
      }
    );

    if (response.statusCode == 200) {
      final List<dynamic>? result = jsonDecode(response.body);
      if(result == null) return [];
      return result.map((mapRow) => Visit.fromMap(mapRow)).toList();
    } else {
      print("Error: ${response.statusCode}");
    }
    return [];
  }

  Future<String?> deleteVisit({
    required int customerId,
  }) async {
    if(!useServer || baseUrl.isEmpty) return "-1";

    final uri = buildUri(
      //host: baseUrl,
      path: "/customers/$customerId/visits",
    );

    try {
      final response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $key",
        }
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print(jsonDecode(response.body));
        var result = jsonDecode(response.body);
        return result == null ? null : Visit.fromMap(result).tookTime.toIso8601String();
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return "-1";
      }
    } catch (e) {
      connectionProvider.periodicCheckConnection();
      print("Exception: $e");
      return "-1";
    }
  }

  Future<Map<String, int>?> getAllVisitsInPeriod(int monthsBack, bool year) async {
    final now = DateTime.now();
    final startDate = year
        ? DateTime(now.year - monthsBack, 1, 1)
        : DateTime.utc(now.year, now.month - monthsBack, 1);
    final endDate= year
        ? DateTime(now.year - monthsBack, 13, 1)
        : DateTime.utc(now.year, now.month - monthsBack+1, 1);

    final start = DateFormat("yyyy-MM-dd").format(startDate);
    final end = DateFormat("yyyy-MM-dd").format(endDate);

    List<dynamic> visitsByDate = [];
    Map<String, dynamic>? map = await _fetchVisitsInPeriod(begin: start, end: end);
    if(map != null){
      visitsByDate = map["visitsByDate"] ?? [];
    }

    Map<String, int> dateMap = {};
    DateTime current = startDate;

    //Initialize all keys
    if (!year) {
      while (current.isBefore(endDate)) {
        dateMap[DateFormat("dd.MM.yyyy").format(current)] = 0;
        current = current.add(const Duration(days: 1));
      }
    } else {
      while (current.isBefore(endDate)) {
        dateMap[DateFormat("MM.yyyy").format(current)] = 0;
        current = DateTime(current.year, current.month + 1, 1);
      }
    }

    //Ordne alle Einträge den passenden keys zu NEW
    for (var item in visitsByDate) {
      DateTime date = DateFormat("yyyy-MM-dd").parse(item["date"] as String);
      String dateKey = DateFormat(year ? "MM.yyyy" : "dd.MM.yyyy").format(date);
      dateMap.putIfAbsent(dateKey, () => 0);
      dateMap[dateKey] = (dateMap[dateKey] ?? 0) + 1;
    }

    return map == null ? null : dateMap;
  }

  Future<dynamic> _fetchVisitsInPeriod({String? begin, String? end}) async {
    if(!useServer || baseUrl.isEmpty) return;

    final uri = buildUri(
      //host: baseUrl,
      path: "/stats/visits",
      queryParams: {
        if (begin != null) "begin": begin,
        if (end != null) "end": end,
      },
    );

    try{
      final response = await http.get(
          uri,
        headers: {
          "Authorization": "Bearer $key",
        }
      );

      if (response.statusCode == 200) {
        if(jsonDecode(response.body) == null) return {};
        return(jsonDecode(response.body));
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (ev){
      connectionProvider.periodicCheckConnection();
      print(ev);
      return null;
    }
  }

  Future<Map<String,dynamic>?> getStats() async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
      //host: baseUrl,
      path: "/stats/customers",
    );

    try{
      final response = await http.get(
          uri,
        headers: {
          "Authorization": "Bearer $key",
        }
      );

      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch(ev){
      connectionProvider.periodicCheckConnection();
      return null;
    }
  }



  Future<void> uploadCsv(File csvFile) async {
    // URL des Endpoints
    final uri = Uri.parse('http://example.com/stats/import');

    // Multipart Request erstellen
    var request = http.MultipartRequest('POST', uri);

    // Datei hinzufügen
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Name des Form-Feldes im Backend
        csvFile.path,
      ),
    );

    try {
      // Request senden
      var response = await request.send();

      // Response auslesen
      if (response.statusCode == 200) {
        print('Upload erfolgreich!');
        final respStr = await response.stream.bytesToString();
        print(respStr);
      } else {
        print('Fehler beim Upload: ${response.statusCode}');
        final respStr = await response.stream.bytesToString();
        print(respStr);
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<String?> getCsv() async {
    if(baseUrl.isEmpty) return null;

    print("What?");
    final uri = buildUri(
      //host: baseUrl,
      path: "/stats/export",
    );

    try{
      final response = await http.get(
          uri,
          headers: {
            "Authorization": "Bearer $key",
          }
      );

      if (response.statusCode == 200) {
        print(response.body);

        return response.body;
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch(ev){
      connectionProvider.periodicCheckConnection();
      return null;
    }
  }

  Uri buildUri({
    //required String host,
    required String path,
    Map<String, String>? queryParams,
  }) {
    final parsed = Uri.tryParse(baseUrl); //

    return Uri(
      scheme: parsed?.scheme.isNotEmpty == true ? parsed!.scheme : defaultScheme,
      host: parsed?.host.isNotEmpty == true ? parsed!.host : baseUrl,
      port: parsed?.hasPort == true ? parsed!.port : int.parse(defaultPort),
      path: path,
      queryParameters: queryParams,
    );
  }
}

/*
 Future<dynamic> getNewCustomerAndVisits([String? query]) async {
    // - Get Customer with updated_on after lastSync
    // - Add to local Database
    // - Get Visits with updated_on afet lastSync
    // - Add Visits to local Database
  }
*/

