import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/utils/converter.dart';

/// @author https://github.com/vincenzopalazzo
class ShiftScheduler {
  late int _id;
  late int _userId; // TODO: Use to make dependences in the database
  late DateTime _start;
  late DateTime _end;
  // Deprecated, with the new system we can autogenerate the scheduler
  // form the list of recurrences.
  late List<Shift> _exceptions;
  late Logger logger;
  late List<ShiftTime> _timeOrders;

  DateTime get end => _end;
  DateTime get start => _start;

  static ShiftScheduler fromDatabase(
      int id, int timeStart, int timeEnd, String schedulerRules) {
    var shift = ShiftScheduler(
        -1,
        DateTime.fromMillisecondsSinceEpoch(timeStart),
        DateTime.fromMillisecondsSinceEpoch(timeEnd));
    shift._id = id;
    List<ShiftTime> timeOrder = List.empty(growable: true);
    var tokens = schedulerRules.split(";");
    for (var index = 0; index < tokens.length; index++) {
      var token = tokens[index];
      timeOrder.add(Converter.fromIntToShiftTime(int.parse(token)));
    }
    print(timeOrder);
    shift.timeOrders = timeOrder;
    return shift;
  }

  ShiftScheduler(this._userId, this._start, this._end) {
    this._id = -1;
    this._exceptions = List.empty(growable: true);
    // Default period
    this._timeOrders = List.empty(growable: true);
    _timeOrders.add(ShiftTime.AFTERNOON);
    _timeOrders.add(ShiftTime.MORNING);
    _timeOrders.add(ShiftTime.NIGHT);
    _timeOrders.add(ShiftTime.FREE);
    _timeOrders.add(ShiftTime.FREE);
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

  set timeOrders(List<ShiftTime> rules) => this._timeOrders = rules;

  void addException(Shift shift) {
    this._exceptions.add(shift);
  }

  //TODO(vincenzopalazzo) Adding exception to the serialization
  Map<String, dynamic> toMap() {
    var stringSchedulerRules = StringBuffer();
    for (var index = 0; index < _timeOrders.length; index++) {
      var shiftTime = _timeOrders[index];
      stringSchedulerRules.write(Converter.fromShiftTimeToIndex(shiftTime));
      if (index != _timeOrders.length - 1) {
        stringSchedulerRules.write(";");
      }
    }
    return {
      if (_id != -1) "id": _id,
      "user_id": _userId,
      "start": _start.millisecondsSinceEpoch,
      "end": _end.millisecondsSinceEpoch,
      "scheduler_rules": stringSchedulerRules.toString(),
    };
  }

  void fromShift(ShiftScheduler shift) {
    this._userId = shift._userId;
    this._id = shift._id;
    this._start = shift._start;
    this._end = shift._end;
    this._timeOrders = shift._timeOrders;
  }

  List<Shift> generateScheduler({bool complete = true}) {
    List<Shift> generation = List.empty(growable: true);
    var indexStart = 0;
    var indexMax = _timeOrders.length - 1;
    var iterate = _start;
    var next = _timeOrders[indexStart];
    var afterNight = false;
    var now = DateTime.now();
    while (_end.difference(iterate).inDays >= 0) {
      var shift = Shift(iterate, next);
      if (iterate.difference(now).inDays < 0) shift.done = true;
      iterate = iterate.add(Duration(days: 1));
      // Jump the shift already done.
      if (!complete && shift.done) continue;
      generation.add(shift);
      if (afterNight) {
        afterNight = false;
        continue;
      }
      indexStart++;
      if (indexStart <= indexMax) {
        next = _timeOrders[indexStart];
      } else {
        indexStart = 0;
        next = _timeOrders[indexStart];
      }
    }
    return generation;
  }
}
