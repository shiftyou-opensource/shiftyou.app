import 'package:flutter/material.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/view/home_view.dart';
import 'package:get_it/get_it.dart';

class SetUpView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetUpView();
}

class _SetUpView extends State<SetUpView> {
  ShiftScheduler shiftScheduler;
  _SetUpView() {
    this.shiftScheduler = GetIt.instance.get<ShiftScheduler>();
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
              _settingProprieties(context)
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
                context: context,
                decoration: InputDecoration(
                  labelText: 'Date Range',
                  prefixIcon: Icon(Icons.date_range),
                  hintText: 'Please select a start and end date',
                  border: OutlineInputBorder(),
                ),
                initialValue:
                    DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                validator: (value) {
                  if (value.start.isBefore(DateTime.now())) {
                    return 'Please enter a valid date';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() => shiftScheduler.start = value.start);
                  setState(() {
                    shiftScheduler.end = value.end;
                  });
                }),
            ElevatedButton(
                autofocus: true,
                onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return HomeView();
                    })),
                child: Text("Press"))
          ],
        ),
      ),
    );
  }
}
