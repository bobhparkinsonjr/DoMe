import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

import '../controls/clip_br_rect_shape_border.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const double kAppDialogIconSize = 50.0;
const double kAppDialogElevation = 10.0;

const TextStyle kAppDialogTitleTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: kAppDialogTitleColor,
);

const TextStyle kAppDialogContentTextStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
  color: kAppDialogContentColor,
);

const TextStyle kAppDialogButtonTextStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
  color: kAppDialogButtonColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

enum AppDialogResult {
  option1,
  option2,
  option3,
}

class AppDialog {
  static Future<AppDialogResult?> showChoiceDialog(
      {required BuildContext context,
      String title = '',
      required String content,
      required String option1,
      String? option2,
      String? option3,
      IconData? icon}) async {
    return showDialog<AppDialogResult?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: (icon != null) ? Icon(icon, size: kAppDialogIconSize, color: kAppErrorTextColor) : null,
          backgroundColor: kAppDialogBackgroundColor,
          title: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
          ),
          titleTextStyle: kAppDialogTitleTextStyle,
          content: SingleChildScrollView(
            child: Text(
              content,
              textAlign: TextAlign.center,
            ),
          ),
          contentTextStyle: kAppDialogContentTextStyle,
          actionsAlignment: MainAxisAlignment.start,
          actions: <Widget>[
            TextButton(
              child: Text(
                option1.toUpperCase(),
                style: kAppDialogButtonTextStyle,
              ),
              onPressed: () {
                Navigator.of(context).pop(AppDialogResult.option1);
              },
            ),
            Visibility(
              visible: option2 != null,
              child: TextButton(
                child: Text(
                  (option2 != null) ? option2.toUpperCase() : '',
                  style: kAppDialogButtonTextStyle,
                ),
                onPressed: () {
                  Navigator.of(context).pop(AppDialogResult.option2);
                },
              ),
            ),
            Visibility(
              visible: option3 != null,
              child: TextButton(
                child: Text(
                  (option3 != null) ? option3.toUpperCase() : '',
                  style: kAppDialogButtonTextStyle,
                ),
                onPressed: () {
                  Navigator.of(context).pop(AppDialogResult.option3);
                },
              ),
            ),
          ],
          shape: ClipBRRectShapeBorder(clipRatio: 0.35, maxSize: 20.0, thickness: 1.0, outlineColor: kAppDialogOutlineColor),
          elevation: kAppDialogElevation,
        );
      },
    );
  }
}
