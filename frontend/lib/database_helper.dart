import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
      join(path, "storhhalm_db_version8.db"),
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY,
            uuid TEXT UNIQUE,
            firstName TEXT,
            lastName TEXT,
            birthday TEXT,
            country TEXT,
            lastVisit TEXT,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE visits(
            id INTEGER PRIMARY KEY,
            customerId INTEGER,
            visitDate TEXT,
            updated_on TEXT
          )
        ''');
      },
      version: 1,
    );
  }


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
      countryCounts[row["country"] as String] = [(row["percentage"] as num).toDouble(), (row["number"] as num).toInt()];
    }
    return countryCounts;
  }


  Future<Map<String, int>> getAllVisitsInPeriod(int monthsBack, bool year) async {
    final db = await database;
    final now = DateTime.now();

    final startDate = year
        ? DateTime(now.year - monthsBack, 1, 1)
        : DateTime.utc(now.year, now.month - monthsBack, 1);

    final endDate = year
        ? DateTime(now.year - monthsBack + 1, 1, 1) // nächstes Jahr
        : DateTime.utc(now.year, now.month - monthsBack + 1, 1);

    final start = startDate.toIso8601String();
    final end = endDate.toIso8601String();

    final format = year ? '%m.%Y' : '%d.%m.%Y';

    final visitsByDate = await db.rawQuery('''
          SELECT strftime('$format', visitDate) AS date, COUNT(*) AS visits
          FROM visits
          WHERE visitDate >= ? AND visitDate < ?
          GROUP BY strftime('$format', visitDate)
          ORDER BY date
        ''',
        [start, end]);

    // Map initialisieren
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

    // Query-Ergebnisse einfügen
    for (var item in visitsByDate) {
      final dateKey = item["date"] as String;
      final count = item["visits"] as int;
      dateMap[dateKey] = count;
    }

    return dateMap;
  }


  Future<TookItem> addVisit(int userId) async {
    final db = await database;

    DateTime createdOn = DateTime.now(); //.subtract(Duration(days: Random().nextInt(365)+300));
    int itemId = await db.insert(
      "visits",
      {
        "customerId" : userId,
        "visitDate" : createdOn.toIso8601String(),
        //"updated_on": item != null ? item.tookTime.toIso8601String() : "-1" //if HttpRequest successful => date else -1
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    
   updateUserLastVisit(userId, createdOn);

    return TookItem(
        id:itemId,
        userId: userId,
        tookTime: createdOn
    );
  }

  Future<void> updateUserLastVisit(int userId, DateTime? visitDate) async {
    final db = await database;
    await db.update(
        "users",
        {
          "lastVisit": visitDate == null ? null : DateFormat("yyyy-MM-dd").format(visitDate)
        },
        where: "id = ?",
        whereArgs: [userId]
    );
  }


  Future<User> addUser({
    required String uuId,
    required String firstName,
    required String lastName,
    required DateTime birthDay,
    String? birthCountry,
    String? notes}) async {
      final db = await database;
      //final minNegativeIdRow = await db.rawQuery(
      //    "SELECT MIN(id) as minId FROM users WHERE id < 0"
      //);
      //int minId = minNegativeIdRow.first["minId"] as int? ?? 0;
      //id ??= (minId - 1);
        try {
          int id = await db.insert(
            "users",
            {
              "uuid": uuId,
              "firstName": firstName,
              "lastName": lastName,
              "birthday": birthDay.toIso8601String(),
              "country": birthCountry ?? "",
              "notes": notes ?? "",
              //"updated_on" : DateTime.now().toIso8601String()
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          );

          return User(
            id: id,
            uuId: uuId,
            firstName: firstName,
            lastName: lastName,
            birthDay: birthDay,
            country: birthCountry ?? "",
            notes: notes ?? "",
            lastVisit: null
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
    DateTime? lastVisitBefore,
  }) async {
    final db = await database;
    List<String> conditions = [];
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      conditions.add("LOWER(firstName || ' ' || lastName) LIKE ?");
      whereArgs.add("%${search.toLowerCase()}%");
    }
    if (uuid != null && uuid.isNotEmpty) {
      conditions.add("LOWER(uuid) = ?");
      whereArgs.add(uuid.toLowerCase());
    }
    if(lastVisitBefore != null){
      conditions.add("lastVisit < ?");
      whereArgs.add(lastVisitBefore.toIso8601String());
    }

    List<Map<String, dynamic>> maps = await db.query(
      "users",
      where: conditions.join(" AND "),
      whereArgs: whereArgs,
      orderBy: "lastVisit DESC",
    );

    List<User> users = [];
    for(Map<String, dynamic> map in maps){
      User user = User.fromMap(map);
      users.add(user);
    }
    return users;
  }

  Future<List<TookItem>> getVisits(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      "visits",
      where: "customerId = ?",
      whereArgs: [userId],
      orderBy: "visitDate DESC",
    );
    return maps.map((mapRow) => TookItem.fromMap(mapRow)).toList();
  }

  Future<void> updateUser(User user) async { //bool updateSuccessFull
    final db = await database;

      await db.update(
          "users",
          {
            "firstName" : user.firstName,
            "lastName" : user.lastName,
            "birthday": user.birthDay.toIso8601String(),
            "country": user.country,
            "notes": user.notes,
          },
          where: "id = ?",
          whereArgs: [user.id]);
  }

  Future<String?> deleteLatestAndReturnPrevious(User user) async {
    final db = await database;
    int id = user.id;

    final result = await db.query(
      "visits",
      where: "customerId = ?",
      whereArgs: [id],
      orderBy: "visitDate DESC",
      limit: 2,
    );

    //result[0] is newest, is deleted, result[1] is the one before gets returned as new latest
    if (result.isEmpty) { //should never be the case since if empty there is no possibility to delete
      return null;
    }

    await db.delete(
      "visits",
      where: "customerId = ? AND visitDate = ?",
      whereArgs: [id, result.first["visitDate"]],
    );

    DateTime? newLastVisit;
    if (result.length > 1) {
      final visitDateString = result.last["visitDate"] as String?;
      if (visitDateString != null) {
        newLastVisit = DateTime.tryParse(visitDateString);
      }
    }

    updateUserLastVisit(id, newLastVisit);

    // Return string of previous visit if it exists, else null
    return newLastVisit?.toIso8601String();
  }

  Future<bool> deleteUser(int id) async {
    final db = await database;
    int rowsAffected = await db.delete (
        "users",
      where: "id = ?",
      whereArgs: [id]
    );

    //Set Visit id to -1 so it still counts in the statistic
    await db.update(
        "visits",
        {
          "customerId": -1,
        },
        where: "customerId = ?",
        whereArgs: [id]
    );

    return rowsAffected > 0;
  }
}

//Sync Strategy:
/*Future<void> uploadPendingUsers()async{
    print("Start Sync");
    final db = await database;
    final negativeUsersMap = await db.query(
      "users",
      where: "id < 0",
    );
    List<User> negativeUsers = negativeUsersMap.map((item) => User.fromMap(item)).toList();

    String updatedOn = DateTime.now().toIso8601String();
    for (final item in negativeUsers) {
      //int? newId = await HttpHelper().addCustomer(
      //  uuId: item.uuId,
      //  firstName: item.firstName,
      //  lastName: item.lastName,
      //  birthday: item.birthDay,
      //  countryCode: item.country,
      //  notes: item.notes,
      //);

      //if (newId != null) {
      //  await updateUserAndVisitId(item, newId, updatedOn);
      //  print("Upload successful for user ${item.uuId}");
      //} else {
      //  print("ERROR uploading user ${item.uuId}");
      //}
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
      User user = User.fromMap(item);
      var result = await HttpHelper().updateCustomer(
          user: user
      );
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
        where: "updated_on = ? AND customerId > 0",
        whereArgs: ["-1"]
    );
    for (final map in negativeVisitMap) {
      int userId = map["customerId"] as int;
      String visitedOn =  map["visitDate"] as String;
      var result = await HttpHelper().addVisit(userId:userId, visitTime: visitedOn);
      if(result != null){
        await db.update(
            "visits",
            {
              "updated_on" : DateTime.now().toIso8601String()
            },
            where: "id = ? AND customerId = ?",
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

    await db.update(
        "visits",
        {
          "customerId": newId,
        },
        where: "customerId = ?",
        whereArgs: [currentUser.id]
    );
  }

  Future<void> syncWithDatabase()async{
    // - check field updated_at of customer and visited_on from Visits on Server
    // - request Customers and visits with date > lastTimeFiredFunction
    // - Add Data to local database (if id exists update, else add)

    // - get all uuid in deleted_table
    // - iterate trough result and delete all entries with uuid
  }

  Future<int> countAllVisits() async{
    final db = await database;
    int result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) as count FROM visits")) ?? 0;
    return result;
  }

  /*final maps = await db.rawQuery('''

        SELECT u.*,
               v.id as visitId,
               v.userId,
               v.visitDate
        FROM users u
        LEFT JOIN visits v ON u.id = v.userId
        ${conditions.isNotEmpty ? "WHERE ${conditions.join(" AND ")}" : ""}
        ORDER BY u.id, v.visitDate DESC
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
    return usersMap.values.toList();*/
  */