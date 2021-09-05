import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/utils/converter.dart';
import 'package:nurse_time/utils/map_reduce_shifts.dart';

class PieChartShift extends StatefulWidget {

  final List<Shift> shifts;

  const PieChartShift({Key? key, required this.shifts}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PieChartShift();
}

class _PieChartShift extends State<PieChartShift> {

  late int _touchedIndex;

  // The int is the index of the shift, and the list of color
  // is the list of color used in the component, with the following meaning by index
  // - 0: Main color
  // - 1: Border color
  final Map<int, List<Color>> colorsShift = {
    Converter.fromShiftTimeToIndex(ShiftTime.AFTERNOON): [
      Color(0xff89ddff),
      Color(0xff0293ee)
    ],
    Converter.fromShiftTimeToIndex(ShiftTime.FREE): [
      Color(0xfff07178),
      Color.fromARGB(255, 255, 0, 57)
    ],
    Converter.fromShiftTimeToIndex(ShiftTime.NIGHT): [
      Color(0xffc792ea),
      Color(0xff845bef)
    ],
    Converter.fromShiftTimeToIndex(ShiftTime.MORNING): [
      Color(0xffffcb6b),
      Color.fromARGB(255, 249, 168, 37)
    ],
    Converter.fromShiftTimeToIndex(ShiftTime.STOP_WORK): [
      Color.fromARGB(255, 201, 235, 190),
      Color.fromARGB(255, 61, 176, 23)
    ],
  };

  _PieChartShift() {
    _touchedIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
          pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
            setState(() {
              final desiredTouch =
                  pieTouchResponse.touchInput is! PointerExitEvent &&
                      pieTouchResponse.touchInput is! PointerUpEvent;
              if (desiredTouch &&
                  pieTouchResponse.touchedSection != null) {
                _touchedIndex = pieTouchResponse
                    .touchedSection!.touchedSectionIndex;
              } else {
                _touchedIndex = -1;
              }
            });
          }),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: showingSections()),
    );
  }

  PieChartSectionData _makePieChartData({required ShiftTime shift,
    required double count,
    required int total,
    required bool isTouched,
    required BuildContext context}) {
    double radius = isTouched ? 110 : 100;
    final double widgetSize = isTouched ? 70 : 55;
    int indexShiftTime = Converter.fromShiftTimeToIndex(shift);
    return PieChartSectionData(
      color: colorsShift[indexShiftTime]![0],
      value: (count * 100) / total,
      title: '${(count * 100) ~/ total}%',
      radius: radius,
      titleStyle: Theme
          .of(context)
          .textTheme
          .bodyText1,
      badgeWidget: _Badge(
        Converter.fromShiftTimeToImage(shift),
        size: widgetSize,
        borderColor: colorsShift[indexShiftTime]![1],
      ),
      badgePositionPercentageOffset: .98,
    );
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> pieChartData = List.empty(growable: true);
    // We need to make the sum to runtime to paint the chart
    var _shifts = widget.shifts;
    var shiftCalculation = MapReduceShift.reduce(_shifts);
    var indexElem = 0;
    shiftCalculation.forEach((shift, count) {
      final isTouched = indexElem++ == _touchedIndex;
      var pieData = _makePieChartData(shift: shift,
          count: count,
          total: _shifts.length,
          isTouched: isTouched,
          context: context);
      pieChartData.add(pieData);
    });
    return pieChartData;
  }

}

class _Badge extends StatelessWidget {
  final String svgAsset;
  final double size;
  final Color borderColor;

  const _Badge(this.svgAsset, {
    required this.size,
    required this.borderColor,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      //padding: EdgeInsets.all(size * .15),
      child: Center(
        child:
        Image(image: AssetImage("assets/images/$svgAsset"), height: 35.0),
      ),
    );
  }
}
