import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/actions/auth/apple_sign_in.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/actions/auth/google_sign_in.dart';
import 'package:nurse_time/utils/app_preferences.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  // TODO implementing a builder, that create the single instance
  // of a login managed and put this builder in GetIt
  late GoogleManagerUserLogin _googleLogin;
  late AppleManageUserLogin _appleLogin;
  late DAODatabase _dao;
  late UserModel _userModel;
  late Logger _logger;

  _LoginView() {
    this._logger = GetIt.instance<Logger>();
    this._googleLogin = GetIt.instance.get<GoogleManagerUserLogin>();
    this._appleLogin = GetIt.instance.get<AppleManageUserLogin>();
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
        centerTitle: false,
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
              Spacer(),
              Image.asset("assets/ic_launcher.png"),
              Spacer(),
              _signInButton(
                  buttonsType: Buttons.GoogleDark,
                  buttonText: AppLocalization.getWithKey(
                      Keys.Generic_Messages_Login_Google),
                  onPressed: () {
                    _googleLogin.signIn().then((userModel) {
                      this._userModel.bing(userModel);
                      _dao.insertUser(userModel).then((_) {
                        Navigator.pushNamed(context, "/setting");
                      }).catchError((error, stacktrace) => _handleError(
                          error, stacktrace,
                          userMessage:
                              AppLocalization.getWithKey(Keys.Errors_Login)));
                    }).catchError((error, stacktrace) => _handleError(
                        error, stacktrace,
                        userMessage:
                            AppLocalization.getWithKey(Keys.Errors_Login)));
                  }),
              makeVisibleComponent(
                  Divider(color: Theme.of(context).backgroundColor),
                  Theme.of(context).platform == TargetPlatform.iOS),
              makeVisibleComponent(
                  _signInButton(
                      buttonsType: Buttons.AppleDark,
                      buttonText: AppLocalization.getWithKey(
                          Keys.Generic_Messages_Login_Apple),
                      onPressed: () {
                        _appleLogin.signIn().then((userModel) {
                          this._userModel.bing(userModel);
                          _dao.insertUser(userModel).then((_) {
                            Navigator.pushNamed(context, "/setting");
                          }).catchError((error, stacktrace) => _handleError(
                              error, stacktrace,
                              userMessage: AppLocalization.getWithKey(
                                  Keys.Errors_Login)));
                        }).catchError((error, stacktrace) => _handleError(
                            error, stacktrace,
                            userMessage:
                                AppLocalization.getWithKey(Keys.Errors_Login)));
                      }),
                  Theme.of(context).platform == TargetPlatform.iOS),
              Spacer()
            ],
          ),
        ),
      )),
    );
  }

  FutureOr<Null> _handleError(dynamic error, dynamic stacktrace,
      {String? userMessage}) async {
    _logger.e(error);
    _logger.e(stacktrace);
    if (userMessage != null) {
      showSnackBar(context, userMessage);
    }
  }

  Widget _signInButton(
      {required Buttons buttonsType,
      required String buttonText,
      required VoidCallback onPressed}) {
    return SignInButton(
      buttonsType,
      padding: const EdgeInsets.all(5),
      text: buttonText,
      onPressed: onPressed,
    );
  }
}
