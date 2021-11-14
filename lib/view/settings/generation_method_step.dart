import 'package:flutter/material.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/utils/generic_components.dart';

import 'abstract_indicator_view.dart';

class GenerationMethodStep extends AbstractIndicatorStep {
  final int _selectedIndex;
  final Function _onChanged;
  final List<SchedulerRules> _schedulerRules;

  GenerationMethodStep(
      Widget title, this._onChanged, this._selectedIndex, this._schedulerRules)
      : super(title, messageTips: "Some tips");

  @override
  Widget buildView(BuildContext context) {
    return _makeRadioButtonView(context);
  }

  Widget _makeRadioButtonView(BuildContext context) {
    return Column(
        children: List<RadioListTile>.generate(
            _schedulerRules.length,
            (index) => RadioListTile(
                  title: makeRadioTitle(context, _schedulerRules[index].name,
                      index == _selectedIndex),
                  value: index,
                  groupValue: _selectedIndex,
                  onChanged: (value) => _onChanged(value),
                )));
  }
}
