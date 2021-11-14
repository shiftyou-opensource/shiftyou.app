import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/profile/content_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key, required this.userModel}) : super(key: key);

  final UserModel userModel;

  /*
  TODO adding as utils function
  FutureOr<Null> _handleError(dynamic error, dynamic stacktrace,
      {String? userMessage, required BuildContext context}) async {
    _logger.e(error);
    _logger.e(stacktrace);
    if (userMessage != null) {
      showSnackBar(context, userMessage);
    }
  }
  */

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
                showSnackBar(context, "No supported");
                /*
                      TODO: Need to alterate the table in the db and
                      var _authProvider = GetIt.instance.get<AuthProvider>();
                      _authProvider.logOut()
                          .then((value) => )
                          .catchError((error, stacktrace) => _handleError(error, stacktrace, context: context));
                       */
              }),
            ))
      ],
    );
  }
}
