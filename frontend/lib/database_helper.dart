import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/user.dart';

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
      join(path, "storhhalm_db_version5.db"),
      onCreate: (db, version) async {

        //Date as Iso8610String
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY,
            uuid TEXT UNIQUE,
            firstName TEXT,
            lastName TEXT,
            birthday TEXT,
            country TEXT,
            updated_on TEXT,
            notes TEXT,  
            createdOn TEXT
          )
        ''');

        //TODO: Foreign Key entfernen, damit unabängig von Usern (Datenintegrität niedriger und cascading delete muss manuell passieren)
        await db.execute('''
          CREATE TABLE visits(
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            visitedOn TEXT,
            updated_on TEXT,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');

        /* New Structure
        await db.execute('''
          CREATE TABLE users(
            id String PRIMARY KEY,
            firstName TEXT,
            lastName TEXT,
            birthday TEXT,
            country TEXT,
            miscellaneous TEXT,
            createdOn TEXT,
            updatedOn TEXT,
            deletedOn TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE visits(
            userId TEXT,
            visitDate TEXT,
            notes TEXT,
            PRIMARY KEY (userId, visitDate) //this or just id INTEGER PRIMARY KEY which gets never used?
          )
        ''');*/
      },
      version: 1,
    );
  }

  Future<void> syncWithDatabase()async{
    //TODO:
    // - check field updated_at of customer and visited_on from Visits on Server
    // - request Customers and visits with date > lastTimeFiredFunction
    // - Add Data to local database (if id exists update, else add)

    // - get all uuid in deleted_table
    // - iterate trough result and delete all entries with uuid
  }

  //TODO: Can stay offline
  Future<Map<String, dynamic>> getBirthCountries() async {
    final db = await database;

    final result = await db.query(
      "users",
      columns: ["country as country", "COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users) AS percentage, COUNT(*) AS number"],
      where: "country IS NOT NULL AND country != ''",
      groupBy: "country",
    );

    final Map<String, dynamic> countryCounts = {};
    for (Map row in result) {
      countryCounts[row["country"] as String] = [(row["percentage"] as double?), row["number"] as int?];
    }
    return countryCounts;
  }


  //TODO: Can sty offline
  Future<Map<String, int>> getAllVisitsInPeriod(int monthsBack, bool year) async {
    final db = await database;
    final now = DateTime.now();
    final startDate = year
        ? DateTime(now.year - monthsBack, 1, 1)
        : DateTime.utc(now.year, now.month - monthsBack, 1);
    final endDate= year
        ? DateTime(now.year - monthsBack, 13, 1)
        : DateTime.utc(now.year, now.month - monthsBack+1, 1);

    final start = startDate.toIso8601String();
    final end = endDate.toIso8601String();

    final maps = await db.query(
      "visits",
      where: "visitedOn >= ? AND visitedOn < ?",
      whereArgs: [start, end],
    );

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

    List<TookItem> list = maps.map((mapRow) => TookItem.fromMap(mapRow)).toList();

    //Ordne alle Einträge den passenden keys zu
    for (var item in list) {
      String dateKey = DateFormat(year ? "MM.yyyy" : "dd.MM.yyyy").format(item.tookTime);
      dateMap.putIfAbsent(dateKey, () => 0);
      dateMap[dateKey] = (dateMap[dateKey] ?? 0) + 1;
    }
    return dateMap;
  }


  //TODO: Add upload and set local-Db entry with primary id from server => If Error save with negativ id or updated_on null => upload when possible and update with server-id
  Future<TookItem> addVisit(int userId) async {
    final db = await database;

    DateTime createdOn = DateTime.now();
    String? date = await HttpHelper().addVisit(userId: userId, visitTime: createdOn.toIso8601String());

    int itemId = await db.insert(
      "visits",
      {
        "userId" : userId,
        "visitedOn" : createdOn.toIso8601String(),
        "updated_on": date ?? "-1" //if HttpRequest successful => date else -1
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return TookItem(
        id:itemId,
        userId: userId,
        tookTime: createdOn
    );
  }

  Future<void> uploadPendingUsers()async{
    print("Start Sync");
    final db = await database;
    final negativeUsersMap = await db.query(
      "users",
      where: "id < 0",
    );
    List<User> negativeUsers = negativeUsersMap.map((item) => User.fromMap(item, null)).toList();

    String updatedOn = DateTime.now().toIso8601String();
    for (final item in negativeUsers) {
      int? newId = await HttpHelper().addCustomer(
        uuId: item.uuId,
        firstName: item.firstName,
        lastName: item.lastName,
        birthday: item.birthDay,
        countryCode: item.birthCountry,
        notes: item.miscellaneous,
      );

      if (newId != null) {
        await updateUserAndVisitId(item, newId, updatedOn);
        print("Upload successful for user ${item.uuId}");
      } else {
        print("ERROR uploading user ${item.uuId}");
      }
    }
  }

  Future<void> updatePendingUsers()async{
    print("Start Sync of failed updates");
    final db = await database;
    final notUpdatedUsers = await db.query(
      "users",
      where: "updated_on = ? AND id > 0",
      whereArgs: ["-1"]
    );

    for (final item in notUpdatedUsers){
      User user = User.fromMap(item, null);
      var result = await HttpHelper().updateCustomer(
          id: user.id,
          uuid: user.uuId,
          firstName: user.firstName,
          lastName: user.lastName,
          birthday: user.birthDay,
          countryCode: user.birthCountry,
          notes: user.miscellaneous
      );
      //TODO: UploadVisits//updateVisits
      if(result != null){
        print("Update successfull");
      } else {
        print("ERROR");
      }
    }
  }

  Future<void> uploadPendingVisits() async {
    final db = await database;
    final negativeVisitMap = await db.query(
        "visits",
        where: "updated_on = ? AND userId > 0",
        whereArgs: ["-1"]
    );
    for (final map in negativeVisitMap) {
      int userId = map["userId"] as int;
      String visitedOn =  map["visitedOn"] as String;
      var result = await HttpHelper().addVisit(userId:userId, visitTime: visitedOn);
      if(result != null){
        await db.update(
            "visits",
            {
              "updated_on" : DateTime.now().toIso8601String()
            },
            where: "id = ? AND userId = ?",
            whereArgs: [map["id"],userId]
        );
      }
    }
  }

  ///Updated id of user and visits after successful upload of previously failed addUser
  Future<void> updateUserAndVisitId(User currentUser, int newId, String updatedOn) async {
    final db = await database;

    await db.update(
        "users",
        {
          "id" : newId,
          "updated_on": updatedOn
        },
        where: "id = ?",
        whereArgs: [currentUser.id]);

    //TODO: In the current version id of visit is never used, its always referenced as the last of the visits with userId
    await db.update(
        "visits",
        {
          "userId": newId,
        },
        where: "userId = ?",
        whereArgs: [currentUser.id]
    );
  }

  //TODO: Add upload and set local-Db entry with primary id from server  => If Error save with negativ id or updated_on null => upload when possible and update with server-id
  Future<User> addUser({
    required int? id,
    required String uuId,
    required String firstName,
    required String lastName,
    required DateTime birthDay,
    String? birthCountry,
    String? notes}) async {
      final db = await database;
      final minNegativeIdRow = await db.rawQuery(
          "SELECT MIN(id) as minId FROM users WHERE id < 0"
      );
      int minId = minNegativeIdRow.first["minId"] as int? ?? 0;
      id ??= (minId - 1);
      print("ID $id");
        try {
          await db.insert(
            "users",
            {
              "id": id,
              "uuid": uuId,
              "firstName": firstName,
              "lastName": lastName,
              "birthday": birthDay.toIso8601String(),
              "country": birthCountry ?? "",
              "notes": notes ?? "",
              "updated_on" : DateTime.now().toIso8601String()
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          );

          return User(
            id: id,
            uuId: uuId,
            firstName: firstName,
            lastName: lastName,
            //createdOn: createdOn,
            birthDay: birthDay,
            birthCountry: birthCountry ?? "",
            hasChild: false,
            miscellaneous: notes ?? "",
            visits: []
          );
        } catch (e) {
          if (e is DatabaseException && e.isUniqueConstraintError()) {
            if (kDebugMode) {
              print(e);
            }
          }
          rethrow;
        }

  }

  Future<List<User>> getUsers({
    String? search,
    String? uuid,
  }) async {
    final db = await database;
    List<String> conditions = [];
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      conditions.add("LOWER(u.firstName || ' ' || u.lastName) LIKE ?");
      whereArgs.add("%${search.toLowerCase()}%");
    }
    if (uuid != null && uuid.isNotEmpty) {
      conditions.add("LOWER(u.uuid) = ?");
      whereArgs.add(uuid.toLowerCase());
    }

    final maps = await db.rawQuery('''
        SELECT u.*, 
               v.id as visitId, 
               v.userId, 
               v.visitedOn
        FROM users u
        LEFT JOIN visits v ON u.id = v.userId
        ${conditions.isNotEmpty ? "WHERE ${conditions.join(" AND ")}" : ""}
        ORDER BY u.id, v.visitedOn DESC
        ''',
        whereArgs);

    Map<int, User> usersMap = {};

    for (final row in maps) {
      final userId = row["id"] as int;

      if (!usersMap.containsKey(userId)) {
        usersMap[userId] = User.fromMap(row, []);
      }

      if (row["visitId"] != null) {
        usersMap[userId]!.visits.add(TookItem.fromMap(row));
      }
    }
    return usersMap.values.toList();
  }

  Future<User?> getUserByUuid(String uuId) async {
    final users = await getUsers(uuid: uuId);
    return users.isNotEmpty ? users.first : null;
  }

  Future<void> updateUser(User user, bool updateSuccessFull) async {
    final db = await database;

      await db.update(
          "users",
          {
            "firstName" : user.firstName,
            "lastName" : user.lastName,
            "birthday": user.birthDay.toIso8601String(),
            "country": user.birthCountry,
            "notes": user.miscellaneous,
            "updated_on": updateSuccessFull ? DateTime.now().toIso8601String() : "-1"
          },
          where: "id = ?",
          whereArgs: [user.id]);
  }



  //TODO: delete visit from server => If Error save to seperate table => make table on server with deleted where uuid gets saved, then check local if uuid exists and if delete
  Future<DateTime?> deleteLatestAndReturnPrevious(User user) async {
    final db = await database;
    int id = user.id;

    final result = await db.query(
      "visits",
      columns: ["visitedOn"],
      where: "userId = ?",
      whereArgs: [id],
      orderBy: "visitedOn DESC",
      limit: 2,
    );

    //result[0] is newest, is deleted, result[1] is the one before gets returned as new latest
    if (result.isEmpty) { //should never be the case since if empty there is no possibility to delete
      return null;
    }

    await db.delete(
      "visits",
      where: "userId = ? AND visitedOn = ?",
      whereArgs: [id, result.first["visitedOn"]],
    );

    if (result.length > 1) {
      return DateTime.parse(result.last["visitedOn"] as String);
    } else {
      return null; //if there is no second entry visits for user is empty
    }
  }

  //TODO: delete in Databse
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete (
        "users",
      where: "id = ?",
      whereArgs: [id]
    );
  }


/*Future<int> getLastVisit(int userId) async { //Obsolet
    final db = await database;

    final result = await db.query(
      "visits",
      columns: ["visitedOn"],
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "visitedOn DESC",
      limit: 1,
    );

    int lastVisit = -1;
    if(result.isNotEmpty) lastVisit = result.first["visitedOn"] as int;

    return lastVisit;
  }

  Future<int> countAllVisits() async{
    final db = await database;
    int result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) as count FROM visits")) ?? 0;
    return result;
  }
  */
}