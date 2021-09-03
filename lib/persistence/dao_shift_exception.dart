import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/abstract_dao_model.dart';
import 'package:sqflite/sqlite_api.dart';

/// @author https://github.com/vincenzopalazzo
class DAOShiftException extends AbstractDAOModel<Shift> {

  late Logger _logger;

  DAOShiftException() {
    this._logger = GetIt.instance<Logger>();
  }

  @override
  Future<Shift?> get(AbstractDAO dao, Map<String, dynamic> options) async {
    throw Exception("Not implemented yet");
  }

  @override
  Future<List<Shift>> getAll(AbstractDAO dao) async {
    List<Map<String, dynamic>> exceptionsMap = await dao.getInstance.query("Exception");
    List<Shift> exceptions = List.empty(growable: true);
    exceptionsMap.forEach((element) {
      var shift = Shift.fromDatabase(element);
      exceptions.add(shift);
    });
    _logger.d("All the exception stored in the database are $exceptions");
    return exceptions;
  }

  @override
  void insert(AbstractDAO dao, Shift toInsert) {
    _logger.d("Put in the db the following exception $toInsert");
    dao.getInstance.insert("Exception", toInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
