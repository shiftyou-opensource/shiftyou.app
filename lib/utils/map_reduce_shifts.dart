import 'package:nurse_time/model/shift.dart';

// TODO: I can have different Stategy?
class MapReduceShift {
  static Map<ShiftTime, double> reduce(List<Shift> shifts) {
    var reduceMap = Map<ShiftTime, double>();
    shifts.forEach((shift) => {
          if (reduceMap.containsKey(shift.time))
            {reduceMap[shift.time]++}
          else
            {reduceMap[shift.time] = 1}
        });
    return reduceMap;
  }
}
