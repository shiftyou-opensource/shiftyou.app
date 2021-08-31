import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/utils/converter.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/settings/abstract_indicator_view.dart';

class OptionViewStep extends AbstractIndicatorStep {
  final List<SchedulerRules> _schedulerRules;
  final List<ShiftTime> _shiftTimePicker;
  final int _selectedRules;
  final Function _onDelete;
  final Function _onAddTime;
  late Logger _logger;

  OptionViewStep(Widget title, this._schedulerRules, this._selectedRules,
      this._onDelete, this._shiftTimePicker, this._onAddTime)
      : super(title) {
    this._logger = GetIt.instance<Logger>();
  }

  @override
  Widget buildView(BuildContext context) {
    return Column(
      children: [
        _makeChipsArea(context),
        makeVisibleComponent(
            makeTitleDivider("Shift order: How your shift looks like"),
            _schedulerRules[_selectedRules].size() != 0,
            disappear: true),
        makeVisibleComponent(
            makeTitleDivider("Adding your shift time with one click"),
            !_schedulerRules[_selectedRules].static,
            disappear: true),
        makeVisibleComponent(_makeShiftTimePicker(context),
            !_schedulerRules[_selectedRules].static,
            disappear: true),
      ],
    );
  }

  Widget _makeChipsArea(BuildContext context) {
    return makeVisibleComponent(
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

  void removeChipAt(BuildContext context, int index) {
    try {
      _onDelete(index);
    } on Exception catch (ex) {
      this._logger.e(ex);
      showSnackBar(context, "You can't remove this shift");
    }
  }

  Widget _makeShiftTimePicker(BuildContext context) {
    return Column(
      children: List<ListTile>.generate(
        _shiftTimePicker.length,
        (index) => ListTile(
          title: _makeShiftTimePickerItem(context, _shiftTimePicker[index]),
        ),
      ),
    );
  }

  Widget _makeShiftTimePickerItem(BuildContext context, ShiftTime time) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Image(
                  image: AssetImage(
                      "assets/images/${Converter.fromShiftTimeToImage(time)}")),
            )),
        Expanded(flex: 3, child: Text(Converter.fromShiftTimeToString(time))),
        Expanded(
            flex: 1,
            child: IconButton(
                icon: Icon(Icons.add), onPressed: () => _onAddTime(time)))
      ],
    );
  }
}
