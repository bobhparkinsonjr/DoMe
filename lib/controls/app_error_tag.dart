import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kAppErrorTagTextStyle = TextStyle(
  fontSize: 12.0,
  color: kAppErrorTextColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppErrorTag extends StatelessWidget {
  final String message;
  final bool visible;

  const AppErrorTag({Key? key, required this.message, this.visible = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 4.0,
          left: 18.0,
          right: 18.0,
        ),
        child: Text(
          message,
          style: kAppErrorTagTextStyle,
        ),
      ),
    );
  }
}
