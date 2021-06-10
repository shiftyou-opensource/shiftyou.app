import 'package:nurse_time/model/shift.dart';

class Converter {
  static ShiftTime fromIntToShiftTime(int index) {
    switch (index) {
      case 0:
        return ShiftTime.MORNING;
      case 1:
        return ShiftTime.AFTERNOON;
      case 2:
        return ShiftTime.NIGHT;
      case 3:
        return ShiftTime.FREE;
      default:
        throw Exception(
            "Index not recognize to (re)cereate the shift time enumas");
    }
  }

  static int fromShiftTimeToIndex(ShiftTime shiftTime) {
    switch (shiftTime) {
      case ShiftTime.MORNING:
        return 0;
      case ShiftTime.AFTERNOON:
        return 1;
      case ShiftTime.NIGHT:
        return 2;
      case ShiftTime.FREE:
        return 3;
      default:
        throw Exception("Shift time not recognized");
    }
  }
}
