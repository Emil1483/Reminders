import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './event_tile.dart';
import '../models/event.dart';
import '../scoped_models/event_model.dart';

class EventList extends StatelessWidget {
  final AnimationController controller;
  final animatedListKey = GlobalKey<AnimatedListState>();

  EventList({
    @required this.controller,
  }) : assert(controller != null);

  void removeSelectedItems(BuildContext context) {
    EventModel model = EventModel.of(context);
    List<int> indexes = model.selectedEvents.map(
      (Event e) {
        return model.events.indexOf(e);
      },
    ).toList();

    for (int index in indexes) {
      EventTile eventTile = EventTile(
        animation: controller,
        event: model.events[index],
      );
      animatedListKey.currentState.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return _slideOutEventTile(context, animation, eventTile);
        },
        duration: Duration(milliseconds: 5000),
      );
    }

    model.completeSelectedEvents();
  }

  void insertItem({
    @override BuildContext context,
    @override Event event,
  }) {
    EventModel model = EventModel.of(context);
    model.addEvent(event);
    animatedListKey.currentState.insertItem(model.events.length - 1);
  }

  Animation<Offset> _getPosition(Animation<double> animation) {
    return Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    )
        .chain(
          CurveTween(
            curve: Curves.easeOutCubic,
          ),
        )
        .animate(animation);
  }

  Widget _slideOutEventTile(
    BuildContext context,
    Animation<double> animation,
    EventTile eventTile,
  ) {
    return SlideTransition(
      position: _getPosition(animation),
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return Container(
            height: (animation.value) * 100,
            color: Colors.blue,
            child: ClipRRect(
              borderRadius: EventTile.borderRadius,
              child: SingleChildScrollView(
                child: eventTile,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, EventModel model) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: AnimatedList(
            key: animatedListKey,
            shrinkWrap: true,
            initialItemCount: model.events.length,
            itemBuilder:
                (BuildContext context, int index, Animation<double> animation) {
              return SlideTransition(
                position: _getPosition(animation),
                child: EventTile(
                  event: model.events[index],
                  animation: controller,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
