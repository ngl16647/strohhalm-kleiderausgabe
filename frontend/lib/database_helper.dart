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
      join(path, "storhhalm_db_v3.db"),
      onCreate: (db, version) async {

        //TODO: lastVisit entfernen und durch tookItem abfrage ersetzen
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY,
            uuId TEXT UNIQUE,
            firstName TEXT,
            lastName TEXT,
            birthDay INTEGER,
            birthCountry TEXT,
            lastVisit INTEGER,
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
        whereArgs: [userId]
    );
    return maps.map((mapRow) => TookItem.fromMap(mapRow)).toList();
  }

  Future<Map<String, int>> getAllVisitsInLastMonths(int monthsBack) async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - monthsBack, 1).millisecondsSinceEpoch;
    final end = DateTime(now.year, now.month - monthsBack, 31).millisecondsSinceEpoch;

    final maps = await db.query(
      "tookItems",
      where: "tookDate >= ? AND tookDate < ?",
      whereArgs: [start, end],
    );

    Map<String, int> dateMap = {};
    DateTime countTime = DateTime.fromMillisecondsSinceEpoch(start);
    for(int i = 0; i < DateTime.fromMillisecondsSinceEpoch(end).difference(DateTime.fromMillisecondsSinceEpoch(start)).inDays; i++){
      String key = DateFormat("dd.MM.yyyy").format(countTime);
      dateMap.putIfAbsent(key, () => 0);
      countTime = countTime.add(Duration(days: 1));
    }

    List<TookItem> list = maps.map((mapRow) => TookItem.fromMap(mapRow)).toList();

    for (var item in list) {
      String dateKey = DateFormat("dd.MM.yyyy").format(DateTime.fromMillisecondsSinceEpoch(item.tookTime));
      dateMap.putIfAbsent(dateKey, () => 0);
      dateMap[dateKey] = dateMap[dateKey]! + 1;
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



  Future<void> addVisit(int userId, bool wasBedSheet) async {
    final db = await database;

    int createdOn = DateTime.now().millisecondsSinceEpoch;

    await db.update(
        "users",
        {
          "lastVisit": createdOn
        },
        where: "id = ?",
        whereArgs: [userId]);

    await db.insert(
      "tookItems",
      {
        "userId" : userId,
        "tookDate" : createdOn,
        "wasBedSheet" : wasBedSheet ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
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
            "lastVisit": -1,
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
          lastVisit: -1,
          birthDay: birthDay,
          birthCountry: birthCountry,
          hasChild: hasChild,
          miscellaneous: miscellaneous,
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
      User user = mapToUser(map);
      users.add(user);
    }
    return users;
  }

  User mapToUser(Map map){
    return User(
        id: map["id"],
        uuId: map["uuId"],
        firstName: map["firstName"],
        lastName: map["lastName"],
        createdOn: map["createdOn"],
        lastVisit: map["lastVisit"],
        birthDay: map["birthDay"],
        birthCountry: map["birthCountry"] ?? "",
        hasChild: map["hasChild"] == 1 ? true : false,
        miscellaneous: map["miscellaneous"]
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
    return maps.isNotEmpty ? mapToUser(maps.first) : null;
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

  //TODO: lastVisit entfernen
  Future<int?> updateUserLastVisited(User user) async {
    final db = await database;
    int id = user.id;
    int lastVisit = user.lastVisit;

    await db.delete(
      "tookItems",
      where: "userId = ? AND tookDate = ?",
      whereArgs: [id, lastVisit]
    );

    final result = await db.query(
      "tookItems",
      columns: ["tookDate"],
      where: "userId = ?",
      whereArgs: [id],
      orderBy: "tookDate DESC",
      limit: 1,
    );

    int? lastTookDate = -1;
    if (result.isNotEmpty) {
      lastTookDate = result.first["tookDate"] as int?;
    }

    await db.update(
        "users",
        {
          "lastVisit": lastTookDate
        },
        where: "id = ?",
        whereArgs: [id]);

    return lastTookDate;
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