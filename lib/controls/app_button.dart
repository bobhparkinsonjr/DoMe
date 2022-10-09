import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

import 'clip_br_rect_shape.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppButtonOnPressCallback = void Function();

const TextStyle kAppButtonTextStyle = TextStyle(
  fontSize: 16.0,
  color: kAppForegroundColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppButton extends StatelessWidget {
  final String title;
  final AppButtonOnPressCallback onPress;
  final bool enabled;

  const AppButton({Key? key, required this.title, required this.onPress, this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x00FFFFFF),
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(
            color: kAppPrimaryColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Material(
            elevation: 8.0,
            color: enabled ? kAppPrimaryColor : kAppDisabledColor,
            borderRadius: BorderRadius.circular(30.0),
            child: MaterialButton(
              onPressed: enabled ? onPress : null,
              minWidth: 200.0,
              height: 42.0,
              child: Text(
                title,
                style: kAppButtonTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
