import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../ui_elements/event_list.dart';

class HomeRoute extends StatefulWidget {
  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute>
    with SingleTickerProviderStateMixin {
  ScrollController _controller;
  AnimationController _buttonAnim;

  final double _scrollBeforeButton = 50.0;

  @override
  void initState() {
    super.initState();

    _buttonAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      animationBehavior: AnimationBehavior.preserve,
    );
    _controller = ScrollController();
    _controller.addListener(
      () {
        _buttonAnim.animateTo(
          _controller.offset > _scrollBeforeButton ? 1 : 0,
        );
      },
    );
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
    _buttonAnim.dispose();
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
                  _controller.animateTo(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () => Navigator.pushNamed(context, "/addEvent"),
      ),
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _controller,
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "Reminder",
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  ButtonBar(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  EventList(),
                ]),
              ),
            ],
          ),
          _buildRaisedButton(),
        ],
      ),
    );
  }
}
