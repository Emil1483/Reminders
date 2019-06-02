import 'package:flutter/material.dart';

class Event {
  final DateTime time;
  final String name;

  Event({
    @required this.time,
    @required this.name,
  }) : assert(name != null);
}
