import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/event.dart';
import '../scoped_models/event_model.dart';

class TappedDialog extends StatefulWidget {
  final int eventId;
  final Function onComplete;

  TappedDialog({
    @required this.eventId,
    @required this.onComplete,
  });

  @override
  _TappedDialogState createState() => _TappedDialogState();
}

class _TappedDialogState extends State<TappedDialog> {
  Event _event;

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
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, EventModel model) {
        if (model.isLoading)
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                height: size.height < h + p * 2 ? size.height - p * 2 : h,
                width: size.width < w + p * 2 ? size.width - p * 2 : w,
                color: _switchAlphaWithShade(Theme.of(context).cardColor),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        if (_event == null) _event = model.getEventById(widget.eventId);
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
                          _event.name,
                          style: Theme.of(context).textTheme.headline,
                          textAlign: TextAlign.center,
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _buildButton(
                              context,
                              onPressed: () {
                                widget.onComplete();
                                if (Navigator.canPop(context))
                                  Navigator.pop(context);
                              },
                              text: "Complete",
                            ),
                            _buildButton(
                              context,
                              onPressed: () {
                                EventModel.of(context)
                                    .snoozeNotification(_event);
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
      },
    );
  }
}
