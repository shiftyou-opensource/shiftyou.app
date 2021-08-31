import 'package:nurse_time/model/shift.dart';

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
}
