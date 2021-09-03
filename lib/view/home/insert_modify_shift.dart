import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/utils/spinner_chooser.dart';
import 'package:nurse_time/utils/converter.dart';

class InsertModifyShiftView extends StatefulWidget {

  final String title;
  final Function(Shift) onSave;
  final Function onClose;
  final Shift? shift;
  final bool modify;
  final DateTime? start;
  late final List<Image> icons;

  InsertModifyShiftView(
      {Key? key,
      required this.title,
      required this.onSave,
      required this.onClose,
      required this.modify,
      this.shift,
      this.start})
      : super(key: key) {
    this.icons = Converter.shiftToListOfImages(height: 50.0);
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
    }
    if (widget.start != null) this._selectedDate = widget.start!;
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
      children: [
        _makeTitleView(context: context, text: widget.title),
        Divider(),
        _makeShiftView(context: context),
        Divider(),
        Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: DatePickerWidget(
                looping: false,
                // default is not looping
                firstDate: this._selectedDate,
                //DateTime(1960),
                dateFormat: "dd-MMMM",
                onChange: (DateTime newDate, _) {
                  _selectedDate = newDate;
                },
                pickerTheme: DateTimePickerTheme(
                  backgroundColor: Theme.of(context).backgroundColor,
                  itemTextStyle: Theme.of(context).textTheme.caption!,
                  dividerColor: Theme.of(context).accentColor,
                ),
              ),
            )),
        Expanded(
          flex: 1,
          child: Container(
            child: OutlinedButton.icon(
                onPressed: () => {
                      widget.onSave(Shift(_selectedDate, _shiftTime)),
                      widget.onClose()
                    },
                icon: Icon(Icons.done_all_rounded),
                label: Text("Insert")),
          ),
        ),
        Spacer(),
      ],
    );
  }

  Widget _makeModifyView(BuildContext context) {
    return Column(
      children: [
        _makeTitleView(context: context, text: widget.title),
        Divider(),
        Expanded(child: Text("To work on"), flex: 2),
        _makeShiftView(context: context),
        Expanded(
          flex: 1,
          child: Container(
            child: OutlinedButton.icon(
                onPressed: () => {
                      widget.onSave(Shift(_selectedDate, _shiftTime)),
                      widget.onClose()
                    },
                icon: Icon(Icons.done_all_rounded),
                label: Text("Insert")),
          ),
        ),
        Spacer(),
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

  Widget _makeTitleView({context: BuildContext, text: String}) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Text(text, style: Theme.of(context).textTheme.headline5),
            )),
        Container(
          padding: EdgeInsets.all(10.0),
          child: IconButton(
              iconSize: 30,
              onPressed: () => widget.onClose(),
              icon: Icon(Icons.close)),
        )
      ],
    );
  }

  Widget _makeShiftView({context: BuildContext}) {
    return Expanded(
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
          dividerColor: Theme.of(context).accentColor,
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
