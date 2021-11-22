import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';

abstract class AbstractDAO<T> {
  void init();

  T get getInstance;

  Future<int> insertUser(UserModel user);

  Future<void> updateUser(UserModel userModel);

  Future<UserModel?> getUser();

  Future<int> insertShift(ShiftScheduler shift);

  Future<ShiftScheduler?> getShift(int user);

  Future<void> deleteShift(ShiftScheduler shift);

  Future<void> updateShift(ShiftScheduler shift);

  Future<void> deleteShiftException(ShiftScheduler shift);
}
