import 'package:flutter/material.dart';

class Event {
  final DateTime time;
  final String name;
  final int id;

  Event({
    @required this.name,
    this.time,
    this.id,
  }) : assert(name != null);

  factory Event.fromJson(Map<String, dynamic> parsedJson) {
    return Event(
      name: parsedJson["name"],
      id: parsedJson["id"],
      time: parsedJson["time"],
    );
  }
}
