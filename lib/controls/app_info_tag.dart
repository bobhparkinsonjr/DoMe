import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kAppInfoTagTextStyle = TextStyle(
  fontSize: 14.0,
  color: kAppInfoTextColor,
  shadows: [
    Shadow(
      blurRadius: 1.0,
      color: Color(0xC0000000),
      offset: Offset(1.0, 1.0),
    ),
  ],
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppInfoTag extends StatelessWidget {
  final String message;
  final bool visible;

  const AppInfoTag({Key? key, required this.message, this.visible = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 4.0,
              left: 18.0,
              right: 18.0,
            ),
            child: Text(
              message,
              style: kAppInfoTagTextStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
