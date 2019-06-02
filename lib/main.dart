import 'package:flutter/material.dart';
import 'package:reminders/routes/home_route.dart';
import 'package:scoped_model/scoped_model.dart';

import './scoped_models/event_model.dart';
import './routes/add_event_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  EventModel _eventModel;

  @override
  void initState() {
    _eventModel = EventModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<EventModel>(
      model: _eventModel,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          cardColor: Color(0x42ffffff),
          indicatorColor: Colors.deepPurpleAccent[200].withAlpha(32),
          primaryColor: Color(0xff303030),
          canvasColor: Color(0xff212121),
          disabledColor: Color(0x42ffffff),
          accentColor: Colors.deepPurpleAccent[200],
          textTheme: TextTheme(
            display4: TextStyle(
              color: Colors.white,
              fontSize: 52.0,
              fontWeight: FontWeight.w200,
            ),
            headline: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 32.0,
            ),
            title: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 22.0,
            ),
            button: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
            subtitle: TextStyle(
              color: Colors.white54,
              fontSize: 12.0,
              fontWeight: FontWeight.w300,
            ),
            caption: TextStyle(
              color: Colors.white54,
              fontSize: 22.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        routes: {
          "/": (BuildContext context) => HomeRoute(),
          "/addEvent": (BuildContext context) => AddEventRoute(),
        },
      ),
    );
  }
}
