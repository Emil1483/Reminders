import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:path_provider/path_provider.dart';

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
  List<Event> _deadEvents = [];
  bool _killingEvents = false;
  bool _isLoading = true;

  EventModel() {
    _loadEvents();
  }

  List<Event> get selectedEvents => List.from(_selectedEvents);

  bool get isLoading => _isLoading;

  Future<File> _getFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/events.json");
  }

  void _loadEvents() async {
    File file = await _getFile();
    try {
      String jsonString = await file.readAsString();
      Map<String, dynamic> data = json.decode(jsonString);
      print(jsonString);
      _events = Event.listFromJson(data);
    } catch (e) {
      file.writeAsString(json.encode({}));
    }
    _isLoading = false;
    notifyListeners();
  }

  void _uploadEvent(Event event) async {
    final File file = await _getFile();
    final String jsonString = await file.readAsString();
    Map<String, dynamic> data = json.decode(jsonString);
    data.addAll(event.toJson());
    await file.writeAsString(json.encode(data));
  }

  void _updateEventInJson(Event event) async {
    final File file = await _getFile();
    final String jsonString = await file.readAsString();
    Map<String, dynamic> data = json.decode(jsonString);
    data[event.id.toString()] = event.toPartJson();
    await file.writeAsString(json.encode(data));
  }

  void _deleteEventInJson(Event event) async {
    if (_killingEvents) {
      _deadEvents.add(event);
      return;
    }
    _killingEvents = true;
    final File file = await _getFile();
    final String jsonString = await file.readAsString();
    Map<String, dynamic> data = json.decode(jsonString);
    data.remove(event.id.toString());
    await file.writeAsString(json.encode(data));
    _killingEvents = false;
    if (_deadEvents.length > 0) {
      _deleteEventInJson(_deadEvents[0]);
      _deadEvents.removeAt(0);
    }
  }

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
    List<int> indexes = _selectedEvents.map(
      (Event e) {
        return _events.indexOf(e);
      },
    ).toList();

    indexes.sort();
    for (int i = indexes.length - 1; i >= 0; i--) {
      Event selected = _events[i];
      deleteEvent(selected);
    }
    _selectedEvents.clear();
    notifyListeners();
  }

  List<Event> get events => List.from(_events);

  Event improved(Event event) {
    return Event(
      time: event.time,
      name: event.name != null ? event.name : "",
      id: _validNewId(event.id) ? event.id : _generateId(),
    );
  }

  void addEvent(Event event) {
    Event newEvent = improved(event);
    if (event.time != null) _scheduleNotification(newEvent);
    _events.add(newEvent);
    notifyListeners();
    _uploadEvent(newEvent);
  }

  void deleteEvent(Event event) {
    _cancelNotification(event.id);
    _deleteEventInJson(event);
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
            minutes: 15,
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
      time != null ? time : event.time,
      platformChannelSpecifics,
      payload: event.id.toString(),
    );
  }

  void modify(Event oldEvent, Event newEvent) {
    int index = _events.indexOf(oldEvent);
    _events.remove(oldEvent);
    _events.insert(index, newEvent);
    _updateEventInJson(newEvent);
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
