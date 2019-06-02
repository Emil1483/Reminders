import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './event_tile.dart';
import '../models/event.dart';
import '../scoped_models/event_model.dart';

class EventList extends StatelessWidget {
  final AnimationController controller;

  EventList({
    @required this.controller,
  }) : assert(controller != null);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, EventModel model) {
        int index = -1;
        return Column(
          children: model.events.map(
            (Event event) {
              index++;
              return Container(
                margin: EdgeInsets.only(
                  bottom: index >= model.events.length - 1 ? 112.0 : 0.0,
                ),
                child: EventTile(
                  event: event,
                  animation: controller,
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }
}
