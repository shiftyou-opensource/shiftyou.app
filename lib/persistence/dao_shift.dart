import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/abstract_dao_model.dart';
import 'package:sqflite/sqflite.dart';

class DAOShift extends AbstractDAOModel<ShiftScheduler> {
  @override
  Future<ShiftScheduler?> get(
      AbstractDAO dao, Map<String, dynamic> options) async {
    final List<Map<String, dynamic>> maps = await dao.getInstance
        .query('Shifts', where: "user_id = " + options["user_id"].toString());
    if (maps.isEmpty) {
      return null;
    }
    return ShiftScheduler.fromDatabase(
      maps[0]['id'],
      maps[0]['start'],
      maps[0]['end'],
      maps[0]['start_with'],
    );
  }

  @override
  Future<List<ShiftScheduler>> getAll(AbstractDAO dao) async {
    final List<Map<String, dynamic>> maps =
        await dao.getInstance.query('Shifts');
    if (maps.isEmpty) {
      return List.empty();
    }
    return List.generate(maps.length, (i) {
      return ShiftScheduler.fromDatabase(
        maps[i]['id'],
        maps[i]['start'],
        maps[i]['end'],
        maps[i]['start_with'],
      );
    });
  }

  @override
  void insert(AbstractDAO dao, ShiftScheduler toInsert) {
    dao.getInstance.insert("Shifts", toInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
