import 'package:intl/intl.dart';
import 'package:nurse_time/utils/converter.dart';

enum ShiftTime {
  MORNING,
  AFTERNOON,
  NIGHT,
  FREE,
}

/// @author https://github.com/vincenzopalazzo
class Shift {
  // Used to make the mapping with the database
  int _id = -1;
  // The user id used to make the mapping with the database
  int _userId = -1;
  DateTime _date;
  ShiftTime _time;
  bool _done = false;

  static Shift fromDatabase(Map<String, dynamic> element) {
    ShiftTime time = Converter.fromIntToShiftTime(element["shift"]);
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(element["day_timestamp"]);
    var shift = Shift(date, time);
    shift.done = element["done"] == 0 ? false : true;
    return shift;
  }

  Shift(this._date, this._time);

  DateTime get date {
    return this._date;
  }

  ShiftTime get time {
    return this._time;
  }

  int get userId => this._userId;

  set userId(int id) => this._userId = id;

  set time(ShiftTime shiftTime) {
    this._time = shiftTime;
  }

  bool get done => _done;

  set done(bool value) {
    this._done = value;
  }

  void fromShift(Shift shift) {
    this._date = shift.date;
    this._time = shift.time;
    this._done = shift.done;
  }

  Map<String, dynamic> toMap() => {
        if (_id != -1) "id": _id,
        if (_userId != -1) "user_id": _userId,
        "day_timestamp": date.millisecondsSinceEpoch,
        "shift": Converter.fromShiftTimeToIndex(_time),
        "done": _done ? 1 : 0,
      };

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
