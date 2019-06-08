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

  void initializeNotifications({Function(int) onTappedNotification}) {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    Future onSelectNotification(String payload) async {
      int selectedEventId = int.parse(payload);
      if (onTappedNotification != null) onTappedNotification(selectedEventId);
    }

    Future onDidReceiveLocalNotification(
        int a, String b, String c, String d) async {}

    var init = InitializationSettings(
      AndroidInitializationSettings(
        'app_icon',
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
      _events = Event.listFromJson(data);
    } catch (e) {
      file.writeAsString(json.encode({}));
    }
    _isLoading = false;
    _events = [
      Event(name: "a", id: 0),
      Event(name: "b", id: 1),
      Event(name: "c", id: 2),
      Event(name: "d", id: 3),
      Event(name: "e", id: 4),
    ];
    notifyListeners();
  }

  void saveData() async {
    while (_isLoading) {
      await Future.delayed(Duration(milliseconds: 10));
    }
    final File file = await _getFile();
    Map<String, dynamic> data = {};
    for (Event event in _events) {
      data.addAll(event.toJson());
    }
    await file.writeAsString(json.encode(data));
  }

  Event getEventById(int id) {
    for (Event event in _events) {
      if (event.id == id) return event;
    }
    return null;
  }

  void printEvents() {
    for (int i = 0; i < _events.length; i++) {
      Event event = _events[i];
      print("index: $i, ${event.toString()}");
    }
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
    for (Event event in _selectedEvents) _events.remove(event);
    _selectedEvents.clear();
    notifyListeners();
  }

  List<Event> get events => List.from(_events);

  Event improved(Event event, {bool keepId = false}) {
    return Event(
      time: event.time,
      name: event.name != null ? event.name : "",
      id: keepId ? event.id : _validNewId(event.id) ? event.id : _generateId(),
    );
  }

  void addEvent(Event event) {
    Event newEvent = improved(event);
    if (event.time != null) _scheduleNotification(newEvent);
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
    DateTime newTime = DateTime.now().add(Duration(minutes: 15));
    _scheduleNotification(
      event,
      time: newTime,
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
    if (oldEvent.time != null) _cancelNotification(oldEvent.id);
    if (newEvent.time != null) _scheduleNotification(newEvent);
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
