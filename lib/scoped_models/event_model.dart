import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

import '../models/event.dart';

class EventModel extends Model {
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  void initializeNotifications({Function(Event) onTappedNotification}) {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    Future onSelectNotification(String payload) async {
      Event selectedEvent = getEventById(int.parse(payload));
      if (onTappedNotification != null) onTappedNotification(selectedEvent);
    }

    Future onDidReceiveLocalNotification(
        int a, String b, String c, String d) async {}

    var init = InitializationSettings(
      AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
      IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      ),
    );
    _flutterLocalNotificationsPlugin.initialize(
      init,
      onSelectNotification: onSelectNotification,
    );
  }

  List<Event> _events = [];

  List<Event> _selectedEvents = [];

  List<Event> get selectedEvents => List.from(_selectedEvents);

  Event getEventById(int id) {
    for (Event event in _events) {
      if (event.id == id) return event;
    }
    return null;
  }

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
      deleteEvent(selected);
    }
    _selectedEvents.clear();
    notifyListeners();
  }

  List<Event> get events => List.from(_events);

  void addEvent(Event event) {
    Event newEvent = Event(
      time: event.time,
      name: event.name != null ? event.name : "",
      id: _validNewId(event.id) ? event.id : _generateId(),
    );
    _scheduleNotification(newEvent);
    _events.add(newEvent);
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _cancelNotification(event.id);
    _events.remove(event);
    notifyListeners();
  }

  void snoozeNotification(Event event) {
    if (!_events.contains(event)) return;
    _cancelNotification(event.id);
    _scheduleNotification(
      event,
      time: DateTime.now()
        ..add(
          Duration(
            seconds: 5,
          ),
        ),
    );
  }

  void _cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  void _scheduleNotification(Event event, {DateTime time}) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.schedule(
      event.id,
      'Reminder',
      event.name,
      time != null ? time : DateTime.now()
        ..add(Duration(seconds: 5)),
      platformChannelSpecifics,
      payload: event.id.toString(),
    );
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
