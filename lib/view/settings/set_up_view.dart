import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_timeline/indicator_position.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_timeline/flutter_timeline.dart';
import 'package:nurse_time/view/home/home_view.dart';
import 'package:nurse_time/view/settings/generation_method_step.dart';
import 'package:nurse_time/view/settings/optional_view_step.dart';
import 'package:nurse_time/view/settings/period_view_step.dart';

class SetUpView extends StatefulWidget {
  final bool ownView;
  final ShiftScheduler? shiftScheduler;
  final DateTimeRange? range;
  final Function(int) onUpdate;
  final List<SchedulerRules> schedulerRules;

  SetUpView(
      {required this.onUpdate,
      this.ownView = true,
      this.shiftScheduler,
      this.range,
      required this.schedulerRules});

  @override
  State<StatefulWidget> createState() => _SetUpView();
}

class _SetUpView extends State<SetUpView> {
  late ShiftScheduler _shiftScheduler;
  late UserModel _userModel;
  late AbstractDAO _dao;
  late List<ShiftTime> _shiftTimePicker;
  int _selectedRules = 0;

  _SetUpView() {
    this._userModel = GetIt.instance.get<UserModel>();
    this._dao = GetIt.instance<DAODatabase>();

    _shiftTimePicker = List.from([
      ShiftTime.MORNING,
      ShiftTime.AFTERNOON,
      ShiftTime.NIGHT,
      ShiftTime.STOP_WORK,
      ShiftTime.FREE
    ]);
  }

  @override
  void initState() {
    super.initState();
    if (widget.shiftScheduler == null) {
      this._shiftScheduler = GetIt.instance.get<ShiftScheduler>();
    } else
      this._shiftScheduler = widget.shiftScheduler!;

    if (this._shiftScheduler.isManual()) {
      this._selectedRules = 1;
      widget.schedulerRules[this._selectedRules].timeOrders =
          this._shiftScheduler.timeOrders;
    } else if (this._shiftScheduler.isCustom()) {
      this._selectedRules = 0;
      widget.schedulerRules[this._selectedRules].timeOrders =
          this._shiftScheduler.timeOrders;
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkFinishSetup();
  }

  void checkFinishSetup() {}

  @override
  Widget build(BuildContext context) {
    if (widget.ownView) {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => {
            setState(() {
              _shiftScheduler.userId = this._userModel.id;
              _shiftScheduler.timeOrders =
                  widget.schedulerRules[_selectedRules].timeOrders;
              _shiftScheduler.manual =
                  widget.schedulerRules[_selectedRules].manual;
              _shiftScheduler.cleanException().notify();
              _dao.insertShift(_shiftScheduler);
            }),
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return HomeView();
            }))
          },
          icon: Icon(Icons.done),
          backgroundColor: Theme.of(context).accentColor,
          foregroundColor: Theme.of(context).primaryColor,
          elevation: 5,
          label: Text("Save"),
        ),
        appBar: AppBar(
          elevation: 0,
          title: const Text("Setting Scheduler"),
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
                style: TextStyle(fontSize: 18)),
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
            PeriodViewStep(Text("Select the shift period", style: Theme.of(context).textTheme.bodyText1!.apply(fontSizeFactor: 1.4)),
                    shiftScheduler: _shiftScheduler,
                    onSave: (timeRange) => setState(
                        () => _shiftScheduler.updateRangeFromRange(timeRange)))
                .build(context),
            GenerationMethodStep(
              Text("Set how generate the week shift", style: Theme.of(context).textTheme.bodyText1!.apply(fontSizeFactor: 1.4)),
              (value) => setState(() {
                _selectedRules = value!;
                widget.onUpdate(_selectedRules);
              }),
              _selectedRules,
              widget.schedulerRules,
            ).build(context),
            OptionViewStep(
                Text("Select Your Week Cadency", style: Theme.of(context).textTheme.bodyText1!.apply(fontSizeFactor: 1.4)),
                widget.schedulerRules,
                _selectedRules,
                (index) => setState(
                    () => widget.schedulerRules[_selectedRules].removed(index)),
                _shiftTimePicker,
                (time) => setState(() => widget.schedulerRules[_selectedRules]
                    .addTime(time))).build(context),
          ],
        ));
  }
}
