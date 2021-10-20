import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/actions/google_sign_in.dart';
import 'package:nurse_time/utils/app_preferences.dart';
import 'package:nurse_time/utils/generic_components.dart';
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
    Future.delayed(Duration.zero, () async {
      var showDialog = await AppPreferences.instance
          .valueWithKey(PreferenceKey.DIALOG_SHOWS, defValue: false) as bool;
      if (showDialog) {
        await AppPreferences.instance
            .putValue(PreferenceKey.DIALOG_SHOWS, false);
        var message = await AppPreferences.instance
            .valueWithKey(PreferenceKey.DIALOG_MESSAGE) as String;
        showAppDialog(
            context: context,
            title:
                AppLocalization.getWithKey(Keys.Generic_Messages_Upgrade_Info),
            message: message);
      }
    });
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

  FutureOr<Null> _handleError(dynamic error) async {
    _logger.e(error);
    showSnackBar(context, error.toString());
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
          }).catchError((error) => _handleError(error));
        }).catchError((error) => _handleError(error));
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
                AppLocalization.getWithKey(Keys.Generic_Messages_Login_Google),
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
