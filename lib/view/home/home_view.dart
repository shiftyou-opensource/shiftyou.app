import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/utils/converter.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/charts/pie_chart.dart';
import 'package:nurse_time/view/home/insert_modify_shift.dart';
import 'package:nurse_time/view/settings/set_up_view.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  ShiftScheduler? _shiftScheduler;
  SchedulerRules? _selectedScheduler;
  int _selectedView = 1;

  late List<SchedulerRules> _schedulerRules;
  late AbstractDAO _dao;
  late UserModel _userModel;
  late Logger _logger;
  late PageController _pageController;

  _HomeView() {
    this._logger = GetIt.instance.get<Logger>();
    this._userModel = GetIt.instance.get<UserModel>();
    this._dao = GetIt.instance<DAODatabase>();
    this._schedulerRules = GetIt.instance.get<List<SchedulerRules>>();
    this._pageController = PageController(initialPage: _selectedView);
  }

  set selectedScheduler(SchedulerRules schedulerRules) =>
      this._selectedScheduler = schedulerRules;

  ShiftScheduler get shiftScheduler => this._shiftScheduler!;

  @override
  void initState() {
    super.initState();
    this._shiftScheduler = GetIt.instance.get<ShiftScheduler>();
    //TODO this contains the bug to have the UI lean to startup.
    // but I don't know why at the moment.
    // we are coming from the login view, and we have no information about the
    // state chose from the user in the setting ui.
    if (GetIt.instance.isRegistered<SchedulerRules>()) {
      this._selectedScheduler = GetIt.instance.get<SchedulerRules>();
      this._shiftScheduler!.timeOrders = this._selectedScheduler!.timeOrders;
      this._shiftScheduler!.notify();
    }
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
          settingView: _selectedView == 2,
          onPress: (context, modify, index) => _makeBottomDialog(
              context: context, modify: modify, index: index)),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedView = index),
        children: [
          SafeArea(child: PieChartShift(shifts: _shiftScheduler!.shifts)),
          SafeArea(child: _buildHomeView(context, _shiftScheduler!.shifts)),
          SafeArea(
              child: SetUpView(
                  schedulerRules: _schedulerRules,
                  onUpdate: (int selectedRules) {
                    setState(() {
                      this._shiftScheduler!.rules =
                          _schedulerRules[selectedRules];
                    });
                  },
                  ownView: false,
                  shiftScheduler: this._shiftScheduler)),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Theme.of(context).backgroundColor,
        selectedIndex: _selectedView,
        containerHeight: 68,
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
      bool settingView = false,
      int? index,
      Icon icon = const Icon(Icons.add),
      required Function(BuildContext, bool, int?) onPress}) {
    return makeVisibleComponent(
        FloatingActionButton.extended(
          onPressed: () async {
            // add and modify shift
            if (!settingView) {
              onPress(context, modify, index);
            } else {
              // Set the new data inside the _shiftScheduler and update the ui.
              await _dao.deleteShiftException(_shiftScheduler!);
              setState(() {
                _shiftScheduler!.userId = this._userModel.id;
                // we are modify the shift, this mean that we can delete the
                // old exception and save the new one
                _shiftScheduler!.cleanException().notify();
                _dao.updateShift(_shiftScheduler!);
                _pageController.jumpToPage(1);
                showSnackBar(context, "New Scheduler generated");
              });
            }
          },
          icon: settingView ? Icon(Icons.done) : icon,
          backgroundColor: Theme.of(context).accentColor,
          foregroundColor: Theme.of(context).primaryColor,
          elevation: 5,
          label: settingView ? Text("Save") : Text("Add"),
        ),
        (_selectedView == 1 || _selectedView == 2));
  }

  void _makeBottomDialog(
      {required BuildContext context, bool modify = false, int? index}) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          var _shifts = _shiftScheduler!.shifts;
          return Container(
              height: MediaQuery.of(context).copyWith().size.height * 0.80,
              child: InsertModifyShiftView(
                title: modify ? "Modify the Shift" : "Insert a Shift",
                start: _shifts.isEmpty ? DateTime.now() : _shifts.first.date,
                shiftScheduler: _shiftScheduler!,
                shift: index != null ? _shifts[index] : null,
                onSave: (Shift shift) => {
                  _logger.d("On save called in the bottom dialog"),
                  setState(() => {
                        _shiftScheduler!.addException(shift),
                        _dao.updateShift(_shiftScheduler!),
                        _logger.d("Update shift inside the db"),
                        showSnackBar(context, "All done 🌈"),
                      })
                },
                onClose: () => Navigator.of(context).pop(),
                modify: modify,
              ));
        });
  }

  Widget _buildHomeView(BuildContext context, List<Shift> shifts) {
    return Column(children: [
      Expanded(
          flex: MediaQuery.of(context).size.height > 900 ? 5 : 2,
          child: Container(
            color: Theme.of(context).backgroundColor,
            child:
                Center(child: PieChartShift(shifts: _shiftScheduler!.shifts)),
          )),
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
                        style: TextStyle(
                            fontFamily: 'DsDigit',
                            fontSize: 25 *
                                MediaQuery.of(context)
                                    .copyWith()
                                    .textScaleFactor)),
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
}
