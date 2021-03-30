import 'package:flutter_test/flutter_test.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';

/// @author https://github.com/vincenzopalazzo
void main() {
  test('TestGenerateSchedulerOne', () {
    var start = DateTime.now();
    var end = start.add(Duration(days: 2));

    var scheduler = ShiftScheduler(start, end);
    var schedulerGenerate = scheduler.generateScheduler();
    print(schedulerGenerate);

    var expectedScheduler = List.empty(growable: true);
    var next = ShiftTime.AFTERNOON;
    var iterate = start;
    print(iterate.difference(end).inDays);
    while (end.difference(iterate).inDays >= 0) {
      expectedScheduler.add(Shift(iterate, next));
      iterate = iterate.add(Duration(days: 1));
      switch (next) {
        case ShiftTime.AFTERNOON:
          next = ShiftTime.MORNING;
          break;
        case ShiftTime.MORNING:
          next = ShiftTime.NIGHT;
          break;
        case ShiftTime.NIGHT:
          next = ShiftTime.FREE;
          break;
        case ShiftTime.FREE:
          next = ShiftTime.AFTERNOON;
          break;
      }
    }
    print(expectedScheduler);
    expect(expectedScheduler, equals(schedulerGenerate));
  });
}
