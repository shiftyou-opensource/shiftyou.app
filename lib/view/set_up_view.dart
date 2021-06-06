import 'package:flutter/material.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/view/home_view.dart';
import 'package:get_it/get_it.dart';

class SetUpView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetUpView();
}

class _SetUpView extends State<SetUpView> {
  late ShiftScheduler _shiftScheduler;
  late UserModel _userModel;
  late Logger _logger;
  ShiftTime? _startWith;

  _SetUpView() {
    this._startWith = ShiftTime.MORNING;
    this._shiftScheduler = GetIt.instance.get<ShiftScheduler>();
    this._userModel = GetIt.instance.get<UserModel>();
    this._logger = GetIt.instance.get<Logger>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Setting Scheduler"),
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
                ],
              )
            ],
          ),
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
                        title: const Text("Morning"),
                        value: ShiftTime.MORNING,
                        groupValue: this._startWith,
                        onChanged: (ShiftTime? value) {
                          setState(() => this._startWith = value);
                        },
                      ),
                      RadioListTile<ShiftTime>(
                        title: const Text("Afternoon"),
                        value: ShiftTime.AFTERNOON,
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
