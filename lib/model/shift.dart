import 'package:intl/intl.dart';

/// @author https://github.com/vincenzopalazzo

enum ShiftTime {
  MORNING,
  AFTERNOON,
  NIGHT,
  FREE,
}

class Shift {
  DateTime _date;
  ShiftTime _time;

  DateTime get date {
    return this._date;
  }

  ShiftTime get time {
    return this._time;
  }

  set time(ShiftTime shiftTime) {
    this._time = shiftTime;
  }

  Shift(this._date, this._time);

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
    return '${DateFormat.yMEd().format(_date)}: in $_time}';
  }
}
