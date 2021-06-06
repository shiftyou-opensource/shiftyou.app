import 'package:nurse_time/model/user_model.dart';

abstract class AbstractDAO<T> {
  void init();

  T get getInstance;

  Future<void> insertUser(UserModel user);

  Future<UserModel?> getUser();
}
