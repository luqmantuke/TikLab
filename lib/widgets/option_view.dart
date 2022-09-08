// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ButtonView extends StatelessWidget {
  Color color;
  String header;
  double padding;
  Color textColor;

  // ignore: use_key_in_widget_constructors
  ButtonView(this.color, this.header,
      {this.padding = 8, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        color: color,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(15))),
          child: Text(header,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 15)),
        ),
      ),
    );
  }
}
