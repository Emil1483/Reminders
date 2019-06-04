import 'package:flutter/material.dart';

class Event {
  DateTime time;
  String name;
  int id;

  Event({
    @required this.name,
    this.time,
    this.id,
  }) : assert(name != null);

  void modify(Event newEvent) {
    time = newEvent.time;
    name = newEvent.name;
  }
}
