import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/abstract_dao_model.dart';
import 'package:sqflite/sqlite_api.dart';

/// @author https://github.com/vincenzopalazzo
class DAOShiftException extends AbstractDAOModel<Shift> {
  late Logger _logger;

  DAOShiftException({String tableName = "Exception"}) : super(tableName) {
    this._logger = Logger();
  }

  @override
  Future<Shift?> get(AbstractDAO dao, Map<String, dynamic> options) async {
    throw Exception("Not implemented yet");
  }

  @override
  Future<List<Shift>> getAll(AbstractDAO dao) async {
    List<Map<String, dynamic>> exceptionsMap =
        await dao.getInstance.query(super.tableName);
    _logger.d(
        "Get all exception inside the db return the following result ${exceptionsMap.toString()}");
    List<Shift> exceptions = List.empty(growable: true);
    exceptionsMap.forEach((element) {
      var shift = Shift.fromDatabase(element);
      exceptions.add(shift);
    });
    _logger.d("Size of exception are ${exceptions.length}");
    return exceptions;
  }

  @override
  Future<int> insert(AbstractDAO dao, Shift toInsert) async {
    _logger.d("Put in the db the following exception ${toInsert.toMap()}");
    return await dao.getInstance.insert(super.tableName, toInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> delete(AbstractDAO dao, Map<String, dynamic> options) async {
    return await dao.getInstance.delete(super.tableName);
  }

  @override
  Future<void> update(AbstractDAO dao, Shift toUpdate) async {
    _logger.d(
        "Update Exception with the following data ${toUpdate.toMap(update: true)}");
    return await dao.getInstance.update(
        "Exception", toUpdate.toMap(update: true),
        where: 'id = ?', whereArgs: [toUpdate.id]);
  }
}
