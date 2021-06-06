import 'dart:async';

import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/dao_user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DAODatabase extends AbstractDAO<Database> {
  Database? _database;
  late DAOUser _daoUser;

  DAODatabase() {
    init();
  }

  Future<void> init() async {
    if (this._database != null) {
      return;
    }
    this._daoUser = DAOUser();
    this._database = await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        join(await getDatabasesPath(), 'database.db'), onCreate: (db, version) {
      return db
          .execute("CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT)");
    }, version: 1);
  }

  @override
  Database get getInstance {
    return this._database!;
  }

  @override
  Future<UserModel?> getUser() async {
    return await this._daoUser.get(this);
  }

  @override
  Future<void> insertUser(UserModel user) async {
    await this._daoUser.insert(this, user);
  }
}
