import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final Widget child;
  final Widget mainIconFront;
  final Widget mainIconBack;
  final Color mainColor;
  final Object heroTag;
  final bool shrinkChildren;

  CustomButton({
    @required this.child,
    this.mainIconFront = const Icon(Icons.more_horiz),
    this.mainIconBack = const Icon(Icons.close),
    this.shrinkChildren = true,
    this.mainColor,
    this.heroTag,
    Key key,
  })  : assert(child != null),
        super(key: key);

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    if (_controller.isDismissed)
      _controller.forward();
    else
      _controller.reverse();
  }

  void up() {
    _controller.forward();
  }

  void down() {
    _controller.reverse();
  }

  double _getSize(double t) {
    double newT = Curves.easeInOutCubic.transform(t);
    return (math.cos(newT * 2 * math.pi) + 1) / 2;
  }

  double _getRotation(double t) {
    double newT = Curves.easeInOutCubic.transform(t);
    return newT * math.pi / 2;
  }

  Widget _buildSmallButtons() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        double val = Curves.easeInOutCubic.transform(
          1 - _controller.value,
        );

        return Transform(
          alignment: Alignment.centerRight,
          transform: Matrix4.identity()..rotateY(val * math.pi / 2),
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: widget.child,
          ),
        );
      },
    );
  }

  Widget _buildMainButton() {
    return IconButton(
      onPressed: _animate,
      color: Colors.white,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(_getSize(_controller.value))
              ..rotateZ(_getRotation(_controller.value)),
            child: _controller.value <= 0.5
                ? widget.mainIconFront
                : widget.mainIconBack,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildSmallButtons(),
        _buildMainButton(),
      ],
    );
  }
}
