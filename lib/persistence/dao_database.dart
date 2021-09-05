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

  // Used to store the QUERY to migrate the database
  // it is useful to add or remove row in the db table.
  Map<int, String> _migrationScripts = {};

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
        join(await getDatabasesPath(), 'database.db'), onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }, onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE Users(id INTEGER PRIMARY KEY autoincrement, name TEXT)");
      await db.execute("CREATE TABLE "
          "Shifts(id INTEGER PRIMARY KEY autoincrement, start INTEGER, "
          "end INTEGER, start_with INTEGER, scheduler_rules TEXT, manual INTEGER,"
          "user_id INTEGER, FOREIGN KEY(user_id) REFERENCES Users(id) ON DELETE CASCADE ON UPDATE CASCADE)");
      await db.execute(
          "CREATE TABLE Exception(id INTEGER PRIMARY KEY autoincrement, "
          "day_timestamp INTEGER, shift INTEGER, done INTEGER, shift_id INTEGER, "
          "FOREIGN KEY(shift_id) REFERENCES Shifts(id) ON DELETE CASCADE ON UPDATE CASCADE)");
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
  Future<int> insertUser(UserModel user) async {
    return await this._daoUser.insert(this, user);
  }

  @override
  Future<ShiftScheduler?> getShift(int userId) async {
    var result = await this._daoShift.get(this, {"user_id": userId});
    if (result != null) result.notify();
    return result;
  }

  @override
  Future<int> insertShift(ShiftScheduler shift) async {
    var id = await this._daoShift.insert(this, shift);
    shift.id = id;
    return id;
  }

  @override
  Future<void> deleteShift(ShiftScheduler shift) {
    // TODO: implement deleteShift
    throw UnimplementedError();
  }

  @override
  Future<void> updateShift(ShiftScheduler shift) async {
    return await this._daoShift.update(this, shift);
  }
}
