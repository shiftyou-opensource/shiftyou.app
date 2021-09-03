import 'package:intl/intl.dart';

enum ShiftTime {
  MORNING,
  AFTERNOON,
  NIGHT,
  FREE,
}

/// @author https://github.com/vincenzopalazzo
class Shift {
  DateTime _date;
  ShiftTime _time;
  bool _done = false;

  DateTime get date {
    return this._date;
  }

  ShiftTime get time {
    return this._time;
  }

  set time(ShiftTime shiftTime) {
    this._time = shiftTime;
  }

  bool get done => _done;

  set done(bool value) {
    this._done = value;
  }

  Shift(this._date, this._time);

  void fromShift(Shift shift) {
    this._date = shift.date;
    this._time = shift.time;
    this._done = shift.done;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shift &&
          runtimeType == other.runtimeType &&
          _date == other._date &&
          _time == other._time;

  @override
  int get hashCode => _date.hashCode ^ _time.hashCode;

  String formatString() => DateFormat.yMEd().format(_date);

  @override
  String toString() {
    return '${DateFormat.yMEd().format(_date)}: in $_time is done: $_done}';
  }
}
