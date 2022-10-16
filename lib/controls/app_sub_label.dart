import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kAppSubLabelTextStyle = TextStyle(
  fontSize: 16.0,
  fontStyle: FontStyle.italic,
  color: kAppSubLabelTextColor,
  height: 1.4,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

///////////////////////////////////////////////////////////////////////////////////////////////////

enum AppSubLabelAlign {
  left,
  center,
  right,
}

class AppSubLabel extends StatelessWidget {
  final String message;
  final bool visible;
  final AppSubLabelAlign labelAlign;

  const AppSubLabel({Key? key, required this.message, this.visible = true, this.labelAlign = AppSubLabelAlign.left})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        mainAxisAlignment: _getAlignment(),
        children: [
          SelectableText(
            message,
            style: kAppSubLabelTextStyle,
          ),
        ],
      ),
    );
  }

  MainAxisAlignment _getAlignment() {
    switch (labelAlign) {
      case AppSubLabelAlign.left:
        return MainAxisAlignment.start;

      case AppSubLabelAlign.center:
        return MainAxisAlignment.center;

      case AppSubLabelAlign.right:
        return MainAxisAlignment.end;

      default:
        // empty
        break;
    }

    return MainAxisAlignment.start;
  }
}
