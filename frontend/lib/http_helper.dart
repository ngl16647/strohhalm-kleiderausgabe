
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user_and_visit.dart';
import 'app_settings.dart';

///Helper Class for Http-Requests to the server. On fails starts connectivity-Checks
class HttpHelper {
  static const String defaultPort = "8080";
  static const String defaultScheme = "http";

  bool get useServer => AppSettingsManager.instance.settings.useServer!;
  String get baseUrl => AppSettingsManager.instance.settings.url!;
  String? get key => AppSettingsManager.instance.authToken;

  ///Checks if there is a internet-Connection
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup("example.com").timeout(Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      print("not connected");
    }
    return false;
  }

  ///Checks for a response from server
  Future<bool> isServerOnline() async {
    try {
      final socket = await Socket.connect(baseUrl, int.parse(defaultPort), timeout: Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  ///Adds a customer to the server Database
  Future<int?> addCustomer({
    required User user
  }) async {
    if(!useServer || baseUrl.isEmpty) return null;
    final uri = buildUri(
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
        final data = jsonDecode(response.body);
        print("Added Customer $data");
        return data["id"];
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

  ///Deletes a Customer on the Server
  Future<bool> deleteCustomer({
    required int id,
  }) async {
    if(!useServer || baseUrl.isEmpty) return false;

    final uri = buildUri(
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

  ///Searches the customers on the server and limits results to size, offset by the page*size
  Future<List<User>?> searchCustomers({
    String? query,
    int? page,
    int? size,
    DateTime? lastVisitBefore}) async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
        path: "/customers",
        queryParams: {
          if(query != null && query.isNotEmpty) "query": query,
          if(lastVisitBefore != null) "last_visit_before" : DateFormat("yyyy-MM-dd").format(lastVisitBefore),
          if(page != null) "page": page.toString(),
          if(size != null) "size" : size.toString(),
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
        for(var item in data["data"]){
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

  ///Gets customers by their uuid from the server
  Future<User?> getCustomerByUUID(String uuid) async {
    if(!useServer || baseUrl.isEmpty) return null;
    final uri = buildUri(
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

  ///Updates a customer on the server
  Future<bool?> updateCustomer(User user) async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
        path: "/customers/${user.id}"
    );

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

  ///Adds a visit to a customer, optional with visitTime
  Future<Visit?> addVisit({
    required int userId,
    String? visitTime,
    String? notes,
  }) async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
        path: "/customers/$userId/visits"
    );

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

  ///Gets all visits from a user on the server
  Future<List<Visit>> getALlVisitsFromUser({required int id}) async {
    if(!useServer || baseUrl.isEmpty) return [];

    final uri = buildUri(
      path: "/customers/$id/visits",
    );

    final response = await http.get(
        uri,
      headers: {
        "Authorization": "Bearer $key",
      }
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      final List<dynamic>? result = jsonDecode(response.body)["data"];
      if(result == null) return [];
      print(result);
      return result.map((mapRow) => Visit.fromMap(mapRow)).toList();
    } else {
      print("Error: ${response.statusCode}");
    }
    return [];
  }

  ///Deletes a visit on the server. Sets customerId to null, so cant be distinguished after deletion
  Future<String?> deleteVisit({
    required int customerId,
  }) async {
    if(!useServer || baseUrl.isEmpty) return "-1";

    final uri = buildUri(
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

  ///Turns a request from the server into a usable Map with visits in a specified month/year period
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

    //Match all entries to the existing keys
    for (var item in visitsByDate) {
      DateTime date = DateFormat("yyyy-MM-dd").parse(item["date"] as String);
      String dateKey = DateFormat(year ? "MM.yyyy" : "dd.MM.yyyy").format(date);
      dateMap.putIfAbsent(dateKey, () => 0);
      dateMap[dateKey] = (dateMap[dateKey] ?? 0) + (item["count"] as int);
    }

    return map == null ? null : dateMap;
  }

  ///Gets visits in a specified timeframe from the server
  Future<dynamic> _fetchVisitsInPeriod({String? begin, String? end}) async {
    if(!useServer || baseUrl.isEmpty) return;

    final uri = buildUri(
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
        print("SERVER_RESPONSE:\n${jsonDecode(response.body)}");
        return(jsonDecode(response.body));
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (ev){
      connectionProvider.periodicCheckConnection();
      print("$ev");
      return null;
    }
  }

  ///Gets country-Stats from the Server
  Future<Map<String,dynamic>?> getCountryStats() async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
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

  ///Upload a compatible CSV to the server. Helps syncing offline/online Database
  Future<bool?> uploadCsv(File csvFile) async {
    if(!useServer || baseUrl.isEmpty) return null;

    final uri = buildUri(
      path: "/stats/import",
    );

    var request = http.MultipartRequest(
        'POST',
        uri,
    );

    request.headers.addAll({
      "Authorization": "Bearer $key",
      //"Content-Type": "multipart/form-data",
    });

    // Datei hinzufügen
    request.files.add(
      await http.MultipartFile.fromPath(
        "file", // Name des Form-Feldes im Backend
        csvFile.path,
      ),
    );

    try {

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Upload erfolgreich!");
        final respStr = await response.stream.bytesToString();
        print(respStr);
        return true;
      } else {
        print("Fehler beim Upload: ${response.statusCode}");
        final respStr = await response.stream.bytesToString();
        print(respStr);
        return false;
      }
    } catch (e) {
      print("Exception: $e");
    }
    return null;
  }

  ///Exports the Data from the Server into a CSV-File
  Future<String?> getCsv() async {
    if(baseUrl.isEmpty) return null;

    final uri = buildUri(
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

  ///Checks the saves uri and tries to make it usable no matter the input (e.g. localhost works same as http://localhost:8080/)
  Uri buildUri({
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

