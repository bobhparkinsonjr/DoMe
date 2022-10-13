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
  final Widget? prevChild;
  final Widget? nextChild;

  const AppPrimaryPrompt({Key? key, required this.prompt, this.prevChild, this.nextChild}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (prevChild != null || nextChild != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: prevChild != null,
            child: (prevChild != null) ? prevChild! : Container(),
          ),
          const SizedBox(width: 2.0),
          Text(
            prompt.toUpperCase(),
            style: kAppPrimaryPromptTextStyle,
            textAlign: TextAlign.left,
          ),
          const SizedBox(width: 2.0),
          Visibility(
            visible: nextChild != null,
            child: (nextChild != null) ? nextChild! : Container(),
          ),
        ],
      );
    }

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
