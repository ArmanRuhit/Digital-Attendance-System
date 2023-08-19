import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  ButtonWidget({this.buttonLabel, this.onPressed});

  final String buttonLabel;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.black,
        backgroundColor: Color(0xFFF66900),
        padding: EdgeInsets.all(8.0),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Colors.orangeAccent;
              else
                return null;
            }
        )
      ),
      onPressed: onPressed,
      child: Text(buttonLabel),
    );
  }
}