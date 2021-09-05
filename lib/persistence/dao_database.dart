import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/dao_shift.dart';
import 'package:nurse_time/persistence/dao_shift_exception.dart';
import 'package:nurse_time/persistence/dao_user.dart';
import 'package:nurse_time/utils/app_preferences.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DAODatabase extends AbstractDAO<Database> {
  Database? _database;
  late DAOUser _daoUser;
  late DAOShift _daoShift;
  late DAOShiftException _daoShiftException;
  late Logger _logger;

  static const String CREATE_USERS_TABLE_QUERY =
      "CREATE TABLE Users(id INTEGER PRIMARY KEY, name TEXT)";

  static const String CREATE_SHIFT_TABLE_QUERY = "CREATE TABLE "
      "Shifts(id INTEGER PRIMARY KEY autoincrement, start INTEGER, "
      "end INTEGER, start_with INTEGER, scheduler_rules TEXT, manual INTEGER,"
      "user_id INTEGER, FOREIGN KEY(user_id) REFERENCES Users(id) ON DELETE CASCADE ON UPDATE CASCADE)";

  static const String CREATE_EXCEPTION_TABLE_QUERY =
      "CREATE TABLE Exception(id INTEGER PRIMARY KEY autoincrement, "
      "day_timestamp INTEGER, shift INTEGER, done INTEGER, shift_id INTEGER, "
      "FOREIGN KEY(shift_id) REFERENCES Shifts(id) ON DELETE CASCADE ON UPDATE CASCADE)";

  // Used to store the QUERY to migrate the database
  // it is useful to add or remove row in the db table.
  Map<int, String> _migrationScripts = {};

  DAODatabase() {
    _logger = Logger();
  }

  Future<void> init() async {
    if (this._database != null) {
      return;
    }

    var bruteForce = await AppPreferences.instance
        .valueWithKey(PreferenceKey.BRUTE_MIGRATION_DB) as bool;
    var path = join(await getDatabasesPath(), 'database.db');

    if (bruteForce && await File(path).exists()) {
      _logger.d("Bruce force execution");
      await deleteDatabase(path);
      await AppPreferences.instance.putValue(PreferenceKey.DIALOG_SHOWS, true);
      await AppPreferences.instance.putValue(PreferenceKey.DIALOG_MESSAGE,
          "The app is update to the new version, and your data for the moment are over. We are working hard to provide a solution for the next updates");
    }

    this._database = await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        path, onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }, onCreate: (db, version) async {
      await db.execute(CREATE_USERS_TABLE_QUERY);
      await db.execute(CREATE_SHIFT_TABLE_QUERY);
      await db.execute(CREATE_EXCEPTION_TABLE_QUERY);
      await AppPreferences.instance
          .putValue(PreferenceKey.BRUTE_MIGRATION_DB, false, override: true);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      _logger.i(
          "Migrate DB from a old version $oldVersion to new version $newVersion");
      for (int i = oldVersion + 1; i <= newVersion; i++) {
        if (_migrationScripts.containsKey(i)) {
          _logger.i("Migrate statement ${_migrationScripts[i]}");
          await db.execute(_migrationScripts[i]!);
        }
      }
    }, version: 12);

    this._daoUser = DAOUser();
    this._daoShift = DAOShift();
    this._daoShiftException = DAOShiftException();
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

  @override
  Future<void> deleteShiftException(ShiftScheduler shift) async {
    return await this._daoShiftException.delete(this, {"shift_id": shift.id});
  }
}
