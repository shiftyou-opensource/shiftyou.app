import 'dart:async';

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

  DAODatabase() {
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
      await db.execute("CREATE TABLE Users(id INTEGER PRIMARY KEY, name TEXT)");
      // TODO(vincenzopalazzo): Add exception table
      await db.execute("CREATE TABLE "
          "Shifts(id INTEGER PRIMARY KEY autoincrement, start INTEGER, "
          "end INTEGER, start_with INTEGER, user_id REFERENCES Users(id)"
          ")");
    }, version: 2);
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
