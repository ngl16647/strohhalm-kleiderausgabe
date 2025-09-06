import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:strohhalm_app/settings.dart';
import 'package:strohhalm_app/user.dart';

class HttpHelper {

  bool get useServer => AppSettingsManager.instance.settings.useServer!;
  String get baseUrl => AppSettingsManager.instance.settings.url!;

  Future<int?> addCustomer({
    required String uuId,
    required String firstName,
    required String lastName,
    required DateTime birthday,
    String? countryCode,
    String? notes,
  }) async {
    if(!useServer || baseUrl.isEmpty) return null;
    String joinedUrl = "$baseUrl/customers";

    final url = Uri.parse(joinedUrl);

    final body = jsonEncode({
      "uuid": uuId,
      "firstName": firstName,
      "lastName": lastName,
      "birthday": birthday.toIso8601String(),
      if(countryCode != null) "country" : countryCode,
      if (notes != null) "notes": notes,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(Duration(seconds: 1)); //TODO: too short?

      if (response.statusCode == 200 || response.statusCode == 201) {
        //TODO: Look for Entries where updated_on > lastSync => lastSync = DateTime.now();
        final data = jsonDecode(response.body);
        print("Added Customer $data");
        return data["id"];
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  Future<dynamic> searchCustomers([String? query]) async {
    if(!useServer || baseUrl.isEmpty) return null;
    final joinedUrl = "$baseUrl/customers";

    final url = query != null && query.isNotEmpty
        ? Uri.parse("$joinedUrl?query=${Uri.encodeComponent(query)}")
        : Uri.parse(joinedUrl);

    try {
      final response = await http.get(url).timeout(Duration(seconds: 1)); //TODO: too short?;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Found Customer: $data");
        return data.map((item) => User.fromMap(item, null)).toList();
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return -1;
      }
    } catch (e) {
      print("Exception: $e");
      return -1;
    }
  }

  Future<dynamic> updateCustomer({
    required int id,
    required String uuid,
    required String firstName,
    required String lastName,
    required DateTime birthday,
    String? countryCode,
    String? notes,
  }) async {
    if(!useServer || baseUrl.isEmpty) return null;
    String joinedUrl = "$baseUrl/customers/$id";

    final url = Uri.parse(joinedUrl);

    final body = jsonEncode({
      "uuid": uuid,
      "firstName": firstName,
      "lastName": lastName,
      "birthday": birthday.toIso8601String(),
      if(countryCode != null) "country" : countryCode,
      if (notes != null) "notes": notes,
    });

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(Duration(seconds: 1)); //TODO: too short?;
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        //TODO: Look for Entries where updated_on > lastSync => lastSync = DateTime.now();
        return response.body;
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  Future<String?> addVisit({
    required int userId,
    String? visitTime,
    String? notes,
  }) async {
    if(!useServer || baseUrl.isEmpty) return null;
    String joinedUrl = "$baseUrl/visits/$userId";

    final url = Uri.parse(joinedUrl);

    final body = jsonEncode({
      if(visitTime != null) "visitDate" : visitTime,
      if (notes != null) "notes": notes,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(Duration(seconds: 1)); //TODO: too short?;

      if (response.statusCode == 200 || response.statusCode == 201) {
        //TODO: Look for Entries where updated_on > lastSync => lastSync = DateTime.now();
        final data = jsonDecode(response.body);
        print("Added Visit $data");
        return data["visit_date"];
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  Future<dynamic> getNewCustomerAndVisits([String? query]) async {
    //TODO:
    // - Get Customer with updated_on after lastSync
    // - Add to local Database
    // - Get Visits with updated_on afet lastSync
    // - Add Visits to local Database
  }
}


/* TODO: Check in backend before inserting
   dynamic data = await searchCustomers("$firstName $lastName");
    if(data is List){
      print("data is List");
      List d = data;
      if(d.isNotEmpty){
        if(d.any((item) => item["birthday"] == birthday)) {
          print("Even birthday is Same");
          return;
        }
      };
    } else if(data is Map){
      print("data is Map");
      Map d = data;
      if(d.isNotEmpty) return;
    } else if(data == null) {
       print("Data was null/empty");
    } else if(data == -1) {
      print("DATA was an Error");
      return;
    } else {
      print("DATA was something else ${data.runtimeType}");
      return;
    }
*/

