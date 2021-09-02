import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timeline/event_item.dart';
import 'package:flutter_timeline/indicator_position.dart';

abstract class AbstractIndicatorStep {
  final Widget _title;
  final Widget indicator;

  AbstractIndicatorStep(this._title,
      {this.indicator = const Icon(Icons.donut_large)});

  Widget get title => _title;

  TimelineEventDisplay build(BuildContext context) {
    return TimelineEventDisplay(
        anchor: IndicatorPosition.top,
        indicatorOffset: Offset(0, 35),
        child: Card(
          child: TimelineEventCard(
              title: title,
              content: Expanded(
                flex: 5,
                child: this.buildView(context),
              )),
        ),
        indicatorSize: 25,
        indicator: indicator);
  }

  Widget buildView(BuildContext context);
}
