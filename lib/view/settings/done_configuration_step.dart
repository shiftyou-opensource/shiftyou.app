import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/home/home_view.dart';
import 'package:nurse_time/view/settings/abstract_indicator_view.dart';

class DoneConfigurationView extends AbstractIndicatorStep {
  ShiftTime? startWith;
  late ShiftScheduler shiftScheduler;
  late UserModel userModel;
  late AbstractDAO _dao;
  DateTimeRange? range;
  final List<ShiftTime> shiftTimePicker;
  final bool manual;

  DoneConfigurationView(Widget title,
      {required this.startWith,
      required this.shiftScheduler,
      required this.userModel,
      required this.range,
      required this.shiftTimePicker,
      required this.manual})
      : super(title) {
    this._dao = GetIt.instance.get<DAODatabase>();
  }

  @override
  Widget buildView(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, setState) => Column(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              if (range == null) {
                showSnackBar(
                    context, "Please select a valid period in the date range");
                return;
              }
              setState(() {
                shiftScheduler.start = range!.start;
                shiftScheduler.end = range!.end;
                shiftScheduler.userId = this.userModel.id;
                shiftScheduler.timeOrders = shiftTimePicker;
                shiftScheduler.manual = manual;
                _dao.insertShift(shiftScheduler);
              });
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return HomeView();
              }));
              //Navigator.pop(context);
            },
            icon: Icon(Icons.done_all_rounded),
            label: Text("Save"),
          )
        ],
      ),
    );
  }
}
