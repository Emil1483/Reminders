import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/time_utils.dart';

class EventTile extends StatefulWidget {
  final Event event;
  final AnimationController animation;

  EventTile({
    @required this.event,
    @required this.animation,
  })  : assert(event != null),
        assert(animation != null);

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
    );
  }

  @override
  void dispose() {
    super.dispose();
    _iconAnimation.dispose();
  }

  void _onLongPress() {
    if (widget.animation.value < 0.5) {
      widget.animation.forward();
      _iconAnimation.animateTo(
        1,
        duration: Duration(),
      );
    }
  }

  void _onTap() {
    _iconAnimation.fling(
      velocity: _iconAnimation.value < 0.5 ? 1 : -1,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    BorderRadiusGeometry borderRadius = BorderRadius.circular(22.0);
    AnimationController animation = widget.animation;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (BuildContext context, Widget child) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            bottom: 8.0,
            left: 8.0,
            right: 8.0,
          ),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Color.lerp(
              Theme.of(context).cardColor,
              Theme.of(context).indicatorColor,
              Curves.easeInOutCubic
                  .transform(Curves.easeInOutCubic.transform(animation.value)),
            ),
          ),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: _onTap,
            onLongPress: _onLongPress,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 22.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 0,
                    child: Container(
                      width:
                          Curves.easeInOutCubic.transform(animation.value) * 50,
                      child: ScaleTransition(
                        alignment: Alignment.center,
                        scale: animation,
                        child: AnimatedIcon(
                          icon: AnimatedIcons.list_view,
                          progress: _iconAnimation,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
