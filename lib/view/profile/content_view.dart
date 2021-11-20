import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/home/cards/simple_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class ContentView extends StatefulWidget {
  const ContentView({Key? key, required this.userModel}) : super(key: key);

  final UserModel userModel;

  @override
  State<StatefulWidget> createState() => _ContentView();
}

class _ContentView extends State<ContentView> {
  @override
  Widget build(BuildContext context) {
    return _makeContent(context: context);
  }

  void _launchURL(BuildContext context, String url) async =>
      await canLaunch(url)
          ? await launch(url,
              forceSafariVC: false,
              forceWebView: false,
              universalLinksOnly: true)
          : showSnackBar(context, "We can't perform the action");

  Widget _makeContent({required BuildContext context}) {
    return Column(
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
        Expanded(
            flex: 2,
            child: SimpleCard(
              elevation: 4,
              icon: Icon(FontAwesomeIcons.mailchimp),
              text: "Support by Email",
              onPress: () {
                _launchURL(context, "mailto:shiftyou.team@protonmail.com");
              },
            )),
        Expanded(
            flex: 2,
            child: SimpleCard(
              elevation: 4,
              icon: Icon(FontAwesomeIcons.instagram),
              text: "Instagram",
              onPress: () {
                _launchURL(
                    context, "https://www.instagram.com/shiftyou.social");
              },
            )),
        Expanded(
            flex: 2,
            child: SimpleCard(
              elevation: 4,
              icon: Icon(FontAwesomeIcons.telegram),
              text: "Telegram Support",
              onPress: () {
                _launchURL(context, "https://t.me/joinchat/Km4uiE4e78NlODc8");
              },
            )),
        Expanded(
            flex: 2,
            child: SimpleCard(
              elevation: 4,
              icon: Icon(FontAwesomeIcons.reddit),
              text: "Reddit",
              onPress: () {
                _launchURL(context, "https://www.reddit.com/r/shiftyou");
              },
            )),
        Expanded(
            flex: 2,
            child: SimpleCard(
              elevation: 4,
              icon: Icon(FontAwesomeIcons.star),
              text: "Rating and Share App",
              onPress: () {
                InAppReview.instance.isAvailable().then((value) {
                  if (value) {
                    InAppReview.instance.requestReview();
                  } else {
                    if (Platform.isIOS) {
                      _launchURL(context, "http://shorturl.at/otCQ5");
                    } else {
                      _launchURL(context, "http://shorturl.at/jnBHL");
                    }
                  }
                });
              },
            ))
      ],
    );
  }
}
