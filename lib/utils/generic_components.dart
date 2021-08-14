import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildUserIcon(BuildContext context, String imageUrl) {
  return CircleAvatar(
    backgroundColor: Theme.of(context).buttonColor,
    radius: 60.0,
    child: CircleAvatar(
      radius: 50.0,
      backgroundImage: NetworkImage(imageUrl),
      backgroundColor: Colors.transparent,
    ),
  );
}

Widget buildAppLogo(BuildContext context, double dimesntion) {
  return Image.asset("ic_launcher");
}

BottomNavyBarItem makeItem(BuildContext context, String title, IconData icon,
    int index, int actualIndex) {
  bool selected = index == actualIndex;
  return BottomNavyBarItem(
    icon: Icon(icon,
        color: selected
            ? Theme.of(context).accentColor
            : Theme.of(context).textTheme.bodyText1!.color!),
    title: Text(title),
    activeColor: selected
        ? Theme.of(context).accentColor
        : Theme.of(context).textTheme.bodyText1!.color!,
    textAlign: TextAlign.center,
  );
}

void showSnackBar(BuildContext context, String message, {Action? action}) {
  var snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
          label: "Close",
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentSnackBar()));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
