import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/abstract_dao_model.dart';
import 'package:nurse_time/persistence/dao_shift_exception.dart';
import 'package:sqflite/sqflite.dart';

class DAOShift extends AbstractDAOModel<ShiftScheduler> {
  late DAOShiftException _daoShiftException;

  DAOShift() {
    _daoShiftException = DAOShiftException();
  }

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

    ShiftScheduler scheduler = ShiftScheduler.fromDatabase(
      maps[0]['id'],
      maps[0]['start'],
      maps[0]['end'],
      schedulerRule,
      manual,
    );

    List<Shift> exceptions = await _daoShiftException.getAll(dao);
    scheduler.setExceptions(exceptions);
    return scheduler;
  }

  //TODO: Missed the exception here (the shift has a list of exceptions)
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
    // Find a way to do it in a single db operation
    toInsert.getExceptions().forEach((element) {
      _daoShiftException.insert(dao, element);
    });
  }
}
