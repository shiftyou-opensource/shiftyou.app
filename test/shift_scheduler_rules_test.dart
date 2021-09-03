import 'package:flutter_test/flutter_test.dart';
import 'package:nurse_time/model/shift_scheduler.dart';

import 'utils/utils.dart';

/// @author https://github.com/vincenzopalazzo
void main() {
  test('TestShiftSchedulerRulesOne', () {
    var start = DateTime.now();
    var end = start.add(Duration(days: 200));
    var scheduler = ShiftScheduler(-1, start, end);
    scheduler.timeOrders = Utils.makeCustomRules();

    expect(false, scheduler.isManual());
    expect(true, scheduler.isCustom());
  });

  test('TestShiftSchedulerRulesOne', () {
    var start = DateTime.now();
    var end = start.add(Duration(days: 200));
    var scheduler = ShiftScheduler(-1, start, end);
    scheduler.timeOrders = Utils.makeCustomRules();
    scheduler.manual = true;

    expect(true, scheduler.isManual());
    expect(false, scheduler.isCustom());
  });
}
