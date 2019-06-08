import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/time_utils.dart';
import './transitioner.dart';
import '../scoped_models/event_model.dart';

class EventTile extends StatefulWidget {
  final Event event;
  final AnimationController animation;
  final Function deleteEvent;
  final double iconAnimationValue;

  static BorderRadiusGeometry borderRadius = BorderRadius.circular(22.0);

  EventTile({
    @required this.event,
    @required this.animation,
    @required this.deleteEvent,
    this.iconAnimationValue = 0,
    Key key,
  })  : assert(event != null),
        assert(animation != null),
        super(key: key);

  @override
  _EventTileState createState() => _EventTileState();
}

class _EventTileState extends State<EventTile>
    with SingleTickerProviderStateMixin {
  AnimationController _iconAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimation = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500,
      ),
      value: widget.iconAnimationValue,
    );
    widget.animation.addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.animation.removeListener(_listener);
    _iconAnimation.dispose();
  }

  void _listener() {
    if (widget.animation.isDismissed) {
      _iconAnimation.animateTo(
        0,
        duration: Duration(),
      );
    }
  }

  void _onLongPress() {
    if (widget.animation.value < 0.5) {
      widget.animation.forward();
      _iconAnimation.animateTo(
        1,
        duration: Duration(),
      );
      _select();
    } else {
      _toggleSelected();
    }
  }

  void _onTap() {
    if (widget.animation.value > 0.5) {
      _toggleSelected();
    } else {
      _editEvent();
    }
  }

  void _editEvent() async {
    final argument = await Navigator.pushNamed(
      context,
      "/addEvent",
      arguments: widget.event,
    );
    if (argument == null) return;
    if (argument is Event) {
      setState(() {
        EventModel model = EventModel.of(context);

        model.modify(
          widget.event,
          Event(
            name: argument.name,
            id: widget.event.id,
            time: argument.time,
          ),
        );
      });
    } else if (argument is bool) {
      if (argument) {
        widget.deleteEvent(widget.event);
      }
    }
  }

  void _toggleSelected() {
    bool add = _iconAnimation.value < 0.5;
    _iconAnimation.fling(
      velocity: add ? 1 : -1,
    );
    EventModel model = EventModel.of(context);
    if (add) {
      model.addToSelectedEvents(widget.event);
    } else {
      model.removeFromSelectedEvents(widget.event);
    }
  }

  void _select() {
    EventModel.of(context).addToSelectedEvents(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AnimationController animation = widget.animation;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        Widget icon = Expanded(
          flex: 0,
          child: Container(
            alignment: Alignment.centerLeft,
            width: Curves.easeInOutCubic.transform(animation.value) * 50,
            child: ScaleTransition(
              alignment: Alignment.center,
              scale: animation,
              child: Transitioner(
                child1: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).accentColor,
                ),
                child2: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).accentColor,
                ),
                animation: _iconAnimation,
              ),
            ),
          ),
        );

        Widget text = Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.event.name,
                style: textTheme.title,
              ),
              SizedBox(height: 4.0),
              widget.event.time != null
                  ? Text(
                      timeToString(widget.event.time),
                      style: textTheme.subtitle,
                    )
                  : Container(),
            ],
          ),
        );

        return Container(
          margin: EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            borderRadius: EventTile.borderRadius,
            color: Color.lerp(
              Theme.of(context).cardColor,
              Theme.of(context).indicatorColor,
              Curves.easeInOutCubic.transform(animation.value),
            ),
          ),
          child: InkWell(
            borderRadius: EventTile.borderRadius,
            onTap: _onTap,
            onLongPress: _onLongPress,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 22.0),
              child: Row(
                children: <Widget>[
                  icon,
                  text,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
