import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppFormFieldSpacer extends StatelessWidget {
  final double spacerSize;

  const AppFormFieldSpacer({Key? key, this.spacerSize = 1.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 24.0 * spacerSize, width: 24.0 * spacerSize);
  }
}
