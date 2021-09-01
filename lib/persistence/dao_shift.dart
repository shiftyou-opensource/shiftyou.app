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

    var schedulerRule = '1;0;2;3;3';
    if (maps[0].containsKey('scheduler_rules')) {
      schedulerRule = maps[0]['scheduler_rules'];
    }

    var manual = false;
    if (maps[0].containsKey('manual')) {
      manual = maps[0]['manual'] == 0 ? false : true;
    }

    return ShiftScheduler.fromDatabase(
      maps[0]['id'],
      maps[0]['start'],
      maps[0]['end'],
      schedulerRule,
      manual,
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
      var schedulerRule = '1;0;2;3;3';
      if (maps[0].containsKey('scheduler_rules')) {
        schedulerRule = maps[0]['scheduler_rules'];
      }

      var manual = false;
      if (maps[0].containsKey('manual')) {
        manual = maps[0]['manual'] == 0 ? false : true;
      }

      return ShiftScheduler.fromDatabase(
        maps[i]['id'],
        maps[i]['start'],
        maps[i]['end'],
        schedulerRule,
        manual,
      );
    });
  }

  @override
  void insert(AbstractDAO dao, ShiftScheduler toInsert) {
    dao.getInstance.insert("Shifts", toInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
