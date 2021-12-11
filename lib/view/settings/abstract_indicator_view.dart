import 'package:flutter/material.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/utils/icon_provider.dart';

abstract class AbstractIndicatorStep {
  final Widget _title;
  final String messageTips;

  AbstractIndicatorStep(this._title, {required this.messageTips});

  Widget get title => _title;

  Card build(BuildContext context) {
    return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Column(children: [
          Container(
            margin: EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: _title,
                    ),
                    flex: 6),
                Expanded(
                    child: IconButton(
                      icon: Icon(Icons.contact_support_rounded),
                      onPressed: () => showAppDialog(
                        context: context,
                        title: AppLocalization.getWithKey(
                            Keys.Floatingbutton_Tips),
                        message: messageTips,
                        withIcon: false,
                        imageProvided:
                            IconProvider.instance.getImage(AppIcon.TIP),
                      ),
                    ),
                    flex: 1)
              ],
            ),
          ),
          this.buildView(context)
        ]));
  }

  Widget buildView(BuildContext context);
}
