import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kAppLabelTextStyle = TextStyle(
  fontSize: 18.0,
  color: kAppLabelTextColor,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

///////////////////////////////////////////////////////////////////////////////////////////////////

enum AppLabelAlign {
  left,
  center,
  right,
}

class AppLabel extends StatelessWidget {
  final String message;
  final bool visible;
  final AppLabelAlign labelAlign;

  const AppLabel({Key? key, required this.message, this.visible = true, this.labelAlign = AppLabelAlign.left})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        mainAxisAlignment: _getAlignment(),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 4.0,
              left: 18.0,
              right: 18.0,
            ),
            child: Text(
              message,
              style: kAppLabelTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  MainAxisAlignment _getAlignment() {
    switch (labelAlign) {
      case AppLabelAlign.left:
        return MainAxisAlignment.start;

      case AppLabelAlign.center:
        return MainAxisAlignment.center;

      case AppLabelAlign.right:
        return MainAxisAlignment.end;

      default:
        // empty
        break;
    }

    return MainAxisAlignment.start;
  }
}
