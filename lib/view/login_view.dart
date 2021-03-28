import 'package:flutter/material.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/view/set_up_view.dart';
import '../actions/google_sign_in.dart';
import 'package:get_it/get_it.dart';

class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  GoogleManagerUserLogin _googleLogin;
  DAODatabase _dao;

  _LoginView() {
    this._googleLogin = GetIt.instance.get<GoogleManagerUserLogin>();
    this._dao = GetIt.instance.get<DAODatabase>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: SafeArea(
          child: Container(
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/ic_launcher.png"),
              SizedBox(height: 50),
              _signInButton()
            ],
          ),
        ),
      )),
    );
  }

  Widget _signInButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 0,
        side: BorderSide(color: Colors.grey),
      ),
      onPressed: () {
        _googleLogin.signIn().then((userModel) {
          _dao.insertUser(userModel);
          Navigator.of(context).push(
            MaterialPageRoute(
              maintainState: false,
              builder: (context) {
                return SetUpView();
              },
            ),
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google-logo.png"), height: 55.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
