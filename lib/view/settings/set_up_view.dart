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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.ownView ? "Setting Scheduler" : ""),
        centerTitle: true,
        leading: Container(),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    color: Theme.of(context).backgroundColor,
                    child: Center(
                      heightFactor: 1.5,
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
                  _makeRadioButtonView(context),
                  _makeChipsAres(context),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _makeRadioButtonView(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _schedulerRules.length,
        itemBuilder: (BuildContext context, int index) {
          return RadioListTile(
            title: Text(_schedulerRules[index].name,
                style: Theme.of(context).textTheme.bodyText1),
            value: index,
            groupValue: _selectedRules,
            onChanged: (int? value) => setState(() => _selectedRules = value!),
          );
        });
  }

  void removeChipAt(BuildContext context, int index) {
    try {
      setState(() => _schedulerRules[_selectedRules].removed(index));
    } on Exception catch (ex) {
      _logger.e(ex);
      showSnackBar(context, "You can't remove this shift");
    }
  }

  Widget _makeChipsAres(BuildContext context) {
    return Container(
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
                  label:
                      Text(_schedulerRules[_selectedRules].shiftAtStr(index)))),
        ));
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
                        title: Text("Morning",
                            style: Theme.of(context).textTheme.bodyText1),
                        value: ShiftTime.MORNING,
                        groupValue: this._startWith,
                        onChanged: (ShiftTime? value) {
                          setState(() => this._startWith = value);
                        },
                      ),
                      RadioListTile<ShiftTime>(
                        activeColor: Theme.of(context).accentColor,
                        title: Text("Afternoon",
                            style: Theme.of(context).textTheme.bodyText1),
                        value: ShiftTime.AFTERNOON,
                        groupValue: this._startWith,
                        onChanged: (ShiftTime? value) {
                          setState(() => this._startWith = value);
                        },
                      ),
                      RadioListTile<ShiftTime>(
                        activeColor: Theme.of(context).accentColor,
                        title: Text("Night",
                            style: Theme.of(context).textTheme.bodyText1),
                        value: ShiftTime.NIGHT,
                        groupValue: this._startWith,
                        onChanged: (ShiftTime? value) {
                          setState(() => this._startWith = value);
                        },
                      ),
                      RadioListTile<ShiftTime>(
                        activeColor: Theme.of(context).accentColor,
                        title: Text("Free",
                            style: Theme.of(context).textTheme.bodyText1),
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
