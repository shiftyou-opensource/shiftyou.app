import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/utils/converter.dart';

class SchedulerRules {
  // Name of the scheduler that we add to it
  String _name;
  // The list of time orders is fixed.
  // This doesn't grown in the time
  bool _static;
  // the shift orders selected by the user.
  late List<ShiftTime> _timeOrders;
  // The user selected the manual mode, this means
  // the the list of ShiftTime is ignored
  bool manual;

  SchedulerRules(this._name, this._static, {this.manual = false}) {
    _timeOrders = List.empty(growable: true);
  }

  get name => _name;

  get static => _static;

  List<ShiftTime> get timeOrders => _timeOrders;

  set timeOrders(List<ShiftTime> timeOrders) => this._timeOrders = timeOrders;

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
