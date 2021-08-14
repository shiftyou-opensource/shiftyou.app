import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/utils/converter.dart';

/// @author https://github.com/vincenzopalazzo
class ShiftScheduler {
  late int _id;
  late int _userId; // TODO: Use to make dependences in the database
  late DateTime _start;
  late DateTime _end;
  late ShiftTime _startWith;
  late List<Shift> _exceptions;

  static ShiftScheduler fromDatabase(
      int id, int timeStart, int timeEnd, int startWithIndex) {
    var shift = ShiftScheduler(
        -1,
        DateTime.fromMillisecondsSinceEpoch(timeStart),
        DateTime.fromMillisecondsSinceEpoch(timeEnd));
    shift._id = id;
    shift._startWith = Converter.fromIntToShiftTime(startWithIndex);
    return shift;
  }

  set userId(int userID) {
    this._userId = userID;
  }

  set start(DateTime dateTime) {
    this._start = dateTime;
  }

  set end(DateTime dateTime) {
    this._end = dateTime;
  }

  set startWith(ShiftTime startWith) {
    this._startWith = startWith;
  }

  ShiftScheduler(this._userId, this._start, this._end) {
    this._id = -1;
    this._exceptions = List.empty(growable: true);
    this._startWith = ShiftTime.MORNING;
  }

  void addException(Shift shift) {
    this._exceptions.add(shift);
  }

  //TODO(vincenzopalazzo) Adding exception to the serialization
  Map<String, dynamic> toMap() {
    return {
      if (_id != -1) "id": _id,
      "user_id": _userId,
      "start": _start.millisecondsSinceEpoch,
      "end": _end.millisecondsSinceEpoch,
      "start_with": Converter.fromShiftTimeToIndex(_startWith)
    };
  }

  void fromShift(ShiftScheduler shift) {
    this._userId = shift._userId;
    this._id = shift._id;
    this._start = shift._start;
    this._end = shift._end;
    this._startWith = shift._startWith;
  }

  List<Shift> generateScheduler() {
    List<Shift> generation = List.empty(growable: true);
    var iterate = _start;
    var next = this._startWith;
    var afterNight = false;
    while (_end.difference(iterate).inDays >= 0) {
      generation.add(Shift(iterate, next));
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
    return generation;
  }
}
