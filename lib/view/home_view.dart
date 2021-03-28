import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:nurse_time/model/user_model.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  UserModel userModel;

  _HomeView() {
    this.userModel = GetIt.instance.get<UserModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Some Title here"),
        primary: true,
        elevation: 2,
        leading: Container(),
      ),
      body: SafeArea(child: _buildHomeView(context)),
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

  Widget _buildHomeView(BuildContext context) {
    return Column(children: [
      Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                color: Theme.of(context).backgroundColor,
                child: Center(
                    child: Text("TODO some here")
                )),
          ]),
      Expanded(
        child: ListView(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: [
            _buildShiftCardView(context, "morning.png"),
            _buildShiftCardView(context, "coffee.png"),
            _buildShiftCardView(context, "night.png"),
            _buildShiftCardView(context, "for-you.png")
          ],
        ),
      ),
    ]);
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
