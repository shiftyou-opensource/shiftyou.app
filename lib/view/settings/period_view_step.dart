import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
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
        confirmText: AppLocalization.getWithKey(Keys.Words_Word_Select),
        cancelText: AppLocalization.getWithKey(Keys.Words_Cancel),
        saveText: AppLocalization.getWithKey(Keys.Words_Word_Save),
        helpText: AppLocalization.getWithKey(
            Keys.Generic_Messages_Select_Period_Shift),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.date_range,
              color: Theme.of(context).textTheme.bodyText1!.color),
          hintText: AppLocalization.getWithKey(
              Keys.Generic_Messages_Select_Period_Shift),
          hintStyle: Theme.of(context).textTheme.bodyText1!,
          labelStyle: Theme.of(context).textTheme.bodyText1!,
          counterStyle: Theme.of(context).textTheme.bodyText1!,
          suffixStyle: Theme.of(context).textTheme.bodyText1!,
          helperStyle: Theme.of(context).textTheme.bodyText1!,
          prefixStyle: Theme.of(context).textTheme.bodyText1!,
          floatingLabelStyle: Theme.of(context).textTheme.bodyText1!,
          border: OutlineInputBorder(),
        ),
        initialValue: DateTimeRange(
            start: shiftScheduler.start.isBefore(DateTime.now())
                ? DateTime.now()
                : shiftScheduler.start,
            end: shiftScheduler.end.isBefore(DateTime.now())
                ? DateTime.now()
                : shiftScheduler.end),
        dateFormat:
            DateFormat("dd/MM/yy", Localizations.localeOf(context).toString()),
        validator: (value) {
          if (value!.start.isBefore(DateTime.now())) {
            return AppLocalization.getWithKey(
                Keys.Generic_Messages_Invalid_Date);
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
