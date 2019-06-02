import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/time_utils.dart';

class EventTile extends StatelessWidget {
  final Event event;

  EventTile({@required this.event}) : assert(event != null);

  

 

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    BorderRadiusGeometry borderRadius = BorderRadius.circular(22.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: borderRadius,
      ),
      margin: EdgeInsets.only(
        bottom: 8.0,
        left: 8.0,
        right: 8.0,
      ),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                event.name,
                style: textTheme.title,
              ),
              SizedBox(height: 4.0),
              event.time != null
                  ? Text(
                      timeToString(event.time),
                      style: textTheme.subtitle,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
