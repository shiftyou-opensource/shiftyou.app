import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';

class Utils {
  static List<ShiftTime> makeDefaultRules() {
    List<ShiftTime> list = List.empty(growable: true);
    list.add(ShiftTime.AFTERNOON);
    list.add(ShiftTime.MORNING);
    list.add(ShiftTime.NIGHT);
    list.add(ShiftTime.FREE);
    list.add(ShiftTime.FREE);
    return list;
  }

  static List<ShiftTime> makeCustomRules() {
    List<ShiftTime> list = List.empty(growable: true);
    list.add(ShiftTime.FREE);
    list.add(ShiftTime.NIGHT);
    list.add(ShiftTime.MORNING);
    list.add(ShiftTime.AFTERNOON);
    return list;
  }

  static bool checkListShiftWithRules(
      List<Shift> shifts, List<ShiftTime> rules) {
    var startIndex = 0;
    var endIndex = rules.length - 1;
    for (var index = 0; index < shifts.length; index++) {
      var shift = shifts[index];
      if (shift.time != rules[startIndex]) return false;
      startIndex++;
      if (startIndex > endIndex) {
        startIndex = 0;
      }
    }
    return true;
  }

  static void setUpInjector() {
    GetIt.instance.registerLazySingleton<Logger>(() => Logger());
    //TODO Review the database rules here
    GetIt.instance.registerLazySingleton<UserModel>(
            () => UserModel(id: -1, name: "", logged: false, initialized: false));
    GetIt.instance.registerLazySingleton<ShiftScheduler>(
            () => ShiftScheduler(-1, DateTime.now(), DateTime.now()));

    List<SchedulerRules> schedulerRules = List.empty(growable: true);
    var custom = SchedulerRules("Weekly Cadence", false);
    schedulerRules.add(custom);
    var manual = SchedulerRules("Up to you", false);
    manual.manual = true;
    schedulerRules.add(manual);
    GetIt.instance.registerSingleton<List<SchedulerRules>>(schedulerRules);
  }
}
