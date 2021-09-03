import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift_scheduler.dart';

import 'abstract_indicator_view.dart';

class PeriodViewStep extends AbstractIndicatorStep {
  final Logger _logger = GetIt.instance.get<Logger>();
  final ShiftScheduler shiftScheduler;

  final Function onSave;

  PeriodViewStep(Widget title,
      {required this.onSave, required this.shiftScheduler})
      : super(title);

  @override
  Widget buildView(BuildContext context) {
    return _settingProprieties(context);
  }

  Widget _settingProprieties(BuildContext context) {
    return DateRangeField(
        enabled: true,
        confirmText: "Select",
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.date_range,
              color: Theme.of(context).textTheme.bodyText1!.color),
          hintText: 'Please select a period of your shift',
          border: OutlineInputBorder(),
        ),
        initialValue:
            DateTimeRange(start: shiftScheduler.start, end: shiftScheduler.end),
        validator: (value) {
          if (value!.start.isBefore(DateTime.now())) {
            return 'Please enter a valid date';
          }
          return null;
        },
        onChanged: (value) {
          //TODO: in the step view it is better remove this event?
          // or this event it is better use to put in the next step?
          this._logger.d("On Change called");
          this._logger.d("Value received from Data picker");
          this.onSave(value!);
          //this._modalBottomSheetMenu(context, value!);
        },
        onSaved: (value) async {
          //TODO: It is a library bug? it is not called
          this._logger.d("onSaved: Value received from Data picker");
          this.onSave(value!);
          //await this._modalBottomSheetMenu(context, value!);
        });
  }
}
