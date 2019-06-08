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

  static List<Event> listFromJson(Map<String, dynamic> json) {
    List<Event> events = [];
    json.forEach(
      (String id, dynamic map) {
        events.add(
          Event(
            id: int.parse(id),
            name: map["name"],
            time: map["time"] == "-1" ? null : DateTime.parse(map["time"]),
          ),
        );
      },
    );
    return events;
  }

  Map<String, dynamic> toJson() {
    return {
      id.toString(): {
        "name": name,
        "time": time != null ? time.toString() : "-1",
      },
    };
  }

  Map<String, dynamic> toPartJson() {
    return {
      "name": name,
      "time": time.toString(),
    };
  }
}
