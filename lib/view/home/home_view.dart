import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/utils/converter.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/utils/map_reduce_shifts.dart';
import 'package:nurse_time/view/home/insert_modify_shift.dart';
import 'package:nurse_time/view/settings/set_up_view.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  late List<Shift> _shifts;
  late bool _manual;
  late Logger _logger;
  late PageController _pageController;
  int? _touchedIndex;
  int _selectedView = 1;

  _HomeView() {
    ShiftScheduler shiftScheduler = GetIt.instance.get<ShiftScheduler>();
    this._logger = GetIt.instance.get<Logger>();
    this._shifts = shiftScheduler.generateScheduler(complete: false);
    this._manual = shiftScheduler.isManual();
    this._pageController = PageController(initialPage: _selectedView);
    _logger.d(_shifts.toString());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Shift"),
        primary: true,
        elevation: 0,
        leading: Container(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: _makeFloatingButton(context,
          onPress: (context, modify, index) => _makeBottomDialog(
              context: context, modify: modify, index: index)),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedView = index),
        children: [
          SafeArea(
            child: PieChart(
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
            ),
          ),
          SafeArea(child: _buildHomeView(context, _shifts)),
          SafeArea(child: SetUpView(ownView: false)),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Theme.of(context).backgroundColor,
        selectedIndex: _selectedView,
        containerHeight: 70,
        itemCornerRadius: 24,
        onItemSelected: (index) => _pageController.jumpToPage(index),
        items: <BottomNavyBarItem>[
          makeItem(context, 'Statistics', Icons.timeline, 0, _selectedView),
          makeItem(context, 'Home', Icons.home, 1, _selectedView),
          makeItem(context, 'Settings', Icons.settings, 2, _selectedView),
        ],
      ),
    );
  }

  Widget _makeFloatingButton(BuildContext context,
      {bool modify = false,
      int? index,
      Icon icon = const Icon(Icons.add),
      required Function(BuildContext, bool, int?) onPress}) {
    return makeVisibleComponent(
        FloatingActionButton.extended(
          onPressed: () => onPress(context, modify, index),
          icon: icon,
          backgroundColor: Theme.of(context).accentColor,
          foregroundColor: Theme.of(context).primaryColor,
          elevation: 5,
          label: Text("Add"),
        ),
        (_selectedView == 1 || _selectedView == 2));
  }

  void _makeBottomDialog(
      {required BuildContext context, bool modify = false, int? index}) {
    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          return InsertModifyShiftView(
            title: modify ? "Modify the Shift" : "Insert a Shift",
            start: _shifts.isEmpty
                ? DateTime.now()
                : _shifts.last.date.add(Duration(days: 1)),
            shift: index != null ? _shifts[index] : null,
            onSave: (Shift shift) => {
              _logger.d("On save called in the bottom dialog"),
              // TODO: save state and adding some method to handle the
              // manual method
              if (index == null)
                setState(() => _shifts.add(shift))
              else
                setState(() => _shifts.elementAt(index).fromShift(shift))
            },
            onClose: () => Navigator.of(context).pop(),
            modify: modify,
          );
        });
  }

  Widget _buildHomeView(BuildContext context, List<Shift> shifts) {
    return Column(children: [
      Expanded(
          flex: 2,
            child: Container(
              width: 150,
              height: 280,
              color: Theme.of(context).backgroundColor,
              child: Center(
                child: PieChart(
                  PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          final desiredTouch = pieTouchResponse.touchInput
                                  is! PointerExitEvent &&
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
                ),
              ),
            )
          ),
      Expanded(
        flex: 3,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: shifts.length,
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return _buildShiftCardView(context, shifts[index], index);
            }),
      ),
    ]);
  }

  Widget _buildShiftCardView(BuildContext context, Shift shift, int index) {
    return Card(
        elevation: 10.0,
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                        child: Image(
                            image: AssetImage(
                                "assets/images/${Converter.fromShiftTimeToImage(shift.time)}"),
                            height: 60.0)),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Center(
                      child: Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text(
                        "${shift.date.day}/${shift.date.month}/${shift.date.year}",
                        style: TextStyle(fontFamily: 'DsDigit', fontSize: 30)),
                  )),
                ),
                Expanded(
                    flex: 2,
                    child: Center(
                        child: IconButton(
                      onPressed: () => _makeBottomDialog(
                          modify: true, index: index, context: context),
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                        size: 25.0,
                      ),
                    )))
              ],
            ),
          ),
        ));
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> pieChartData = List.empty(growable: true);
    // We need to make the sum to runtime to paint the chart
    var shiftCalculation = MapReduceShift.reduce(_shifts);
    var indexElem = 0;
    shiftCalculation.forEach((shift, count) {
      final isTouched = indexElem++ == _touchedIndex;
      final double radius = isTouched ? 110 : 100;
      final double widgetSize = isTouched ? 70 : 55;

      switch (shift) {
        case ShiftTime.AFTERNOON:
          pieChartData.add(PieChartSectionData(
            color: const Color(0xff89ddff),
            value: (count * 100) / _shifts.length,
            title: '${(count * 100) ~/ _shifts.length}%',
            radius: radius,
            titleStyle: Theme.of(context).textTheme.subtitle1,
            badgeWidget: _Badge(
              Converter.fromShiftTimeToImage(shift),
              size: widgetSize,
              borderColor: const Color(0xff0293ee),
            ),
            badgePositionPercentageOffset: .98,
          ));
          break;
        case ShiftTime.FREE:
          pieChartData.add(PieChartSectionData(
            color: const Color(0xfff07178),
            value: (count * 100) / _shifts.length,
            title: '${(count * 100) ~/ _shifts.length}%',
            radius: radius,
            titleStyle: Theme.of(context).textTheme.subtitle1,
            badgeWidget: _Badge(
              Converter.fromShiftTimeToImage(shift),
              size: widgetSize,
              borderColor: const Color.fromARGB(190, 255, 0, 57),
            ),
            badgePositionPercentageOffset: .98,
          ));
          break;
        case ShiftTime.NIGHT:
          pieChartData.add(PieChartSectionData(
            color: const Color(0xffc792ea),
            value: (count * 100) / _shifts.length,
            title: '${(count * 100) ~/ _shifts.length}%',
            radius: radius,
            titleStyle: Theme.of(context).textTheme.subtitle1,
            badgeWidget: _Badge(
              Converter.fromShiftTimeToImage(shift),
              size: widgetSize,
              borderColor: const Color(0xff845bef),
            ),
            badgePositionPercentageOffset: .98,
          ));
          break;
        case ShiftTime.MORNING:
          pieChartData.add(PieChartSectionData(
            color: const Color(0xffffcb6b),
            value: (count * 100) / _shifts.length,
            title: '${(count * 100) ~/ _shifts.length}%',
            radius: radius,
            titleStyle: Theme.of(context).textTheme.subtitle1,
            badgeWidget: _Badge(
              Converter.fromShiftTimeToImage(shift),
              size: widgetSize,
              borderColor: const Color.fromARGB(190, 249, 168, 37),
            ),
            badgePositionPercentageOffset: .98,
          ));
          break;
        default:
          return null;
      }
    });
    return pieChartData;
  }
}

class _Badge extends StatelessWidget {
  final String svgAsset;
  final double size;
  final Color borderColor;

  const _Badge(
    this.svgAsset, {
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
        color: Theme.of(context).backgroundColor,
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
