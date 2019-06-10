import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './event_tile.dart';
import '../models/event.dart';
import '../scoped_models/event_model.dart';

class EventList extends StatelessWidget {
  final AnimationController controller;
  final animatedListKey = GlobalKey<AnimatedListState>();
  final Duration _slideOutDuration = Duration(milliseconds: 800);

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
    indexes.sort();

    for (int i = indexes.length - 1; i >= 0; i--) {
      int index = indexes[i];
      Event event = model.events[index];
      animatedListKey.currentState.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return _slideOutEventTile(
            context: context,
            animation: animation,
            index: index,
            event: event,
          );
        },
        duration: _slideOutDuration,
      );
    }

    model.completeSelectedEvents();
  }

  void removeSingleItem(BuildContext context, Event event) {
    int index = EventModel.of(context).events.indexOf(event);
    animatedListKey.currentState.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        return _slideOutEventTile(
          context: context,
          animation: animation,
          index: index,
          event: event,
        );
      },
      duration: _slideOutDuration,
    );
    EventModel.of(context).deleteEvent(event);
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

  Widget _slideOutEventTile({
    @required BuildContext context,
    @required Animation<double> animation,
    @required int index,
    @required Event event,
  }) {
    GlobalKey key = GlobalKey();
    EventTile eventTile = EventTile(
      key: key,
      animation: controller,
      event: event,
      deleteEvent: (Event event) {},
      dying: true,
    );

    double height;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final RenderBox renderBox = key.currentContext.findRenderObject();
        height = renderBox.size.height;
      },
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        double value1 = Curves.easeIn.transform(
          math.min(1, 2 - animation.value * 2),
        );
        double value2 = Curves.easeInOutCubic.transform(
          math.max(0, 1 - animation.value * 2),
        );
        return Container(
          height: height != null ? (1 - value2) * height : null,
          child: SingleChildScrollView(
            child: Transform(
              transform: Matrix4.identity()
                ..translate(
                  value1 * MediaQuery.of(context).size.width,
                ),
              child: eventTile,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, EventModel model) {
        if (model.isLoading) return Container();
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: AnimatedList(
            key: animatedListKey,
            shrinkWrap: true,
            initialItemCount: model.events.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder:
                (BuildContext context, int index, Animation<double> animation) {
              return SlideTransition(
                position: _getPosition(animation),
                child: EventTile(
                  event: model.events[index],
                  animation: controller,
                  deleteEvent: (Event event) =>
                      removeSingleItem(context, event),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
