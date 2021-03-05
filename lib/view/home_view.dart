import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nurse_time/actions/google_sign_in.dart';

class HomeView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {

  GoogleManagerUserLogin _googleLogin;


  _HomeView(){
    this._googleLogin =
        GetIt.instance.get<GoogleManagerUserLogin>();
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
      body: SafeArea(
        child: Container(
            child: Center(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: Colors.blue,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 60.0,
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: NetworkImage(
                            _googleLogin.getCurrentUser().photoURL.toString()),
                        backgroundColor: Colors.transparent,
                      ),
                  ),
                  )
                ),
                Center(
                  heightFactor: 1.2,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      Card(
                        elevation: 3,
                        child: Center(
                          child: Text("Time One"),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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

}
