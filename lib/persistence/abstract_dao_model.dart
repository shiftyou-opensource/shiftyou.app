import 'package:nurse_time/persistence/abstract_dao.dart';

abstract class AbstractDAOModel<T> {
  void insert(AbstractDAO<dynamic> dao, T toInsert);

  Future<List<T>> getAll(AbstractDAO<dynamic> dao);

  Future<T> get(AbstractDAO<dynamic> dao);
}
