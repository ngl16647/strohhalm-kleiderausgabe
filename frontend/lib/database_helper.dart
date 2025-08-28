import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:strohhalm_app/user.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "storhhalm_db_version1.db"),
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY,
            uuId TEXT UNIQUE,
            firstName TEXT,
            lastName TEXT,
            birthDay INTEGER,
            birthCountry TEXT,
            hasChild INTEGER,
            miscellaneous TEXT,  
            createdOn INTEGER
          )
        ''');

        //TODO: Foreign Key entfernen, damit unabängig von Usern (Datenintegrität niedriger)
        await db.execute('''
          CREATE TABLE tookItems(
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            tookDate INTEGER,
            wasBedSheet INTEGER,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> countAllVisits() async{
    final db = await database;
    int result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) as count FROM tookItems")) ?? 0;
    return result;
  }

  Future<Map<String, double>> getBirthCountries() async {
    final db = await database;

    final result = await db.query(
      "users",
      columns: ["birthCountry as country", "COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users) AS percentage"],
      where: "birthCountry IS NOT NULL AND birthCountry != ''",
      groupBy: "birthCountry",
    );

    final Map<String, double> countryCounts = {};
    for (Map row in result) {
      countryCounts[row["country"] as String] = (row["percentage"] as double?) ?? 0;
    }
    return countryCounts;
  }

  Future<List<TookItem>> getVisits(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
        "tookItems",
        where: "userId = ?",
        whereArgs: [userId],
        orderBy: "tookDate DESC",
    );
    return maps.map((mapRow) => TookItem.fromMap(mapRow)).toList();
  }
  int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }


  Future<Map<String, int>> getAllVisitsInPeriod(int monthsBack, bool year) async {
    final db = await database;
    final now = DateTime.now();
    final startDate = year
        ? DateTime(now.year - monthsBack, 1, 1)
        : DateTime.utc(now.year, now.month - monthsBack, 1);
    final endDate= year
        ? DateTime(now.year - monthsBack, 13, 1)
        : DateTime.utc(now.year, now.month - monthsBack+1, 1);

    final start = startDate.millisecondsSinceEpoch;
    final end = endDate.millisecondsSinceEpoch;

    final maps = await db.query(
      "tookItems",
      where: "tookDate >= ? AND tookDate < ?",
      whereArgs: [start, end],
    );

    Map<String, int> dateMap = {};
    DateTime current = startDate;

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

    List<TookItem> list = maps.map((mapRow) => TookItem.fromMap(mapRow)).toList();

    for (var item in list) {
      String dateKey = DateFormat(year ? "MM.yyyy" : "dd.MM.yyyy").format(DateTime.fromMillisecondsSinceEpoch(item.tookTime));
      dateMap.putIfAbsent(dateKey, () => 0);
      dateMap[dateKey] = (dateMap[dateKey] ?? 0) + 1;
    }
    //dateMap.forEach((entryString, entryInt) => print("$entryString | $entryInt"));
    return dateMap;
  }

  Future<List<TookItem>> getAllVisitsInLastWeeks(int weeksBack) async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
    final end = DateTime(now.year, now.month + 1, 1).millisecondsSinceEpoch; // aktueller Monat Ende

    final maps = await db.query(
      "tookItems",
      where: "tookDate >= ? AND tookDate < ?",
      whereArgs: [start, end],
    );

    return maps.map((mapRow) => TookItem.fromMap(mapRow)).toList();
  }



  Future<TookItem> addVisit(int userId, bool wasBedSheet) async {
    final db = await database;

    int createdOn = DateTime.now().millisecondsSinceEpoch;
    int itemId = await db.insert(
      "tookItems",
      {
        "userId" : userId,
        "tookDate" : createdOn,
        "wasBedSheet" : wasBedSheet ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return TookItem(itemId, userId, createdOn, wasBedSheet);
  }

  Future<User> addUser(String firstName, String lastName, int birthDay, String birthCountry, bool hasChild, String miscellaneous) async {
    final db = await database;
    final createdOn = DateTime.now().millisecondsSinceEpoch;

    while (true) {
      final uuId = const Uuid().v4();
      try {
        final id = await db.insert(
          "users",
          {
            "uuId": uuId,
            "firstName": firstName,
            "lastName": lastName,
            "createdOn": createdOn,
            "hasChild": hasChild ? 1 : 0,
            "birthDay": birthDay,
            "birthCountry": birthCountry,
            "miscellaneous": miscellaneous,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );

        return User(
          id: id,
          uuId: uuId,
          firstName: firstName,
          lastName: lastName,
          createdOn: createdOn,
          birthDay: birthDay,
          birthCountry: birthCountry,
          hasChild: hasChild,
          miscellaneous: miscellaneous,
          tookItems: []
        );
      } catch (e) {
        if (e is DatabaseException && e.isUniqueConstraintError()) {
          if (kDebugMode) {
            print(e);
          }
          continue;
        }
        rethrow;
      }
    }
  }

  Future<List<User>> getUsers(String search) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
        "users",
      where: "LOWER(firstName || ' ' || lastName) LIKE ?",
      whereArgs: ["%${search.toLowerCase()}%"],
    );
    List<User> users = [];
    for(Map map in maps){
      List<TookItem> list = await getVisits(map["id"] as int);
      User user = mapToUser(map, list);
      users.add(user);
    }
    return users;
  }

  User mapToUser(Map map, List<TookItem> list){
    return User(
        id: map["id"],
        uuId: map["uuId"],
        firstName: map["firstName"],
        lastName: map["lastName"],
        createdOn: map["createdOn"],
        birthDay: map["birthDay"],
        birthCountry: map["birthCountry"] ?? "",
        hasChild: map["hasChild"] == 1 ? true : false,
        miscellaneous: map["miscellaneous"],
        tookItems: list
    );
  }

  Future<User?> getUserByUuid(String uuId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      "users",
      where: "uuId = ?",
      whereArgs: [uuId],
      limit: 1
    );
    return maps.isNotEmpty ? mapToUser(maps.first, await getVisits(maps.first["id"] as int)) : null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;

      await db.update(
          "users",
          {
            "firstName" : user.firstName,
            "lastName" : user.lastName,
            "hasChild": user.hasChild ? 1 : 0,
            "birthDay": user.birthDay,
            "birthCountry": user.birthCountry,
            "miscellaneous": user.miscellaneous,
          },
          where: "id = ?",
          whereArgs: [user.id]);
  }

  Future<int> getLastVisit(int userId) async { //Obsolet
    final db = await database;

    final result = await db.query(
      "tookItems",
      columns: ["tookDate"],
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "tookDate DESC",
      limit: 1,
    );

    int lastVisit = -1;
    if(result.isNotEmpty) lastVisit = result.first["tookDate"] as int;

    return lastVisit;
  }

  Future<int?> deleteLatestAndReturnPrevious(User user) async { //TODO: maybe return tookItem
    final db = await database;
    int id = user.id;

    final result = await db.query(
      "tookItems",
      columns: ["tookDate"],
      where: "userId = ?",
      whereArgs: [id],
      orderBy: "tookDate DESC",
      limit: 2,
    );

    //result[0] is newest, is deleted, result[1] is the one before gets returned as new latest
    if (result.isEmpty) { //should never be the case since if empty there is no possibility to delete
      return -1;
    }

    await db.delete(
      "tookItems",
      where: "userId = ? AND tookDate = ?",
      whereArgs: [id, result.first["tookDate"] as int],
    );

    if (result.length > 1) {
      return result.last["tookDate"] as int;
    } else {
      return -1; //if there is no second entry visits for user is empty
    }
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete (
        "users",
      where: "id = ?",
      whereArgs: [id]
    );

    //TODO: Entfernen
    await db.delete(
        "tookItems",
        where: "userId = ?",
        whereArgs: [id]
    );
  }
}