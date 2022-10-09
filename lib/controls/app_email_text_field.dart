import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppEmailOnChangedCallback = void Function(String value);

const InputDecoration kAppEmailInputDecoration = InputDecoration(
  fillColor: kAppBackgroundColor,
  filled: true,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kAppPrimaryColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kAppFocusColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const TextStyle kAppEmailTextStyle = TextStyle(
  color: kAppForegroundColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppEmailTextField extends StatefulWidget {
  final AppEmailOnChangedCallback onChanged;
  final String hintText;
  final bool focus;
  final String initialValue;

  const AppEmailTextField(
      {Key? key, required this.onChanged, required this.hintText, this.focus = false, this.initialValue = ''})
      : super(key: key);

  @override
  State<AppEmailTextField> createState() => _AppEmailTextFieldState();
}

class _AppEmailTextFieldState extends State<AppEmailTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.left,
      onChanged: widget.onChanged,
      style: kAppEmailTextStyle,
      autofocus: widget.focus,
      decoration: kAppEmailInputDecoration.copyWith(hintText: widget.hintText),
    );
  }
}
