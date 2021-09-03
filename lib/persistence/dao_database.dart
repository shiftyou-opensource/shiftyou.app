import 'dart:async';

import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/dao_shift.dart';
import 'package:nurse_time/persistence/dao_user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DAODatabase extends AbstractDAO<Database> {
  Database? _database;
  late DAOUser _daoUser;
  late DAOShift _daoShift;
  late Logger _logger;
  Map<int, String> _migrationScripts = {
    4: "ALTER TABLE Shifts ADD scheduler_rules TEXT; ALTER TABLE Shifts DROP start_with;",
    5: "ALTER TABLE Shifts ADD manual INTEGER;",
    6: "CREATE TABLE Exception(id INTEGER PRIMARY KEY autoincrement, "
        "day_timestamp INTEGER, shift INTEGER, done INTEGER, user_id REFERENCES Users(id))",
  };

  DAODatabase() {
    _logger = Logger();
    init();
  }

  Future<void> init() async {
    if (this._database != null) {
      return;
    }
    this._daoUser = DAOUser();
    this._daoShift = DAOShift();
    this._database = await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        join(await getDatabasesPath(), 'database.db'),
        onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE Users(id INTEGER PRIMARY KEY autoincrement, name TEXT)");
      // In this case it is useful to have the user as foreign key because a shift can be composed
      // also from only exception, an example can be the manual scheduler.
      // at this time we have no information on how will use this app, for this reason, we maintains the table
      // more general. In this case is more logic that a shift have a sequence of exception, however in this case
      // the design choice is explained before. p.s: I'm very bad make decision on the SQL schema.
      await db.execute(
          "CREATE TABLE Exception(id INTEGER PRIMARY KEY autoincrement, "
          "day_timestamp INTEGER, shift INTEGER, done INTEGER, user_id REFERENCES Users(id))");
      await db.execute("CREATE TABLE "
          "Shifts(id INTEGER PRIMARY KEY autoincrement, start INTEGER, "
          "end INTEGER, start_with INTEGER, scheduler_rules TEXT, manual INTEGER,"
          "user_id REFERENCES Users(id)"
          ")");
    }, onUpgrade: (db, oldVersion, newVersion) async {
      _logger.d(
          "Migrate DB from a old version $oldVersion to new version $newVersion");
      for (int i = oldVersion + 1; i <= newVersion; i++) {
        if (_migrationScripts.containsKey(i))
          await db.execute(_migrationScripts[i]!);
      }
    }, version: 6);
  }

  @override
  Database get getInstance {
    return this._database!;
  }

  @override
  Future<UserModel?> getUser() async {
    return await this._daoUser.get(this, {});
  }

  @override
  Future<void> insertUser(UserModel user) async {
    this._daoUser.insert(this, user);
  }

  @override
  Future<ShiftScheduler?> getShift(int userId) async {
    return await this._daoShift.get(this, {"user_id": userId});
  }

  @override
  Future<void> insertShift(ShiftScheduler shift) async {
    this._daoShift.insert(this, shift);
  }
}
