import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:strohhalm_app/user_and_visit.dart';

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
      join(path, "storhhalm_db_ver1_0.db"),
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

  Future<List<Map<String, dynamic>>> getVisitDistribution() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT visit_count AS visits, COUNT(*) AS customers
    FROM (
      SELECT customerId, COUNT(*) AS visit_count
      FROM visits
      GROUP BY customerId
    )
    GROUP BY visit_count
    ORDER BY visit_count;
  ''');

    return result;
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


  Future<Visit?> addVisit(
      User user,
      [DateTime? time]
      ) async {
    final db = await database;

    DateTime createdOn = time ?? DateTime.now(); //.subtract(Duration(days: );

    //Isn't needed when checking before calling function
    //var existingVisits = await getVisits(user.id);
    //if(existingVisits.any((visit) => Utilities.isSameDay(visit.tookTime,createdOn))) return null;

    int itemId = await db.insert(
      "visits",
      {
        "customerId" : user.id,
        "visitDate" : createdOn.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    if(user.lastVisit == null || user.lastVisit!.isBefore(createdOn)){
      updateUserLastVisit(user.id, createdOn);

      return Visit(
          id: itemId,
          userId: user.id,
          tookTime: createdOn
      );
    } else {
      return null;
    }
  }

  Future<void> updateUserLastVisit(int userId, DateTime? visitDate) async {
    final db = await database;
    await db.update(
        "users",
        {
          "lastVisit": visitDate?.toIso8601String()
        },
        where: "id = ?",
        whereArgs: [userId]
    );
  }

  ///Checks if a User with the specified fields already exists. If true returns the id, else -1
  Future<int> checkIfUserExists({
    String? firstName,
    String? lastName,
    DateTime? birthDay,
    String? country,
    String? notes,
  }) async {
    final db = await database;

    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (firstName != null) {
      whereClauses.add("firstName = ?");
      whereArgs.add(firstName);
    }
    if (lastName != null) {
      whereClauses.add("lastName = ?");
      whereArgs.add(lastName);
    }
    if (birthDay != null) {
      whereClauses.add("birthday = ?");
      whereArgs.add(birthDay.toIso8601String());
    }
    if (country != null) {
      whereClauses.add("country = ?");
      whereArgs.add(country);
    }
    if (notes != null) {
      whereClauses.add("notes = ?");
      whereArgs.add(notes);
    }

    final result = await db.query(
      "users",
      where: whereClauses.isNotEmpty ? whereClauses.join(" AND ") : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      limit: 1,
    );

    return result.isNotEmpty ? result.first["id"] as int : -1;
  }

  Future<AddUpdateUserReturnType?> addUser({
    required User user
  }) async {
      final db = await database;

      int exists = await checkIfUserExists(
          firstName: user.firstName,
          lastName: user.lastName,
          birthDay: user.birthDay,
          country: user.country
      );
      if(exists != -1) return AddUpdateUserReturnType(exists, true);
        try {
          int id = await db.insert(
            "users",
            {
              "uuid": user.uuId,
              "firstName": user.firstName,
              "lastName": user.lastName,
              "birthday": user.birthDay.toIso8601String(),
              "country": user.country,
              "notes": user.notes ?? "",
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
          return AddUpdateUserReturnType(id, false);
          //return User(
          //  id: id,
          //  uuId: uuId,
          //  firstName: firstName,
          //  lastName: lastName,
          //  birthDay: birthDay,
          //  country: birthCountry ?? "",
          //  notes: notes ?? "",
          //  lastVisit: null
          //);
        } catch (e) {
          if (e is DatabaseException && e.isUniqueConstraintError()) {
            if (kDebugMode) {
              print(e);
            }
          }
          return null;
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

  Future<int> countAllUsers() async{
    final db = await database;
    int result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) as count FROM users")) ?? 0;
    return result;
  }

  Future<List<Visit>> getVisits(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      "visits",
      where: "customerId = ?",
      whereArgs: [userId],
      orderBy: "visitDate DESC",
    );
    return maps.map((mapRow) => Visit.fromMap(mapRow)).toList();
  }

  //Future<bool?> updateUserNote(int id, String note)async { //bool updateSuccessFull
  //  final db = await database;
//
  //  try{
  //    await db.update(
  //        "users",
  //        {
  //          "notes": note,
  //        },
  //        where: "id = ?",
  //        whereArgs: [id]);
  //    return true;
  //  } catch(ev) {
  //    debugPrint("$ev");
  //    return null;
  //  }
  //}

  Future<bool?> updateUser(User user) async {
    final db = await database;
    int exists = await checkIfUserExists(
        firstName: user.firstName,
        lastName: user.lastName,
        birthDay: user.birthDay,
        country: user.country,
        notes: user.notes
    );
    if(exists != -1) return false;

      try{
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
        return true;
      } catch(ev) {
        debugPrint("$ev");
        return null;
      }
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

    //Set Visit id to 0-id, so its negatively unique
    await db.update(
        "visits",
        {
          "customerId": 0-id,
        },
        where: "customerId = ?",
        whereArgs: [id]
    );

    return rowsAffected > 0;
  }
}

class AddUpdateUserReturnType{
  int id;
  bool existed;

  AddUpdateUserReturnType(
      this.id,
      this.existed
      );
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