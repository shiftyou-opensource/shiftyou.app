import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import '../../actions/google_sign_in.dart';
import '../../utils/generic_components.dart';
import 'package:get_it/get_it.dart';

class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  late GoogleManagerUserLogin _googleLogin;
  late DAODatabase _dao;
  late UserModel _userModel;
  late Logger _logger;
  _LoginView() {
    this._logger = GetIt.instance<Logger>();
    this._googleLogin = GetIt.instance.get<GoogleManagerUserLogin>();
    this._dao = GetIt.instance.get<DAODatabase>();
    this._userModel = GetIt.instance.get<UserModel>();
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
          this._userModel.bing(userModel);
          _dao.insertUser(userModel).then((_) {
            Navigator.pushNamed(context, "/setting");
          })
              .catchError((error) => {
                _logger.e(error),
                showSnackBar(context, error.toString())
              });
          // ignore: invalid_return_type_for_catch_error
        }).catchError((error) => {
          _logger.e(error),
          showSnackBar(context, error.toString())
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
