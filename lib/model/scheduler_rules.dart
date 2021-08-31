import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/utils/converter.dart';

class SchedulerRules {
  String _name;
  bool _static;
  late List<ShiftTime> _timeOrders;

  SchedulerRules(this._name, this._static) {
    _timeOrders = List.empty(growable: true);
  }

  get name => _name;

  get static => _static;

  get timeOrders => _timeOrders;

  void addTime(ShiftTime time) => _timeOrders.add(time);

  int size() => _timeOrders.length;

  ShiftTime shiftAt(int index) => _timeOrders[index];

  String shiftAtStr(int index) =>
      Converter.fromShiftTimeToString(this.shiftAt(index));

  void removed(int index) {
    if (_static)
      throw Exception("You can not remove nothings in a static scheduler");
    _timeOrders.removeAt(index);
  }

  @override
  String toString() {
    return '$_name: $_timeOrders}';
  }
}
