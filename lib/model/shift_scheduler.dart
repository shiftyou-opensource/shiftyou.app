import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/utils/converter.dart';

/// @author https://github.com/vincenzopalazzo
class ShiftScheduler {
  late int _id;

  // used to store the user id inside the db
  late int _userId;
  late DateTime _start;
  late DateTime _end;
  late Logger _logger;

  // The map of exception, during the life we have several
  // exception to manage, and this is the place where the app
  // will store yours exceptions.
  // We use the map to speedup the algorithm to generate the exceptions.
  late Map<String, Shift> _exceptions;

  // The list of period cadence od shift time, with this list of enums
  // we can autogenerate the period without storing a lot of information
  // inside the database.
  late List<ShiftTime> _timeOrders;

  // The orders of shift is manual, with this choice we need to make
  // a change of decision when we need to sink on firebase.
  bool _manual = false;

  // The list of shift sorted in the time order by shift date
  // in addition, only this class know when and how generate
  // the shift from app event
  late List<Shift> _shifts;

  // Store the information about the rules chosen to calculate the
  // shift, in this way we can avoid to punt different object around
  late SchedulerRules _rules;

  // TODO: Move this list of parameters to a accept a single map of params.
  static ShiftScheduler fromDatabase(
      {required int id,
      required int timeStart,
      required int timeEnd,
      required String schedulerRules,
      required bool manual,
      int userId = -1}) {
    var shift = ShiftScheduler(
        userId,
        DateTime.fromMillisecondsSinceEpoch(timeStart),
        DateTime.fromMillisecondsSinceEpoch(timeEnd));
    shift._id = id;
    Logger _logger = GetIt.instance<Logger>();
    _logger.d("ShiftScheduler in DB with id ${shift._id}");
    List<ShiftTime> timeOrder = List.empty(growable: true);
    if (schedulerRules.trim().isNotEmpty) {
      var tokens = schedulerRules.split(";");
      for (var index = 0; index < tokens.length; index++) {
        var token = tokens[index];
        timeOrder.add(Converter.fromIntToShiftTime(int.parse(token)));
      }
    }
    shift.timeOrders = timeOrder;
    shift.manual = manual;
    shift._generateSchedulerRule();
    shift._generateScheduler(complete: false);
    return shift;
  }

  ShiftScheduler(this._userId, this._start, this._end) {
    this._logger = GetIt.instance<Logger>();
    this._id = -1;
    this._exceptions = Map();
    // Default period
    this._timeOrders = List.empty(growable: true);
    this._shifts = List.empty(growable: true);
    this._rules = SchedulerRules(
        this._manual ? "Up to you" : "Weekly Cadence", false,
        manual: this._manual);
    this._rules.timeOrders = this._timeOrders;
    if (this.start != this.end) this._generateScheduler(complete: false);
  }

  List<ShiftTime> get timeOrders => this._timeOrders;

  List<Shift> getExceptions() {
    return this._exceptions.values.toList(growable: true);
  }

  bool get manual => _manual;

  int get id => _id;

  set id(int newId) => this._id = newId;

  DateTime get end => _end;

  DateTime get start => _start;

  List<Shift> get shifts => this._shifts;

  set userId(int userID) {
    this._userId = userID;
  }

  set start(DateTime dateTime) {
    this._start = dateTime;
  }

  set end(DateTime dateTime) {
    this._end = dateTime;
  }

  bool isOwner(UserModel user) {
    return user.id == _userId;
  }

  @override
  String toString() {
    return 'ShiftScheduler{_id: $_id, _userId: $_userId, _start: $_start, _end: $_end}';
  }

  void setExceptions(List<Shift> exceptions) {
    this._exceptions.clear();
    exceptions.forEach((element) {
      this.addException(element, ignoreUpdate: true);
    });
    this.notify();
  }

  set timeOrders(List<ShiftTime> rules) => this._timeOrders = rules;

  set manual(bool manual) => this._manual = manual;

  set rules(SchedulerRules rules) {
    this._rules = rules;
    this._manual = rules.manual;
    this.timeOrders = rules.timeOrders;
  }

  ShiftScheduler addException(Shift shift,
      {bool ignoreUpdate = false, bool complete = false}) {
    this._exceptions[toDateKey(shift.date)] = shift;
    if (!ignoreUpdate) {
      this._generateScheduler(complete: complete);
    }
    return this;
  }

  void updateShiftAt(int index, Shift shift, {bool isException = false}) {
    //TODO for the moment we avoid to modify the date.
    if (isException) this._exceptions[toDateKey(shift.date)] = shift;
  }

  void _generateSchedulerRule() {
    this._rules = SchedulerRules(
        this._manual ? "Up to you" : "Weekly Cadence", false,
        manual: this._manual);
    this._rules.timeOrders = this._timeOrders;
  }

  DateTimeRange range() => DateTimeRange(start: _start, end: _end);

  void updateRange(DateTime start, DateTime end) {
    this._start = start;
    this._end = end;
  }

  void updateRangeFromRange(DateTimeRange range) {
    this._start = range.start;
    this._end = range.end;
  }

  String toDateKey(DateTime time) {
    return "${time.day}/${time.month}/${time.year}";
  }

  Map<String, dynamic> toMap({bool update = false}) {
    var stringSchedulerRules = StringBuffer();
    for (var index = 0; index < _timeOrders.length; index++) {
      var shiftTime = _timeOrders[index];
      stringSchedulerRules.write(Converter.fromShiftTimeToIndex(shiftTime));
      if (index != _timeOrders.length - 1) {
        stringSchedulerRules.write(";");
      }
    }
    return {
      if (_id != -1 && !update) "id": _id,
      if (_userId != -1 && !update) "user_id": _userId,
      "start": _start.millisecondsSinceEpoch,
      "end": _end.millisecondsSinceEpoch,
      "scheduler_rules": stringSchedulerRules.toString(),
      "manual": _manual == false ? 0 : 1,
    };
  }

  ShiftScheduler fromShift(ShiftScheduler shift) {
    this._userId = shift._userId;
    this._id = shift._id;
    this._start = shift._start;
    this._end = shift._end;
    this._timeOrders = shift._timeOrders;
    this.manual = shift._manual;
    this._shifts = shift._shifts;
    this._exceptions = shift._exceptions;
    this._generateScheduler();
    this._generateSchedulerRule();
    return this;
  }

  // Method to generate for the public the scheduler, with option to have
  // a complete or a list of remains shift to do.
  List<Shift> generateScheduler({bool complete = true}) {
    List<Shift> generation = List.empty(growable: true);
    if (_timeOrders.isEmpty) {
      var now = DateTime.now();
      if (_exceptions.isNotEmpty) {
        // Filter the exception in this place,
        // we need to remove from the exception the past exception
        if (complete) {
          generation.addAll(_exceptions.values);
        } else {
          generation.addAll(_exceptions.values
              .where((element) => element.date.difference(now).inDays >= 0));
        }
      }
      generation.sort((a, b) => a.date.compareTo(b.date));
      return generation;
    }
    Map<String, Shift> cloneException = Map();
    cloneException.addAll(_exceptions);
    var indexStart = 0;
    var indexMax = _timeOrders.length - 1;
    var iterate = _start;
    var next = _timeOrders[indexStart];
    var afterNight = false;
    var now = DateTime.now();
    while (_end.difference(iterate).inMinutes >= 0) {
      var shift = Shift(iterate, next);
      if (cloneException.containsKey(toDateKey(iterate))) {
        _logger.d("Contains exceptions");
        shift = cloneException.remove(toDateKey(iterate))!;
      }

      if (iterate.difference(now).inDays < 0) shift.done = true;
      iterate = iterate.add(Duration(days: 1));
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
      // Jump the shift already done, but keep the
      // scheduler logic safe.
      // This give the possibility to fix the following issue
      // https://github.com/shiftyou-opensource/shiftyou.app/issues/73
      if (!complete && shift.done) continue;
      generation.add(shift);
    }

    cloneException.values.forEach((element) {
      if (iterate.difference(now).inDays < 0) element.done = true;
      if (complete || (!complete && !element.done)) {
        generation.add(element);
      }
    });

    generation.sort((a, b) => a.date.compareTo(b.date));
    return generation;
  }

  void _generateScheduler({bool complete = true}) {
    this._shifts = this.generateScheduler(complete: complete);
  }

  ShiftScheduler notify() {
    this._generateScheduler(complete: false);
    return this;
  }

  /// clean the exception stored inside the db, however
  /// after this call we need to call the method notify.
  ShiftScheduler cleanException() {
    this._exceptions.clear();
    return this;
  }

// Method to check if the scheduler policy is on the manual mode
  bool isCustom() {
    return !this.isManual();
  }

// deprecated: The application use the custom setting to avoid
// confusion between person
  @deprecated
  bool isDefault() {
    List<ShiftTime> list = List.empty(growable: true);
    list.add(ShiftTime.AFTERNOON);
    list.add(ShiftTime.MORNING);
    list.add(ShiftTime.NIGHT);
    list.add(ShiftTime.FREE);
    list.add(ShiftTime.FREE);
    if (list.length != _timeOrders.length) return false;
    for (var index = 0; index < list.length; index++) {
      if (list[index] != _timeOrders[index]) return false;
    }
    return true;
  }

  bool isManual() {
    return this._manual;
  }
}
