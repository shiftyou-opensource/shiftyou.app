import 'package:nurse_time/persistence/abstract_dao.dart';

abstract class AbstractDAOModel<T> {
  Future<int> insert(AbstractDAO<dynamic> dao, T toInsert);

  Future<List<T>> getAll(AbstractDAO<dynamic> dao);

  Future<T?> get(AbstractDAO<dynamic> dao, Map<String, dynamic> options);

  Future<T> delete(AbstractDAO<dynamic> dao, Map<String, dynamic> options);

  Future<void> update(AbstractDAO<dynamic> dao, T toUpdate);
}
