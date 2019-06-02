import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

import '../models/event.dart';

class EventModel extends Model {
  List<Event> _events = [
    Event(
      name: "Finish this app",
      time: DateTime.now(),
    ),
    Event(
      name: "Finish this app",
      time: DateTime.now(),
    ),
  ];

  List<Event> get events => List.from(_events);

  void addEvent(Event event) {
    if (event.name.isEmpty) {
      _events.add(
        Event(
          time: event.time,
          name: "An unnamed reminder",
        ),
      );
      notifyListeners();
      return;
    }
    _events.add(event);
    notifyListeners();
  }

  static EventModel of(BuildContext context) {
    return ScopedModel.of<EventModel>(context);
  }
}
