import 'package:flutter_test/flutter_test.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';

import 'utils/utils.dart';

/// @author https://github.com/vincenzopalazzo
void main() {
  test('TestGenerateScheduler Default', () {
    var start = DateTime.now();
    var end = start.add(Duration(days: 2));

    var scheduler = ShiftScheduler(-1, start, end);
    scheduler.timeOrders = Utils.makeDefaultRules();
    var schedulerGenerate = scheduler.generateScheduler();

    var expectedScheduler = List.empty(growable: true);
    var next = ShiftTime.AFTERNOON;
    var iterate = start;
    var afterNight = false;
    while (end.difference(iterate).inDays >= 0) {
      expectedScheduler.add(Shift(iterate, next));
      iterate = iterate.add(Duration(days: 1));
      if (afterNight) {
        afterNight = false;
        continue;
      }
      switch (next) {
        case ShiftTime.AFTERNOON:
          next = ShiftTime.MORNING;
          break;
        case ShiftTime.MORNING:
          next = ShiftTime.NIGHT;
          break;
        case ShiftTime.NIGHT:
          next = ShiftTime.FREE;
          afterNight = true;
          break;
        case ShiftTime.FREE:
          next = ShiftTime.AFTERNOON;
          break;
      }
    }
    expect(expectedScheduler, equals(schedulerGenerate));
  });

  test("TestCustomSchedulerPassOne", () {
    var start = DateTime.now();
    var end = start.add(Duration(days: 2));

    var scheduler = ShiftScheduler(-1, start, end);
    scheduler.timeOrders = Utils.makeCustomRules();
    var validation = Utils.checkListShiftWithRules(
        scheduler.generateScheduler(), Utils.makeCustomRules());
    expect(validation, true);
  });

  test("TestCustomSchedulerSuccessTwo", () {
    var start = DateTime.now();
    var end = start.add(Duration(days: 200));

    var scheduler = ShiftScheduler(-1, start, end);
    scheduler.timeOrders = Utils.makeCustomRules();
    var validation = Utils.checkListShiftWithRules(
        scheduler.generateScheduler(), Utils.makeCustomRules());
    expect(validation, true);
  });

  test("TestCustomSchedulerFailOne", () {
    var start = DateTime.now();
    var end = start.add(Duration(days: 200));

    var scheduler = ShiftScheduler(-1, start, end);
    scheduler.timeOrders = Utils.makeCustomRules();
    var validation = Utils.checkListShiftWithRules(
        scheduler.generateScheduler(), Utils.makeDefaultRules());
    expect(validation, false);
  });
}
