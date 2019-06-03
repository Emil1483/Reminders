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
}
