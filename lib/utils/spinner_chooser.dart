import 'package:flutter/material.dart';

class SpinnerChooser<T> extends StatefulWidget {
  final TextStyle? selectTextStyle;
  final TextStyle? unSelectTextStyle;
  final Function(T, int) onValueChanged;
  final List<T>? options;
  final int startPosition;
  final double itemSize;
  final double diameterRatio;
  final double squeeze;
  final double magnification;
  final double perspective;
  final double? listHeight;
  final double? listWidth;
  final bool horizontal;
  final bool isInfinite;
  final bool useMagnifier;
  final double? indent;
  final Color dividerColor;
  static const double _defaultItemSize = 48.0;
  final WheelBuilder<T> builder;

  SpinnerChooser({
    required this.onValueChanged,
    required this.options,
    required this.builder,
    this.selectTextStyle,
    this.unSelectTextStyle,
    this.startPosition = 0,
    this.squeeze = 1.0,
    this.itemSize = _defaultItemSize,
    this.magnification = 1,
    this.perspective = 0.0000000001,
    this.listWidth,
    this.listHeight,
    this.dividerColor = Colors.transparent,
    this.indent = 16.0,
    this.horizontal = false,
    this.isInfinite = false,
    this.diameterRatio = 20,
    this.useMagnifier = false,
  }) : assert(perspective <= 0.01);

  @override
  _SpinnerChooser<T> createState() => _SpinnerChooser<T>();
}

class _SpinnerChooser<T> extends State<SpinnerChooser<T>> {
  FixedExtentScrollController? fixedExtentScrollController;
  int? currentPosition;

  @override
  void initState() {
    super.initState();
    currentPosition = widget.startPosition;
    fixedExtentScrollController =
        FixedExtentScrollController(initialItem: currentPosition!);
  }

  void _listener(int position) {
    setState(() {
      currentPosition = position;
    });
    if (widget.options == null) {
      widget.onValueChanged(
          widget.options![currentPosition!], currentPosition!);
    } else {
      widget.onValueChanged(
          widget.options![currentPosition!], currentPosition!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
        quarterTurns: widget.horizontal ? 3 : 0,
        child: Container(
            height: widget.listHeight ?? double.infinity,
            width: widget.listWidth ?? double.infinity,
            child: _getListWheelScrollView()));
  }

  Widget _getListWheelScrollView<T>() {
    return ListWheelScrollView.useDelegate(
      itemExtent: widget.itemSize,
      perspective: widget.perspective,
      squeeze: widget.squeeze,
      controller: fixedExtentScrollController,
      diameterRatio: widget.diameterRatio,
      magnification: widget.magnification,
      useMagnifier: widget.useMagnifier,
      physics: FixedExtentScrollPhysics(),
      onSelectedItemChanged: _listener,
      childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.options!.length,
          builder: (BuildContext context, int i) {
            return _buildListItems(i, selected: i == currentPosition);
          }),
    );
    // return widget.builder(widget.options![0]);
  }

  Widget _buildListItems<T>(int index, {bool selected = false}) {
    if (selected) {
      return RotatedBox(
          quarterTurns: widget.horizontal ? 1 : 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(
                  indent: widget.indent,
                  endIndent: widget.indent,
                  color: widget.dividerColor,
                  thickness: 1.0,
                  height: 0,
                ),
                SizedBox(height: widget.indent),
                widget.builder(widget.options![index], index),
                //Text(index.toString()),
                SizedBox(height: widget.indent),
                Divider(
                  indent: widget.indent,
                  endIndent: widget.indent,
                  color: widget.dividerColor,
                  height: 0,
                  thickness: 1.0,
                ),
              ],
            ),
          ));
    }
    return RotatedBox(
        quarterTurns: widget.horizontal ? 1 : 0,
        child: Center(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [widget.builder(widget.options![index], index)]),
        ));
  }
}

typedef WheelBuilder<T> = Widget Function(T option, int index);
