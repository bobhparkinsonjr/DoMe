import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kAppLargeHeaderTextStyle = TextStyle(
  fontSize: 44.0,
  color: kAppPrimaryColor,
  letterSpacing: 1.3,
  shadows: [
    Shadow(
      blurRadius: 10.0,
      color: Color(0xC0000000),
      offset: Offset(3.0, 3.0),
    ),
  ],
);

const TextStyle kAppSmallHeaderTextStyle = TextStyle(
  fontSize: 22.0,
  color: kAppPrimaryColor,
  letterSpacing: 1.3,
  shadows: [
    Shadow(
      blurRadius: 10.0,
      color: Color(0xC0000000),
      offset: Offset(3.0, 3.0),
    ),
  ],
);

const double kAppHeaderLargeVerticalSpacing = 32.0;
const double kAppHeaderSmallVerticalSpacing = 12.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppHeader extends StatelessWidget {
  final bool visible;
  final bool large;

  const AppHeader({Key? key, this.visible = true, this.large = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: (large ? kAppHeaderLargeVerticalSpacing : kAppHeaderSmallVerticalSpacing)),
        child: Text(
          'DoMe',
          style: large ? kAppLargeHeaderTextStyle : kAppSmallHeaderTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
