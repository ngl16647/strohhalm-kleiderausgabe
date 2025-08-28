class User{
  final int id;
  final String uuId;
  final String firstName;
  final String lastName;
  final int createdOn;
  final int birthDay;
  final String birthCountry;
  final bool hasChild;
  final String? miscellaneous;
  List<TookItem> tookItems;

  User({
    required this.id,
    required this.uuId,
    required this.firstName,
    required this.lastName,
    required this.createdOn,
    required this.birthDay,
    required this.birthCountry,
    required this.hasChild,
    this.miscellaneous,
    required this.tookItems
  });

  User copyWith({
    String? firstName,
    String? lastName,
    int? birthDay,
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
      createdOn: createdOn,
      birthDay: birthDay ?? this.birthDay,
      birthCountry: birthCountry ?? this.birthCountry,
      hasChild: hasChild ?? this.hasChild,
      miscellaneous: miscellaneous ?? this.miscellaneous,
      tookItems: tookItems ?? this.tookItems,
    );
  }

  @override
  String toString() {
    return "$firstName $lastName $birthCountry $uuId";
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