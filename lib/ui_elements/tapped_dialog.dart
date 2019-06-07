import 'package:flutter/material.dart';

import '../models/event.dart';
import '../scoped_models/event_model.dart';

class TappedDialog extends StatelessWidget {
  final Event event;
  final Function onComplete;

  TappedDialog({
    @required this.event,
    @required this.onComplete,
  });

  Color _switchAlphaWithShade(Color color) {
    return Color.fromARGB(
      255,
      color.alpha,
      color.alpha,
      color.alpha,
    );
  }

  Widget _buildButton(
    BuildContext context, {
    String text,
    Function onPressed,
  }) {
    return RaisedButton(
      onPressed: onPressed,
      color: Theme.of(context).accentColor,
      child: Text(
        text,
        style: Theme.of(context).textTheme.button,
        textAlign: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double h = 250;
    final double w = 350;
    final double p = 32;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          height: size.height < h + p * 2 ? size.height - p * 2 : h,
          width: size.width < w + p * 2 ? size.width - p * 2 : w,
          color: _switchAlphaWithShade(Theme.of(context).cardColor),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(22.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      event.name,
                      style: Theme.of(context).textTheme.headline,
                      textAlign: TextAlign.center,
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildButton(
                          context,
                          onPressed: () {
                            onComplete();
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                          },
                          text: "Complete",
                        ),
                        _buildButton(
                          context,
                          onPressed: () {
                            EventModel.of(context).snoozeNotification(event);
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                          },
                          text: "Snooze",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
