import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  final double elevation;
  final String text;
  final Icon icon;
  final Function onPress;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const SimpleCard({
    Key? key,
    required this.icon,
    required this.elevation,
    required this.text,
    required this.onPress,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _makeContent(context: context);
  }

  Widget _makeContent({required BuildContext context}) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Container(
        padding: padding ?? EdgeInsets.all(10),
        margin: margin ?? EdgeInsets.all(10),
        child: InkWell(
            onTap: () => onPress(),
            child: Row(
              children: [
                Expanded(flex: 1, child: icon),
                Expanded(
                    flex: 5,
                    child: Text(
                      this.text,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .apply(fontSizeFactor: 1.2),
                    )),
              ],
            )),
      ),
    );
  }
}
