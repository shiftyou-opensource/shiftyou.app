import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
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
  // The Shift Scheduler id of the database,
  // this is useful to manage the update and remove
  // and remove on the db.
  int _shiftId = -1;
  // The day of the shift.
  DateTime _date;
  // The shift time of the shift, that can be
  // MORNING, AFTERNOON, NIGHT, FREE
  ShiftTime _time;
  // The shift it is done (finished), this is useful
  // when we need to generate the shift to make some report.
  bool _done = false;

  static Shift fromDatabase(Map<String, dynamic> element) {
    var logger = Logger();
    logger.d("Information from the database are ${element.toString()}");
    ShiftTime time = Converter.fromIntToShiftTime(element["shift"]);
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(element["day_timestamp"]);
    var shift = Shift(date, time);
    shift.done = element["done"] == 0 ? false : true;
    if (element.containsKey("shift_id"))
      shift.shiftId = element["shift_id"] == null ? 1 : element["shift_id"];
    return shift;
  }

  Shift(this._date, this._time);

  DateTime get date {
    return this._date;
  }

  ShiftTime get time {
    return this._time;
  }

  int get shiftId => this._shiftId;

  int get id => this._id;

  set id(int newId) => this._id = newId;

  set shiftId(int id) => this._shiftId = id;

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

  Map<String, dynamic> toMap({bool update = false}) => {
        if (_id != -1 && !update) "id": _id,
        if (_shiftId != -1 && !update) "shift_id": _shiftId,
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
          _time == other._time &&
          _shiftId == other._shiftId;

  @override
  int get hashCode => _date.hashCode ^ _time.hashCode;

  String formatString() => DateFormat.yMEd().format(_date);

  @override
  String toString() {
    return '${DateFormat.yMEd().format(_date)}: in $_time is done: $_done}';
  }
}
