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

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
  }

  double _getValue() {
    double x = _controller.offset * 0.05;
    x = math.min(x, 1);
    x = math.max(x, 0);
    x = Curves.easeInCubic.transform(x);
    return x;
  }

  Widget _buildRaisedButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 32.0),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget child) {
            double value = _getValue();
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
