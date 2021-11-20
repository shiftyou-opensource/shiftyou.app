import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/actions/auth/auth_provider.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/persistence/abstract_dao.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/profile/content_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key, required this.userModel}) : super(key: key);

  final UserModel userModel;

  FutureOr<Null> _handleError(dynamic error, dynamic stacktrace,
      {String? userMessage, required BuildContext context}) async {
    var _logger = GetIt.instance.get<Logger>();
    _logger.e(error);
    _logger.e(stacktrace);
    if (userMessage != null) {
      showSnackBar(context, userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            flex: 1,
            child: makeIconProfile(
                context: context,
                image: Image.asset("assets/ic_launcher.png"))),
        Expanded(flex: 5, child: ContentView(userModel: userModel)),
        Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.fromLTRB(100, 20, 100, 20),
              child: makeButton(context,
                  text: AppLocalization.getWithKey(Keys.Floatingbutton_Logout),
                  disabled: true,
                  icon: Icon(Icons.logout),
                  // TODO we need a provider here because we have two type of login
                  onPress: () {
                var _authProvider = GetIt.instance.get<AuthProvider>();
                _authProvider.logOut().then((value) async {
                  if (value) {
                    userModel.logged = false;
                    await GetIt.instance
                        .get<AbstractDAO>()
                        .updateUser(userModel);
                  } else {
                    showSnackBar(context,
                        AppLocalization.getWithKey(Keys.Errors_No_Logout));
                  }
                }).catchError((error, stacktrace) =>
                    _handleError(error, stacktrace, context: context));
              }),
            ))
      ],
    );
  }
}
