import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const BoxDecoration kAppTooltipBackdropStyle = BoxDecoration(
  color: Color(0xFA666666),
  borderRadius: BorderRadius.all(Radius.circular(20.0)),
);

const TextStyle kAppTooltipTextStyle = TextStyle(
  fontSize: 12.0,
  color: Color(0xFFEAEA98),
  fontWeight: FontWeight.normal,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppTooltip extends StatelessWidget {
  const AppTooltip({Key? key, required this.child, required this.message}) : super(key: key);

  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      textStyle: kAppTooltipTextStyle,
      decoration: kAppTooltipBackdropStyle,
      child: child,
    );
  }
}
