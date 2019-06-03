import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

import '../models/event.dart';

class EventModel extends Model {
  List<Event> _events = [
    Event(
      name: "Finish this app",
      time: DateTime.now(),
      id: 0,
    ),
    Event(
      name: "Finish this app",
      time: DateTime.now(),
      id: 1,
    ),
  ];

  List<Event> _selectedEvents = [];

  List<Event> get selectedEvents => List.from(_selectedEvents);

  void addToSelectedEvents(Event newEvent) {
    if (!_selectedEvents.contains(newEvent)) {
      _selectedEvents.add(newEvent);
      notifyListeners();
    }
  }

  void removeFromSelectedEvents(Event newEvent) {
    if (_selectedEvents.contains(newEvent)) {
      _selectedEvents.remove(newEvent);
      notifyListeners();
    }
  }

  void clearSelectedEvents() {
    _selectedEvents = [];
    notifyListeners();
  }

  void completeSelectedEvents() {
    for (Event selected in _selectedEvents) {
      _events.remove(selected);
    }
    _selectedEvents.clear();
    notifyListeners();
  }

  void deleteSelectedEvents() {
    for (Event selected in _selectedEvents) {
      _events.remove(selected);
    }
    _selectedEvents.clear();
    notifyListeners();
  }

  List<Event> get events => List.from(_events);

  void addEvent(Event event) {
    _events.add(
      Event(
        time: event.time,
        id: _validNewId(event.id) ? event.id : _generateId(),
        name: event.name.isNotEmpty ? event.name : "An unnamed reminder",
      ),
    );
    notifyListeners();
  }

  bool _validNewId(int id) {
    if (id == null) return false;
    if (id < 0) return false;
    for (Event e in _events) {
      if (e.id == id) return false;
    }
    return true;
  }

  int _generateId() {
    int id = 0;
    for (Event e in _events) {
      if (e.id > id) id = e.id;
    }
    return id + 1;
  }

  static EventModel of(BuildContext context) {
    return ScopedModel.of<EventModel>(context);
  }
}
