import 'package:flutter/material.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:get_it/get_it.dart';
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

    // FIXME: The manual mode it is not longer available
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
              _shiftScheduler.userId = this._userModel.id!;
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 5,
          label: Text(AppLocalization.getWithKey(Keys.Words_Word_Save)),
        ),
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          title:
              Text(AppLocalization.getWithKey(Keys.Titles_Setting_Scheduler)),
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
            makeIconProfile(
                context: context, image: Image.asset("assets/ic_launcher.png")),
            Text("Hey ${this._userModel.name.split(" ")[0]}",
                style: TextStyle(fontSize: 18)),
            _buildTimeline(context),
          ],
        )
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(children: [
      Container(
          margin: EdgeInsets.all(14),
          child: PeriodViewStep(
              Text(AppLocalization.getWithKey(Keys.Settings_Steps_Select_Date),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .apply(fontSizeFactor: 1.4)),
              shiftScheduler: _shiftScheduler,
              onSave: (timeRange) => setState(
                  () => _shiftScheduler.updateRangeFromRange(timeRange))).build(
              context)),
      Container(
          margin: EdgeInsets.all(14),
          child: GenerationMethodStep(
            Text(
                AppLocalization.getWithKey(Keys.Settings_Steps_Generate_Method),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .apply(fontSizeFactor: 1.4)),
            (value) => setState(() {
              _selectedRules = value!;
              widget.onUpdate(_selectedRules);
            }),
            _selectedRules,
            widget.schedulerRules,
          ).build(context)),
      Container(
        margin: EdgeInsets.all(14),
        child: OptionViewStep(
                Text(AppLocalization.getWithKey(Keys.Settings_Steps_Cadency),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .apply(fontSizeFactor: 1.4)),
                widget.schedulerRules,
                _selectedRules,
                (index) => setState(
                    () => widget.schedulerRules[_selectedRules].removed(index)),
                _shiftTimePicker,
                (time) => setState(
                    () => widget.schedulerRules[_selectedRules].addTime(time)))
            .build(context),
      )
    ]);
  }
}
