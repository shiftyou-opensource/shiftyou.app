import 'package:flutter/material.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../actions/google_sign_in.dart';
import 'package:get_it/get_it.dart';

class SetUpView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetUpView();
}

class _SetUpView extends State<SetUpView> {
  DateTimeRange _schedulerSetUp;
  GoogleManagerUserLogin _googleLogin;

  _SetUpView() {
    this._googleLogin = GetIt.instance.get<GoogleManagerUserLogin>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Expanded(
          child: Column(
            children: [
              Container(
                color: Colors.blue,
                child: Center(
                  heightFactor: 1.5,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 60.0,
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(
                          _googleLogin.getCurrentUser().photoURL.toString()),
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
                  setState(() {
                    _schedulerSetUp = value;
                  });
                }),
            ElevatedButton(
                autofocus: true,
                onPressed: () => print("hello"),
                child: Text("Press"))
          ],
        ),
      ),
    );
  }
}