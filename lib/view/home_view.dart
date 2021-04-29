import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/shift.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  UserModel userModel;
  List<Shift> _shifts;
  Logger _logger;

  _HomeView() {
    ShiftScheduler scheduler = GetIt.instance.get<ShiftScheduler>();
    this.userModel = GetIt.instance.get<UserModel>();
    this._logger = GetIt.instance.get<Logger>();
    this._shifts = scheduler.generateScheduler();
    _logger.d(_shifts.toString());
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
      body: SafeArea(child: _buildHomeView(context, _shifts)),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          )
        ],
      ),
    );
  }

  Widget _buildHomeView(BuildContext context, List<Shift> shifts) {
    return Column(children: [
      Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                color: Theme.of(context).backgroundColor,
                child: Center(child: Text("TODO some here"))),
          ]),
      Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: shifts.length,
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext contex, int index) {
              return _buildShiftCardView(
                  context, fromShiftToImage(shifts[index]));
            }),
      ),
    ]);
  }

  String fromShiftToImage(Shift shift) {
    switch (shift.time) {
      case ShiftTime.AFTERNOON:
        return "coffee.png";
      case ShiftTime.MORNING:
        return "morning.png";
      case ShiftTime.FREE:
        return "for-you.png";
      case ShiftTime.NIGHT:
        return "night.png";
      default:
        throw Exception("No image found with name ${shift.time}");
    }
  }

  Widget _buildShiftCardView(BuildContext context, String nameImage) {
    return Card(
        elevation: 3,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        child: Image(
                            image: AssetImage("assets/images/$nameImage"),
                            height: 80.0)),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: EdgeInsets.all(18),
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.topCenter,
                      child: Text("Right Now"),
                    )
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(18),
                      padding: EdgeInsets.all(15),
                      color: Colors.black38,
                      child: Text("right"),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
