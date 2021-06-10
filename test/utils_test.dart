import 'package:flutter_test/flutter_test.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/utils/converter.dart';

void main() {
  test("convert shift to number", () {
    var index = Converter.fromShiftTimeToIndex(ShiftTime.MORNING);
    expect(0, index);

    index = Converter.fromShiftTimeToIndex(ShiftTime.AFTERNOON);
    expect(1, index);

    index = Converter.fromShiftTimeToIndex(ShiftTime.NIGHT);
    expect(2, index);

    index = Converter.fromShiftTimeToIndex(ShiftTime.FREE);
    expect(3, index);
  });

  test("convert number to shift", () {
    var shift = Converter.fromIntToShiftTime(0);
    expect(ShiftTime.MORNING, shift);

    shift = Converter.fromIntToShiftTime(1);
    expect(ShiftTime.AFTERNOON, shift);

    shift = Converter.fromIntToShiftTime(2);
    expect(ShiftTime.NIGHT, shift);

    shift = Converter.fromIntToShiftTime(3);
    expect(ShiftTime.FREE, shift);
  });
}
