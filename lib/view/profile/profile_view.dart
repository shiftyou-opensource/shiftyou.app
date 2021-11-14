import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/utils/generic_components.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key, required this.userModel}) : super(key: key);

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: makeScrollView(context, [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          makeIconProfile(
              context: context, image: Image.asset("assets/ic_launcher.png")),
          Text("Adding content here"),
          makeButton(context,
              text: AppLocalization.getWithKey(Keys.Floatingbutton_Logout),
              icon: Icon(Icons.logout),
              // TODO we need a provider here because we have two type of login
              onPress: () => print("On logout"))
        ],
      ),
    ]));
  }
}
