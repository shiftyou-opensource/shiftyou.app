import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/utils/spinner_chooser.dart';
import 'package:nurse_time/utils/converter.dart';

class InsertModifyShiftView extends StatefulWidget {
  final String title;
  final Function(Shift) onSave;
  final Function onClose;
  final ShiftScheduler shiftScheduler;
  final Shift? shift;
  final bool modify;
  final DateTime? start;
  late final List<Image> icons;
  late final Logger logger;

  InsertModifyShiftView(
      {Key? key,
      required this.title,
      required this.onSave,
      required this.onClose,
      required this.modify,
      required this.shiftScheduler,
      this.shift,
      this.start})
      : super(key: key) {
    this.icons = Converter.shiftToListOfImages(height: 50.0);
    this.logger = GetIt.instance<Logger>();
  }

  @override
  State<StatefulWidget> createState() => _InsertModifyShiftView();
}

class _InsertModifyShiftView extends State<InsertModifyShiftView> {
  late ShiftTime _shiftTime;
  late DateTime _selectedDate;

  _InsertModifyShiftView() {
    this._shiftTime = ShiftTime.MORNING;
    this._selectedDate = DateTime.now();
  }

  @override
  void initState() {
    if (widget.shift != null) {
      this._shiftTime = widget.shift!.time;
      // assume that the shift is null only when the modify it is enabled
      widget.logger
          .d("Widget open in modify mode? ${widget.modify ? "Yes" : "no"}");
      this._selectedDate = widget.shift!.date;
    } else {
      this._selectedDate =
          (widget.start != null ? widget.start : this._selectedDate)!;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var index = 0; index < widget.icons.length; index++)
      precacheImage(widget.icons[index].image, context);
  }

  Widget _makeInsertView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _makeTitleView(context: context, text: widget.title),
        Divider(),
        _makeShiftView(context: context),
        Divider(),
        Flexible(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: DatePickerWidget(
                looping: false,
                // default is not looping
                initialDate: this._selectedDate,
                //DateTime(1960),
                dateFormat: "dd-MMMM-yyyy",
                onChange: (DateTime newDate, _) {
                  _selectedDate = newDate;
                },
                pickerTheme: DateTimePickerTheme(
                  backgroundColor: Theme.of(context).backgroundColor,
                  itemTextStyle: Theme.of(context).textTheme.caption!,
                  dividerColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            )),
        _makeButton(context),
        Spacer(),
      ],
    );
  }

  Widget _makeModifyView(BuildContext context) {
    return Column(
      children: [
        _makeTitleView(context: context, text: widget.title),
        Divider(),
        Flexible(
            child: Text(
              "${AppLocalization.getWithKey(Keys.Generic_Messages_Modify_Daily_Shift)} ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .apply(fontSizeFactor: 1.3),
            ),
            flex: 1),
        _makeShiftView(context: context),
        Spacer(),
        _makeButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: widget.modify
            ? _makeModifyView(context)
            : _makeInsertView(context));
  }

  Widget _makeButton(BuildContext context) {
    return Flexible(
      flex: 2,
      child: SingleChildScrollView(
        child: SizedBox(
          width: 120,
          height: 50,
          child: makeButton(context,
              onPress: () => {
                    widget.onSave(Shift(_selectedDate, _shiftTime)),
                    widget.onClose()
                  }),
        ),
      ),
    );
  }

  Widget _makeTitleView({context: BuildContext, text: String}) {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              child: Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .apply(fontSizeFactor: 1.7)),
            )),
        Expanded(
          flex: 0,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: IconButton(
                iconSize: 30,
                onPressed: () => widget.onClose(),
                icon: Icon(Icons.close)),
          ),
        ),
      ],
    );
  }

  Widget _makeShiftView({context: BuildContext}) {
    return Flexible(
        flex: 5,
        child: SpinnerChooser<Widget>(
          horizontal: true,
          magnification: 1,
          useMagnifier: false,
          diameterRatio: 1,
          itemSize: 60.0,
          onValueChanged: (s, index) => {
            setState(() => _shiftTime = Converter.fromIntToShiftTime(index))
          },
          options: widget.icons,
          startPosition: Converter.shiftToListPosition(_shiftTime),
          dividerColor: Theme.of(context).colorScheme.primary,
          builder: (image, index) => Column(
            children: [
              Container(
                child: image,
              ),
              SizedBox(height: 9),
              Text(
                  Converter.fromShiftTimeToString(
                      Converter.fromIntToShiftTime(index)),
                  style: Theme.of(context).textTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)
            ],
          ),
        ));
  }
}
