import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_time/utils/icon_provider.dart';

Widget buildUserIcon(BuildContext context, String imageUrl) {
  return CircleAvatar(
    backgroundColor: Theme.of(context).colorScheme.primaryVariant,
    radius: 60.0,
    child: CircleAvatar(
      radius: 50.0,
      backgroundImage: NetworkImage(imageUrl),
      backgroundColor: Colors.transparent,
    ),
  );
}

Widget buildAppLogo(BuildContext context, double dimemsion) {
  return Image.asset("ic_launcher");
}

BottomNavyBarItem makeItem(BuildContext context, String title, IconData icon,
    int index, int actualIndex) {
  bool selected = index == actualIndex;
  return BottomNavyBarItem(
    icon: Icon(icon,
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyText1!.color!),
    title: Text(title),
    activeColor: selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).textTheme.bodyText1!.color!,
    textAlign: TextAlign.center,
  );
}

/// This method build a text component to make sure that the title of the radio title
/// have the active color when it is active on the UI.
/// TODO: This change should be done by flutter theme, and this mean that I'm missing somethings in the code.
Text makeRadioTitle(BuildContext context, String message, bool active) {
  return Text(message,
      style: Theme.of(context).textTheme.bodyText1!.apply(
          color: active
              ? Theme.of(context).toggleableActiveColor
              : Theme.of(context).textTheme.bodyText1!.color));
}

/// Make a component that is able to be hidden when the propriety visible is false
Visibility makeVisibleComponent(Widget widget, bool visible,
    {bool disappear = false}) {
  return Visibility(
    child: widget,
    maintainSize: !disappear,
    maintainAnimation: true,
    maintainState: true,
    visible: visible,
  );
}

enum ButtonType { NORMAL }

Widget makeButton(BuildContext context,
    {required Function onPress,
    Icon icon = const Icon(Icons.done),
    required String text,
    bool disabled = false,
    ButtonType type = ButtonType.NORMAL,
    ButtonStyle? style}) {
  switch (type) {
    case ButtonType.NORMAL:
      return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            primary: !disabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => disabled ? () {} : onPress(),
          icon: icon,
          label: Text(text));
  }
}

class ConstrainedWidthFlexible extends StatelessWidget {
  final double minWidth;
  final double maxWidth;
  final int flex;
  final int flexSum;
  final Widget child;
  final BoxConstraints outerConstraints;

  ConstrainedWidthFlexible(
      {required this.minWidth,
      required this.maxWidth,
      required this.flex,
      required this.flexSum,
      required this.outerConstraints,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
      child: Container(
        width: _getWidth(outerConstraints.maxWidth),
        child: child,
      ),
    );
  }

  double _getWidth(double outerContainerWidth) {
    return outerContainerWidth * flex / flexSum;
  }
}

Widget makeTitleDivider(String titleString) {
  return Column(
    children: [
      Text(titleString),
      Divider(),
    ],
  );
}

// Todo use the convention wiht the {required Type Name}
CustomScrollView makeScrollView(BuildContext context, List<Widget> children) {
  return CustomScrollView(
    slivers: List<SliverList>.generate(
      children.length,
      (index) => SliverList(
          delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) => children[index],
              childCount: children.length)),
    ),
  );
}

// TODO adding method to customize the app
Widget makeIconProfile({required BuildContext context, required Image image}) {
  return Container(
    color: Theme.of(context).backgroundColor,
    child: Center(
      heightFactor: 1,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        radius: 60.0,
        child: CircleAvatar(
          radius: 50.0,
          child: image,
          backgroundColor: Colors.transparent,
        ),
      ),
    ),
  );
}

void showSnackBar(BuildContext context, String message,
    {Action? action, String label = "Close"}) {
  var snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed,
      backgroundColor: Theme.of(context).selectedRowColor,
      content: EmojiText(text: message),
      action: SnackBarAction(
          label: label,
          textColor: Theme.of(context).textTheme.button!.color,
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentSnackBar()));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showAppDialog(
    {required BuildContext context,
    required String title,
    required String message}) {
  print("Show message dialog");
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(title),
        content: SizedBox(
            height: 200,
            width: 400,
            child: Column(
              children: [
                Expanded(
                    flex: 6,
                    child: Image(
                        image: IconProvider.instance.getImage(AppIcon.SORRY))),
                Spacer(),
                Expanded(flex: 5, child: Text(message))
              ],
            )),
        actions: <Widget>[
          new TextButton(
            child: new Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

// Stackoverflow Solution: https://stackoverflow.com/a/56839834/10854225
class EmojiText extends StatelessWidget {
  final String text;

  const EmojiText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildText(context, this.text),
    );
  }

  TextSpan _buildText(BuildContext context, String text) {
    final children = <TextSpan>[];
    final runes = text.runes;

    for (int i = 0; i < runes.length; /* empty */) {
      int current = runes.elementAt(i);

      // we assume that everything that is not
      // in Extended-ASCII set is an emoji...
      final isEmoji = current > 255;
      final shouldBreak = isEmoji ? (x) => x <= 255 : (x) => x > 255;

      final chunk = <int>[];
      while (!shouldBreak(current)) {
        chunk.add(current);
        if (++i >= runes.length) break;
        current = runes.elementAt(i);
      }

      children.add(
        TextSpan(
            text: String.fromCharCodes(chunk),
            style: isEmoji
                ? TextStyle(
                    fontFamily: 'EmojiOne',
                  )
                : Theme.of(context).textTheme.subtitle1),
      );
    }

    return TextSpan(children: children);
  }
}
