import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/actions/auth/auth_provider.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/utils/app_preferences.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:nurse_time/utils/icon_provider.dart';

class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  AuthProvider? _authProvider;
  late DAODatabase _dao;
  late UserModel _userModel;
  late ShiftScheduler _scheduler;
  late Logger _logger;

  _LoginView() {
    this._logger = GetIt.instance<Logger>();
    this._dao = GetIt.instance.get<DAODatabase>();
    this._userModel = GetIt.instance.get<UserModel>();
    this._scheduler = GetIt.instance.get<ShiftScheduler>();
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
          title: AppLocalization.getWithKey(Keys.Generic_Messages_Upgrade_Info),
          message: message,
          imageProvided: IconProvider.instance.getImage(AppIcon.SORRY),
        );
      }
    });
    this._userModel = GetIt.instance.get<UserModel>();
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
                    _authProvider =
                        AuthProvider.build(provider: AuthProvider.GOOGLE);
                    if (!GetIt.instance.isRegistered<AuthProvider>()) {
                      GetIt.instance
                          .registerSingleton<AuthProvider>(_authProvider!);
                    }
                    AppPreferences.instance.putValue(
                        PreferenceKey.LOGIN_PROVIDER, AuthProvider.GOOGLE);
                    _authProvider?.login().then((userModel) {
                      this._userModel.bind(userModel);
                      _logger.d("Login view with use mode $_userModel");
                      _logger.d(
                          "Received from GetIt the following scheduler $_scheduler");
                      if (this._scheduler.isOwner(_userModel)) {
                        _logger.d(
                            "After login the user is logged -> ${_userModel.logged}");
                        _dao
                            .updateUser(_userModel)
                            .then((_) => Navigator.pushNamed(context, "/home"))
                            .catchError((error, stacktrace) => _handleError(
                                error, stacktrace,
                                userMessage: AppLocalization.getWithKey(
                                    Keys.Errors_Login)));
                        return;
                      }
                      _dao.insertUser(userModel).then((id) {
                        // bind the address to the user model.
                        _userModel.id = id;
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
                  Platform.isIOS),
              makeVisibleComponent(
                  _signInButton(
                      buttonsType: Buttons.AppleDark,
                      buttonText: AppLocalization.getWithKey(
                          Keys.Generic_Messages_Login_Apple),
                      onPressed: () {
                        _authProvider =
                            AuthProvider.build(provider: AuthProvider.APPLE);
                        if (!GetIt.instance.isRegistered<AuthProvider>()) {
                          GetIt.instance
                              .registerSingleton<AuthProvider>(_authProvider!);
                        }
                        AppPreferences.instance.putValue(
                            PreferenceKey.LOGIN_PROVIDER, AuthProvider.APPLE);
                        _authProvider?.login().then((userModel) {
                          this._userModel.bind(userModel);
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
                  Platform.isIOS),
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
