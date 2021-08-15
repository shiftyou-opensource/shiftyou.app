import 'package:flutter/material.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:flutter/painting.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/utils/converter.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/home/home_view.dart';
import 'package:get_it/get_it.dart';

class SetUpView extends StatefulWidget {
  final bool ownView;

  SetUpView({this.ownView = true});

  @override
  State<StatefulWidget> createState() => _SetUpView();
}

class _SetUpView extends State<SetUpView> {
  late ShiftScheduler _shiftScheduler;
  late UserModel _userModel;
  late DAODatabase _dao;
  late Logger _logger;
  late List<SchedulerRules> _schedulerRules;
  late List<ShiftTime> _shiftTimePicker;
  int _selectedRules = 0;
  ShiftTime? _startWith;

  _SetUpView() {
    this._startWith = ShiftTime.MORNING;
    this._shiftScheduler = GetIt.instance.get<ShiftScheduler>();
    this._userModel = GetIt.instance.get<UserModel>();
    this._logger = GetIt.instance.get<Logger>();
    this._dao = GetIt.instance.get<DAODatabase>();
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
    this._schedulerRules.add(manual);
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
          title: Text(widget.ownView ? "Setting Scheduler" : ""),
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
            _settingProprieties(context),
            makeTitleDivider("Set how generate the week shift"),
            _makeRadioButtonView(context),
            makeConcealableComponent(
                makeTitleDivider("Adding your shift time with one click"),
                !_schedulerRules[_selectedRules].static,
                disappear: true),
            makeConcealableComponent(_makeShiftTimePicker(context),
                !_schedulerRules[_selectedRules].static,
                disappear: true),
            makeConcealableComponent(
                makeTitleDivider("Shift order: How your shift looks like"),
                _schedulerRules[_selectedRules].size() != 0,
                disappear: true),
            _makeChipsArea(context),
          ],
        )
      ],
    );
  }

  Widget _makeRadioButtonView(BuildContext context) {
    return Column(
        children: List<RadioListTile>.generate(
            _schedulerRules.length,
            (index) => RadioListTile(
                  title: makeRadioTitle(context, _schedulerRules[index].name,
                      index == _selectedRules),
                  value: index,
                  groupValue: _selectedRules,
                  onChanged: (value) => setState(() => _selectedRules = value!),
                )));
  }

  void removeChipAt(BuildContext context, int index) {
    try {
      setState(() => _schedulerRules[_selectedRules].removed(index));
    } on Exception catch (ex) {
      _logger.e(ex);
      showSnackBar(context, "You can't remove this shift");
    }
  }

  Widget _makeChipsArea(BuildContext context) {
    return makeConcealableComponent(
        Container(
            decoration: BoxDecoration(
                color: Theme.of(context).buttonColor,
                border: Border.all(
                  color: Theme.of(context).buttonColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            padding: EdgeInsets.all(4),
            child: Wrap(
              children: List<Chip>.generate(
                  _schedulerRules[_selectedRules].size(),
                  (index) => Chip(
                      backgroundColor: Theme.of(context).cardColor,
                      deleteButtonTooltipMessage: "Remove Shift time",
                      deleteIcon: Icon(Icons.highlight_remove,
                          color: Theme.of(context).textTheme.bodyText1!.color),
                      autofocus: true,
                      onDeleted: () => removeChipAt(context, index),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      padding: EdgeInsets.all(2),
                      elevation: 0,
                      avatar: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Image(
                            image: AssetImage(
                                "assets/images/${Converter.fromShiftTimeToImage(_schedulerRules[_selectedRules].shiftAt(index))}")),
                      ),
                      label: Text(
                          _schedulerRules[_selectedRules].shiftAtStr(index)))),
            )),
        _schedulerRules[_selectedRules].size() != 0,
        disappear: true);
  }

  Widget _makeShiftTimePicker(BuildContext context) {
    return Column(
      children: List<ListTile>.generate(
        _shiftTimePicker.length,
        (index) => ListTile(
          title: Text(Converter.fromShiftTimeToString(_shiftTimePicker[index])),
        ),
      ),
    );
  }

  Widget _settingProprieties(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            DateRangeField(
                enabled: true,
                confirmText: "Select",
                decoration: InputDecoration(
                  labelText: 'Period',
                  prefixIcon: Icon(Icons.date_range,
                      color: Theme.of(context).textTheme.bodyText1!.color),
                  hintText: 'Please select a period of your shift',
                  border: OutlineInputBorder(),
                ),
                initialValue:
                    DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                validator: (value) {
                  if (value!.start.isBefore(DateTime.now())) {
                    return 'Please enter a valid date';
                  }
                  return null;
                },
                onChanged: (value) {
                  this._logger.d("On Change called");
                  this._logger.d("Value received from Data picker");
                  this._modalBottomSheetMenu(context, value!);
                },
                onSaved: (value) async {
                  //TODO: It is a library bug? it is not called
                  this._logger.d("onSaved: Value received from Data picker");
                  await this._modalBottomSheetMenu(context, value!);
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _modalBottomSheetMenu(
      BuildContext context, DateTimeRange range) {
    return showModalBottomSheet(
        isDismissible: true,
        context: context,
        builder: (builder) {
          return BottomSheet(
              onClosing: () {},
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context, setState) => Column(
                    children: [
                      RadioListTile<ShiftTime>(
                        activeColor: Theme.of(context).accentColor,
                        title: makeRadioTitle(context, "Morning",
                            ShiftTime.MORNING == this._startWith),
                        value: ShiftTime.MORNING,
                        groupValue: this._startWith,
                        onChanged: (ShiftTime? value) {
                          setState(() => this._startWith = value);
                        },
                      ),
                      RadioListTile<ShiftTime>(
                        activeColor: Theme.of(context).accentColor,
                        title: makeRadioTitle(context, "Afternoon",
                            ShiftTime.AFTERNOON == this._startWith),
                        value: ShiftTime.AFTERNOON,
                        groupValue: this._startWith,
                        onChanged: (ShiftTime? value) {
                          setState(() => this._startWith = value);
                        },
                      ),
                      RadioListTile<ShiftTime>(
                        activeColor: Theme.of(context).accentColor,
                        title: makeRadioTitle(context, "Night",
                            ShiftTime.NIGHT == this._startWith),
                        value: ShiftTime.NIGHT,
                        groupValue: this._startWith,
                        onChanged: (ShiftTime? value) {
                          setState(() => this._startWith = value);
                        },
                      ),
                      RadioListTile<ShiftTime>(
                        activeColor: Theme.of(context).accentColor,
                        title: makeRadioTitle(
                            context, "Free", ShiftTime.FREE == this._startWith),
                        value: ShiftTime.FREE,
                        groupValue: this._startWith,
                        onChanged: (ShiftTime? value) {
                          setState(() => this._startWith = value);
                        },
                      ),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _shiftScheduler.start = range.start;
                            _shiftScheduler.end = range.end;
                            _shiftScheduler.startWith = this._startWith!;
                            _shiftScheduler.userId = this._userModel.id;
                            _dao.insertShift(_shiftScheduler);
                          });
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return HomeView();
                          }));
                          //Navigator.pop(context);
                        },
                        child: Text("Done"),
                      )
                    ],
                  ),
                );
              });
        });
  }
}
