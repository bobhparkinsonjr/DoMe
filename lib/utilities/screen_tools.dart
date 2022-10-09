import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ScreenTools {
  static bool isKeyboardShown(BuildContext context) {
    return (MediaQuery.of(context).viewInsets.bottom != 0);
  }

  static bool isScreenNarrow(BuildContext context) {
    return (MediaQuery.of(context).size.width < 500);
  }
}
