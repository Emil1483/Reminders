import 'package:flutter/material.dart';
import 'package:reminders/routes/about_route.dart';
import 'package:reminders/routes/home_route.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/services.dart';

import './scoped_models/event_model.dart';
import './routes/add_event_route.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  EventModel _eventModel;

  @override
  void initState() {
    _eventModel = EventModel();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state);
    if (state == AppLifecycleState.paused) {
      print("saving Data");
      _eventModel.saveData();
    }
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<EventModel>(
      model: _eventModel,
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          cardColor: Color(0x42ffffff),
          indicatorColor: Colors.deepPurpleAccent[200].withAlpha(32),
          primaryColor: Color(0xff303030),
          canvasColor: Color(0xff212121),
          dialogBackgroundColor: Color(0xff212121),
          disabledColor: Color(0x42ffffff),
          backgroundColor: Color(0xff424242),
          accentColor: Colors.deepPurpleAccent[200],
          brightness: Brightness.dark,
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
            subhead: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            body1: TextStyle(color: Colors.white),
          ),
        ),
        routes: {
          "/": (BuildContext context) => HomeRoute(),
          "/addEvent": (BuildContext context) => AddEventRoute(),
          "/about": (BuildContext context) => AboutRoute(),
        },
      ),
    );
  }
}
