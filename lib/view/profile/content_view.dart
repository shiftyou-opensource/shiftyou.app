import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/home/cards/simple_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentView extends StatelessWidget {
  const ContentView({Key? key, required this.userModel}) : super(key: key);

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return _makeContent(context: context);
  }

  FutureOr<bool> _handleError(
      BuildContext context, dynamic error, dynamic stacktrace,
      {String? userMessage}) async {
    var _logger = Logger(); // TODO: move this as propriety of the class
    _logger.e(error);
    _logger.e(stacktrace);
    if (userMessage != null) {
      showSnackBar(context, userMessage);
    }
    return true;
  }

  void _launchURL(BuildContext context, String url) async =>
      await canLaunchUrl(Uri.parse(url))
          ? await canLaunchUrl(Uri.parse(url)).catchError((error, stacktrace) =>
              _handleError(context, error, stacktrace,
                  userMessage:
                      AppLocalization.getWithKey(Keys.Errors_Open_Url)))
          : showSnackBar(context, "We can't perform the action");

  Widget _makeContent({required BuildContext context}) {
    return ListView(
        padding: EdgeInsets.only(left: 5, right: 5, top: 30, bottom: 30),
        children: [
          Column(
            children: [
              /*
        Expanded(
            flex: 2,
            child: SimpleCard(
              elevation: 4,
              icon: Icon(FontAwesomeIcons.userCircle),
              text: "Info Profile",
              onPress: () {
                showSnackBar(context, "We are working in progress");
              },
            )), */
              SimpleCard(
                elevation: 4,
                icon: Icon(FontAwesomeIcons.envelope),
                text: "Support by Email",
                onPress: () {
                  _launchURL(context, "mailto:shiftyou.team@protonmail.com");
                },
              ),
              SimpleCard(
                elevation: 4,
                icon: Icon(FontAwesomeIcons.instagram),
                text: "Instagram",
                onPress: () {
                  _launchURL(
                      context, "https://www.instagram.com/shiftyou.social");
                },
              ),
              SimpleCard(
                elevation: 4,
                icon: Icon(FontAwesomeIcons.telegram),
                text: "Telegram Support",
                onPress: () {
                  _launchURL(context, "https://t.me/joinchat/Km4uiE4e78NlODc8");
                },
              ),
              SimpleCard(
                elevation: 4,
                icon: Icon(FontAwesomeIcons.reddit),
                text: "Reddit",
                onPress: () {
                  _launchURL(context, "https://www.reddit.com/r/shiftyou");
                },
              ),
              SimpleCard(
                elevation: 4,
                icon: Icon(FontAwesomeIcons.star),
                text: "Rating and Share App",
                onPress: () {
                  if (Platform.isIOS) {
                    _launchURL(context, "http://shorturl.at/otCQ5");
                  } else {
                    _launchURL(context, "http://shorturl.at/jnBHL");
                  }
                },
              )
            ],
          )
        ]);
  }
}
