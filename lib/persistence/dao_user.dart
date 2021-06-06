import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao_model.dart';
import 'package:sqflite/sqflite.dart';
import 'abstract_dao.dart';

class DAOUser extends AbstractDAOModel<UserModel> {
  @override
  Future<void> insert(AbstractDAO<dynamic> dao, UserModel toInsert) async {
    dao.getInstance.insert("users", toInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<UserModel?> get(AbstractDAO<dynamic> dao) async {
    final List<Map<String, dynamic>> maps =
        await dao.getInstance.query('users');
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
        await dao.getInstance.query('users');
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
}
