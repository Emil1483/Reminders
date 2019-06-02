import 'package:flutter/material.dart';
import 'dart:async';

import '../models/event.dart';
import '../scoped_models/event_model.dart';
import '../utils/time_utils.dart';

class AddEventRoute extends StatefulWidget {
  @override
  _AddEventRouteState createState() => _AddEventRouteState();
}

class _AddEventRouteState extends State<AddEventRoute> {
  DateTime _eventDate;
  String _eventName = "";

  bool _shouldSetDate = true;

  static DateTime _initDate = DateTime.now().add(Duration(days: 1));

  static TimeOfDay _initTime = _roundedToHour(TimeOfDay.now());

  @override
  initState() {
    super.initState();
  }

  static TimeOfDay _roundedToHour(TimeOfDay dateTime) {
    int hour = dateTime.minute > 30 ? dateTime.hour + 1 : dateTime.hour;
    return TimeOfDay(
      hour: hour,
      minute: 0,
    );
  }

  static DateTime _flooredToDay(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day.floor(),
    );
  }

  Future<DateTime> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _initDate,
      firstDate: _flooredToDay(DateTime.now()),
      lastDate: DateTime(DateTime.now().year + 100),
    );
    return picked;
  }

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _initTime,
    );
    return picked;
  }

  Future<Null> _setEventDate(BuildContext context) async {
    DateTime date = await _selectDate(context);
    if (date == null) return;
    TimeOfDay time = await _selectTime(context);
    if (date == null || time == null) {
      _eventDate = null;
      return;
    }
    setState(() {
      _eventDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
    return;
  }

  Widget _buildTextField() {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(32.0),
      child: TextField(
        style: Theme.of(context).textTheme.title,
        onChanged: (String name) {
          setState(() {
            _eventName = name;
          });
        },
        decoration: InputDecoration(
          hintStyle: Theme.of(context).textTheme.caption,
          hintText: "Note",
        ),
      ),
    );
  }

  Widget _buildButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          child: Text(
            "No Notice",
            style: Theme.of(context).textTheme.button,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          color: _eventDate == null
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
          onPressed: () {
            setState(() {
              _eventDate = null;
            });
          },
        ),
        RaisedButton(
          child: Text(
            "Time",
            style: Theme.of(context).textTheme.button,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          color: _eventDate != null
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
          onPressed: () {
            _setEventDate(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    Future.delayed(Duration(seconds: 0)).then((_) {
      if (_shouldSetDate) _setEventDate(context);
      _shouldSetDate = false;
    });
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          EventModel.of(context).addEvent(
            Event(
              name: _eventName,
              time: _eventDate,
            ),
          );
          Navigator.pop(context);
        },
        child: Icon(Icons.done),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _eventName,
                          style: textTheme.display4,
                        ),
                        SizedBox(height: 4.0),
                        _eventDate != null
                            ? Text(
                                timeToString(_eventDate),
                                style: textTheme.subtitle,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildTextField(),
                  _buildButtonBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
