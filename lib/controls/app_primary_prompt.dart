import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kAppPrimaryPromptTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: kAppPromptColor,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppPrimaryPrompt extends StatelessWidget {
  final String prompt;

  const AppPrimaryPrompt({Key? key, required this.prompt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      child: Text(
        prompt.toUpperCase(),
        style: kAppPrimaryPromptTextStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}
