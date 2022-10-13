import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kAppTechLabelTextStyle = TextStyle(
  fontSize: 18.0,
  fontStyle: FontStyle.italic,
  color: kAppTechLabelTextColor,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

///////////////////////////////////////////////////////////////////////////////////////////////////

enum AppTechLabelAlign {
  left,
  center,
  right,
}

class AppTechLabel extends StatelessWidget {
  final String message;
  final bool visible;
  final AppTechLabelAlign labelAlign;

  const AppTechLabel({Key? key, required this.message, this.visible = true, this.labelAlign = AppTechLabelAlign.left})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        mainAxisAlignment: _getAlignment(),
        children: [
          Text(
            message,
            style: kAppTechLabelTextStyle,
          ),
        ],
      ),
    );
  }

  MainAxisAlignment _getAlignment() {
    switch (labelAlign) {
      case AppTechLabelAlign.left:
        return MainAxisAlignment.start;

      case AppTechLabelAlign.center:
        return MainAxisAlignment.center;

      case AppTechLabelAlign.right:
        return MainAxisAlignment.end;

      default:
        // empty
        break;
    }

    return MainAxisAlignment.start;
  }
}
