import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const double kAppLabelFontSize = 18.0;

const TextStyle kAppLabelTextStyle = TextStyle(
  fontSize: kAppLabelFontSize,
  color: kAppLabelTextColor,
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

enum AppLabelAlign {
  left,
  center,
  right,
}

class AppLabel extends StatelessWidget {
  final String message;
  final bool visible;
  final AppLabelAlign labelAlign;
  final double scale;
  final bool expand;

  const AppLabel(
      {Key? key,
      required this.message,
      this.visible = true,
      this.labelAlign = AppLabelAlign.left,
      this.scale = 1.0,
      this.expand = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        mainAxisAlignment: _getAlignment(),
        children: [
          expand
              ? Expanded(
                  child: _getText(),
                )
              : _getText(),
        ],
      ),
    );
  }

  Widget _getText() {
    return Text(
      message,
      style: kAppLabelTextStyle.copyWith(fontSize: kAppLabelFontSize * scale),
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
