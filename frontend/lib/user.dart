class User{
  final int id;
  final String uuId;
  final String firstName;
  final String lastName;
  final int createdOn;
  int lastVisit;
  final int birthDay;
  final String birthCountry;
  final bool hasChild;
  final String? miscellaneous;

  User({
    required this.id,
    required this.uuId,
    required this.firstName,
    required this.lastName,
    required this.createdOn,
    required this.lastVisit,
    required this.birthDay,
    required this.birthCountry,
    required this.hasChild,
    this.miscellaneous,
  });

  void updateLastVisit(int newVisit){
    lastVisit = newVisit;
  }

  User copyWith({
    String? firstName,
    String? lastName,
    int? lastVisit,
    int? birthDay,
    String? birthCountry,
    bool? hasChild,
    String? miscellaneous,
  }) {
    return User(
      id: id ,
      uuId: uuId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdOn: createdOn,
      lastVisit: lastVisit ?? this.lastVisit,
      birthDay: birthDay ?? this.birthDay,
      birthCountry: birthCountry ?? this.birthCountry,
      hasChild: hasChild ?? this.hasChild,
      miscellaneous: miscellaneous ?? this.miscellaneous,
    );
  }

  @override
  String toString() {
    return "$firstName $lastName $lastVisit";
  }
}

class TookItem{
  final int id;
  final int userId;
  final int tookTime;
  final bool wasBedSheet;

  const TookItem(
      this.id,
      this.userId,
      this.tookTime,
      this.wasBedSheet
  );

  static TookItem fromMap(Map map){
    return TookItem(
        map["id"],
        map["userId"],
        map["tookDate"],
        map["wasBedSheet"] == 1 ? true : false
    );
  }
}