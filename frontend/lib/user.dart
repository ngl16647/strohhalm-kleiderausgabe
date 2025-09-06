class User{
  final int id;
  final String uuId;
  final String firstName;
  final String lastName;
  //final DateTime createdOn;
  final DateTime birthDay;
  final String birthCountry;
  final bool hasChild;
  final String? miscellaneous;
  List<TookItem> visits;

  User({
    required this.id,
    required this.uuId,
    required this.firstName,
    required this.lastName,
    //required this.createdOn,
    required this.birthDay,
    required this.birthCountry,
    required this.hasChild,
    this.miscellaneous,
    required this.visits
  });

  User copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthDay,
    String? birthCountry,
    bool? hasChild,
    String? miscellaneous,
    List<TookItem>? tookItems,
  }) {
    return User(
      id: id ,
      uuId: uuId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      //createdOn: createdOn,
      birthDay: birthDay ?? this.birthDay,
      birthCountry: birthCountry ?? this.birthCountry,
      hasChild: hasChild ?? this.hasChild,
      miscellaneous: miscellaneous ?? this.miscellaneous,
      visits: tookItems ?? visits,
    );
  }

  factory User.fromMap(Map<String, dynamic> map, List<TookItem>? list){
    return User(
      id: map["id"],
      uuId: map["uuid"],
      firstName: map["firstName"],
      lastName: map["lastName"],
      birthDay: DateTime.parse(map["birthday"]),
      birthCountry: map["country"] ?? "DE",
      miscellaneous: map["notes"] ?? "",
      visits: list ?? [],
      //createdOn: map["createdOn"],
      hasChild: false
    );
  }

  @override
  String toString() {
    return "$id $firstName $lastName $birthCountry $uuId";
  }
}

class TookItem{
  final int id;
  final int userId;
  final DateTime tookTime;
  final bool? wasBedSheet;

  const TookItem({
    required this.id,
    required this.userId,
    required this.tookTime,
    this.wasBedSheet});

  static TookItem fromMap(Map map){
    return TookItem(
        id: map["visitId"] ?? map["id"], //A litte hacky
        userId: map["userId"],
        tookTime: DateTime.parse(map["visitedOn"])
    );
  }
}