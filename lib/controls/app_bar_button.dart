import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

import 'clip_br_rect_shape.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppBarButtonOnPressCallback = void Function();

const TextStyle kAppBarButtonTextStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w900,
  color: kAppBarControlTextColor,
);

const double kAppBarButtonBorderRadius = 20.0;

const double kAppBarButtonIconSize = 20.0;
const Color kAppBarButtonIconColor = kAppBarControlTextColor;

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppBarButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final AppBarButtonOnPressCallback onPress;
  final bool enabled;
  final ImageProvider? fillImage;
  final double scale;

  const AppBarButton(
      {Key? key, this.title = '', this.icon, required this.onPress, this.enabled = true, this.fillImage, this.scale = 1.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double radius = kAppBarButtonBorderRadius * scale;
    return GestureDetector(
      onTap: enabled ? onPress : null,
      // behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
        child: Container(
          width: radius * 2.0,
          height: radius * 2.0,
          decoration: BoxDecoration(
            color: const Color(0x00FFFFFF),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: kAppBarControlFillColor,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: (fillImage != null)
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: fillImage!,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                      borderRadius: BorderRadius.circular(radius),
                    )
                  : BoxDecoration(
                      color: kAppBarControlFillColor,
                      borderRadius: BorderRadius.circular(radius),
                      /*
                        border: Border.all(
                          color: kAppBarControlColor,
                          width: 1,
                        ),
                        */
                    ),
              child: MaterialButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: null, // enabled ? onPress : null,
                minWidth: 1.0,
                height: 10.0,
                child: (icon != null)
                    ? Icon(
                        icon,
                        size: kAppBarButtonIconSize,
                        color: kAppBarButtonIconColor,
                      )
                    : Text(
                        title,
                        style: kAppBarButtonTextStyle,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
