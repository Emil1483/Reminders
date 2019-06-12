import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:reminders/scoped_models/event_model.dart';
import 'package:reminders/ui_elements/custom_button.dart';
import 'package:reminders/ui_elements/tapped_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

import '../ui_elements/event_list.dart';
import '../models/event.dart';

class HomeRoute extends StatefulWidget {
  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> with TickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _buttonAnim;
  AnimationController _selectionAnim;
  EventList _eventList;

  final double _scrollBeforeButton = 50.0;
  final double _bottomBarHeight = 72.0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _eventList = EventList(
      controller: _selectionAnim,
    );
    EventModel.of(context).initializeNotifications(
      onTappedNotification: (int eventId) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return TappedDialog(
              eventId: eventId,
              onComplete: () {
                Event event = EventModel.of(context).getEventById(eventId);
                if (EventModel.of(context).events.contains(event))
                  _eventList.removeSingleItem(context, event);
              },
            );
          },
        );
      },
    );
  }

  @override
  dispose() {
    super.dispose();
    _scrollController.dispose();
    _buttonAnim.dispose();
    _selectionAnim.dispose();
  }

  void _initAnimations() {
    _buttonAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      animationBehavior: AnimationBehavior.preserve,
    );

    _selectionAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    )..addListener(() {
        if (!_selectionAnim.isAnimating) setState(() {});
      });

    _scrollController = ScrollController()
      ..addListener(() {
        _buttonAnim.animateTo(
          _scrollController.offset > _scrollBeforeButton ? 1 : 0,
        );
      });
  }

  Widget _buildRaisedButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 32.0),
        child: AnimatedBuilder(
          animation: _buttonAnim,
          builder: (BuildContext context, Widget child) {
            double value = Curves.easeInOutCubic.transform(_buttonAnim.value);
            if (value == 0) return Container();

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX((1 - value) * math.pi / 2),
              child: RaisedButton(
                child: Text(
                  "Back to Top",
                  style: Theme.of(context).textTheme.button,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    curve: Curves.easeOutExpo,
                    duration: Duration(milliseconds: 800),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    ShapeBorder buttonBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    );
    return AnimatedBuilder(
      animation: _selectionAnim,
      builder: (BuildContext context, Widget child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
          ),
          height: Curves.easeInOutCubic.transform(_selectionAnim.value) *
              _bottomBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton.icon(
                shape: buttonBorder,
                textColor: Colors.white,
                label: Text("Cancel"),
                icon: Icon(
                  Icons.cancel,
                ),
                onPressed: () {
                  _selectionAnim.reverse();
                  EventModel.of(context).clearSelectedEvents();
                },
              ),
              ScopedModelDescendant(
                builder: (
                  BuildContext context,
                  Widget child,
                  EventModel model,
                ) {
                  return FlatButton.icon(
                    shape: buttonBorder,
                    disabledTextColor: Theme.of(context).disabledColor,
                    textColor: Colors.white,
                    label: Text("Complete"),
                    icon: Icon(Icons.delete),
                    onPressed: model.selectedEvents.isNotEmpty
                        ? () {
                            _selectionAnim.reverse();
                            _eventList.removeSelectedItems(context);
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomScrollView() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200.0,
          floating: true,
          pinned: true,
          backgroundColor: Colors.black,
          flexibleSpace: ScopedModelDescendant(
            builder: (BuildContext context, Widget child, EventModel model) {
              String text = !_selectionAnim.isCompleted
                  ? "Reminder"
                  : model.selectedEvents.isEmpty
                      ? "Select Reminders"
                      : "${model.selectedEvents.length} selected";
              return FlexibleSpaceBar(
                centerTitle: true,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              );
            },
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            ButtonBar(
              children: <Widget>[
                _buildCustomButton(),
              ],
            ),
            _eventList,
          ]),
        ),
      ],
    );
  }

  Widget _buildCustomButton() {
    GlobalKey<CustomButtonState> key = GlobalKey();
    return CustomButton(
      key: key,
      child: IconButton(
        icon: Icon(
          Icons.info,
          color: Colors.white,
        ),
        onPressed: () {
          key.currentState.down();
          Navigator.pushNamed(context, "/about");
        },
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _selectionAnim,
      builder: (BuildContext context, Widget child) {
        return Transform.scale(
          scale: Curves.easeInOutCubic.transform(1 - _selectionAnim.value),
          child: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).accentColor,
            onPressed: () async {
              if (_selectionAnim.value != 0) return;
              final newEvent = await Navigator.pushNamed(context, "/addEvent");
              if (newEvent == null) return;
              _eventList.insertItem(
                context: context,
                event: newEvent,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: _buildFAB(),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Stack(
              children: <Widget>[
                _buildCustomScrollView(),
                _buildRaisedButton(),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }
}
