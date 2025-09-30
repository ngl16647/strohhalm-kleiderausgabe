import 'package:intl/intl.dart';

///Customer-Object
class User{
  final int id;
  final String uuId;
  final String firstName;
  final String lastName;
  final DateTime birthDay;
  final String country;
  String? notes;
  DateTime? lastVisit;

  User({
    required this.id,
    required this.uuId,
    required this.firstName,
    required this.lastName,
    required this.birthDay,
    required this.country,
    this.notes,
    required this.lastVisit,
  });

  ///Copies a Customer with the new specified values
  User copyWith({
    int? newId,
    String? newUuId,
    String? firstName,
    String? lastName,
    DateTime? birthDay,
    String? country,
    bool? hasChild,
    String? notes,
    List<Visit>? tookItems,
    DateTime? lastVisit
  }) {
    return User(
      id: newId ?? id ,
      uuId: newUuId ?? uuId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDay: birthDay ?? this.birthDay,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      lastVisit: lastVisit, //Could cause problems down the line, maybe think of something else to identify if no visits present
    );
  }

  ///turns a Map from the Database into a user
  factory User.fromMap(Map<String, dynamic> map){
    DateTime? tryParseIso(String s){
      try {
        return DateTime.parse(s);
      } catch (_) {}

      try {
        return DateFormat("yyyy-MM-dd").parse(s);
      } catch (_) {}
      return null;
    }

    return User(
      id: map["id"],
      uuId: map["uuid"],
      firstName: map["firstName"],
      lastName: map["lastName"],
      birthDay: DateTime.parse(map["birthday"]),
      country: map["country"] ?? "DE",
      notes: map["notes"] ?? "",
      lastVisit: map["lastVisit"] != null && (map["lastVisit"] as String).isNotEmpty ? tryParseIso(map["lastVisit"]) : null
    );
  }

  bool equals(User user){
    return user.firstName == firstName &&
           user.lastName == lastName &&
           user.birthDay == birthDay &&
           user.country == country &&
           user.notes == notes;
  }

  @override
  String toString() {
    return "User(id: $id, uuId: $uuId, firstName: $firstName, lastName: $lastName, "
         "birthDay: ${birthDay.toIso8601String()}, country: $country,"
         "lastVisit: $lastVisit, notes: $notes)";
  }
}

///Visit-Object
class Visit{
  final int id;
  final int? userId; //gets set to -id if user is deleted
  final DateTime tookTime;

  const Visit({
    required this.id,
    required this.userId,
    required this.tookTime,
  });

  ///Turns a Map from the Database into a Visit-Object
  static Visit fromMap(Map map){
    //A litte hacky
    return Visit(
        id: map["visitId"] ?? map["id"],
        userId: map["customerId"] ?? map["userId"] ?? map["customer_id"],
        tookTime: DateTime.parse(map["visitDate"] ?? map["visit_date"]),
    );
  }

  @override
  String toString() {
    return "$id $userId $tookTime";
  }
}