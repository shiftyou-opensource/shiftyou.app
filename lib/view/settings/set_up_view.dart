import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_timeline/indicator_position.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_timeline/flutter_timeline.dart';
import 'package:nurse_time/view/settings/done_configuration_step.dart';
import 'package:nurse_time/view/settings/generation_method_step.dart';
import 'package:nurse_time/view/settings/optional_view_step.dart';
import 'package:nurse_time/view/settings/period_view_step.dart';

class SetUpView extends StatefulWidget {
  final bool ownView;

  SetUpView({this.ownView = true});

  @override
  State<StatefulWidget> createState() => _SetUpView();
}

class _SetUpView extends State<SetUpView> {
  late ShiftScheduler _shiftScheduler;
  late UserModel _userModel;
  late List<SchedulerRules> _schedulerRules;
  late List<ShiftTime> _shiftTimePicker;
  int _selectedRules = 0;
  ShiftTime? _startWith;
  late DateTimeRange _range;

  _SetUpView() {
    this._startWith = ShiftTime.MORNING;
    this._shiftScheduler = GetIt.instance.get<ShiftScheduler>();
    this._userModel = GetIt.instance.get<UserModel>();
    this._range = DateTimeRange(
        start: this._shiftScheduler.start, end: _shiftScheduler.end);
    // TODO, put it inside the getit?
    this._schedulerRules = List.empty(growable: true);
    var defaultRules = SchedulerRules("Default", true);
    defaultRules.addTime(ShiftTime.AFTERNOON);
    defaultRules.addTime(ShiftTime.MORNING);
    defaultRules.addTime(ShiftTime.NIGHT);
    defaultRules.addTime(ShiftTime.FREE);
    defaultRules.addTime(ShiftTime.FREE);
    this._schedulerRules.add(defaultRules);
    var custom = SchedulerRules("Custom (You will choose)", false);
    this._schedulerRules.add(custom);
    var manual = SchedulerRules("Manual", false);
    manual.manual = true;
    this._schedulerRules.add(manual);

    if (this._shiftScheduler.isDefault())
      this._selectedRules = 0;
    else if (this._shiftScheduler.isManual()) {
      this._selectedRules = 2;
      this._schedulerRules[this._selectedRules].timeOrders =
          this._shiftScheduler.timeOrders;
    } else if (this._shiftScheduler.isCustom()) {
      this._selectedRules = 1;
      this._schedulerRules[this._selectedRules].timeOrders =
          this._shiftScheduler.timeOrders;
    }

    // TODO: Set up the UI with the actual state of the application.
    _shiftTimePicker = List.from([
      ShiftTime.MORNING,
      ShiftTime.AFTERNOON,
      ShiftTime.NIGHT,
      ShiftTime.FREE
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ownView) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("Setting Scheduler"),
          centerTitle: true,
          leading: Container(),
        ),
        body: SafeArea(child: makeBody(context)),
      );
    } else {
      return makeBody(context);
    }
  }

  Widget makeBody(BuildContext context) {
    return makeScrollView(
      context,
      [
        Column(
          children: [
            Container(
              color: Theme.of(context).backgroundColor,
              child: Center(
                heightFactor: 1,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).buttonColor,
                  radius: 60.0,
                  child: CircleAvatar(
                    radius: 50.0,
                    child: Image.asset("assets/ic_launcher.png"),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            Text("Hey ${this._userModel.name.split(" ")[0]}",
                style: TextStyle(fontSize: 25)),
            _buildTimeline(context),
          ],
        )
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return TimelineTheme(
        data: TimelineThemeData(
            lineColor: Theme.of(context).textTheme.bodyText1!.color!,
            itemGap: 20,
            lineGap: 20),
        child: Timeline(
          anchor: IndicatorPosition.center,
          indicatorSize: 30,
          altOffset: Offset(10, 10),
          events: [
            PeriodViewStep(Text("Select the shift period"),
                    shiftScheduler: _shiftScheduler,
                    onSave: (timeRange) => setState(() => _range = timeRange))
                .build(context),
            GenerationMethodStep(
              Text("Set how generate the week shift"),
              (value) => setState(() => _selectedRules = value!),
              _selectedRules,
              _schedulerRules,
            ).build(context),
            OptionViewStep(
                    Text("Somethings random"),
                    _schedulerRules,
                    _selectedRules,
                    (index) => setState(
                        () => _schedulerRules[_selectedRules].removed(index)),
                    _shiftTimePicker,
                    (time) => setState(
                        () => _schedulerRules[_selectedRules].addTime(time)))
                .build(context),
            DoneConfigurationView(Text("Your configuration it is finished."),
                    startWith: _startWith,
                    shiftScheduler: _shiftScheduler,
                    userModel: _userModel,
                    range: _range,
                    shiftTimePicker: _schedulerRules[_selectedRules].timeOrders,
                    manual: _schedulerRules[_selectedRules].manual)
                .build(context),
          ],
        ));
  }
}
