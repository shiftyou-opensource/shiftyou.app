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
