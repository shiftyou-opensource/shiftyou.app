import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao_model.dart';
import 'package:sqflite/sqflite.dart';
import 'abstract_dao.dart';

class DAOUser extends AbstractDAOModel<UserModel> {
  DAOUser({String tableName = "Users"}) : super(tableName);

  @override
  Future<int> insert(AbstractDAO<dynamic> dao, UserModel toInsert) async {
    return await dao.getInstance.insert(super.tableName, toInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<UserModel?> get(
      AbstractDAO<dynamic> dao, Map<String, dynamic> options) async {
    final List<Map<String, dynamic>> maps =
        await dao.getInstance.query(super.tableName);
    if (maps.isEmpty) {
      return null;
    }
    return UserModel(
      id: maps[0]['id'],
      name: maps[0]['name'],
      logged: false,
      initialized: true,
    );
  }

  @override
  Future<List<UserModel>> getAll(AbstractDAO dao) async {
    final List<Map<String, dynamic>> maps =
        await dao.getInstance.query(super.tableName);
    if (maps.isEmpty) {
      return List.empty();
    }
    return List.generate(maps.length, (i) {
      return UserModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        logged: false,
        initialized: true,
      );
    });
  }

  @override
  Future<UserModel> delete(AbstractDAO dao, Map<String, dynamic> options) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> update(AbstractDAO dao, UserModel user) async {
    return await dao.getInstance.update(super.tableName, user.toMap());
  }
}
