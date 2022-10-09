import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

import 'app_tooltip.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppLinkOnPressCallback = void Function();

const TextStyle kAppUrlLinkStyle = TextStyle(
  fontSize: 18.0,
  color: Color(0x00000000),
  decorationColor: Color(0xFFDDEBFF),
  fontStyle: FontStyle.italic,
  decoration: TextDecoration.underline,
  decorationThickness: 2.0,
  height: 1.4,
  shadows: [
    Shadow(
      blurRadius: 1.0,
      color: Color(0xC0000000),
      offset: Offset(-2.0, -2.0),
    ),
    Shadow(
      blurRadius: 1.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, -2.0),
    ),
    Shadow(
      blurRadius: 1.0,
      color: Color(0xC0000000),
      offset: Offset(-2.0, 2.0),
    ),
    Shadow(
      blurRadius: 1.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
    Shadow(
      blurRadius: 1.0,
      color: Color(0xFFDDEBFF), // Color(0xC0000000),
      offset: Offset(1.0, -3.0),
    ),
  ],
);

const TextStyle kAppUrlLinkHoverStyle = TextStyle(
  fontSize: 16.0,
  color: Color(0x00000000),
  decorationColor: Color(0xFFD67DFF),
  fontStyle: FontStyle.italic,
  decoration: TextDecoration.underline,
  decorationThickness: 2.0,
  height: 1.4,
  shadows: [
    Shadow(
      blurRadius: 1.0,
      color: Color(0xFFD67DFF), // Color(0xC0000000),
      offset: Offset(1.0, -3.0),
    ),
  ],
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppLink extends StatefulWidget {
  final String tooltip;
  final String linkName;
  final AppLinkOnPressCallback onPressed;

  const AppLink({Key? key, required this.tooltip, required this.linkName, required this.onPressed}) : super(key: key);

  @override
  State<AppLink> createState() => _AppLinkState();
}

class _AppLinkState extends State<AppLink> {
  bool _linkHover = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (e) {
          setState(() {
            _linkHover = true;
          });
        },
        onExit: (e) {
          setState(() {
            _linkHover = false;
          });
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          // behavior: HitTestBehavior.,
          child: AppTooltip(
            message: widget.tooltip,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0),
              child: Text(
                widget.linkName,
                style: _linkHover ? kAppUrlLinkHoverStyle : kAppUrlLinkStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
