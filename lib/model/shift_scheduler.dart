import 'package:nurse_time/model/shift.dart';

/// @author https://github.com/vincenzopalazzo
class ShiftScheduler {
  late DateTime _start;
  late DateTime _end;
  late ShiftTime _startWith;
  late List<Shift> _exceptions;

  set start(DateTime dateTime) {
    this._start = dateTime;
  }

  set end(DateTime dateTime) {
    this._end = dateTime;
  }

  set startWith(ShiftTime startWith) {
    this._startWith = startWith;
  }

  ShiftScheduler(this._start, this._end) {
    this._exceptions = List.empty(growable: true);
    this._startWith = ShiftTime.MORNING;
  }

  void addException(Shift shift) {
    this._exceptions.add(shift);
  }

  List<Shift> generateScheduler() {
    List<Shift> generation = List.empty(growable: true);
    var iterate = _start;
    var next = ShiftTime.AFTERNOON;
    while (_end.difference(iterate).inDays >= 0) {
      generation.add(Shift(iterate, next));
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
    return generation;
  }
}
