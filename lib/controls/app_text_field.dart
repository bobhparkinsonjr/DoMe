import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppTextFieldOnChangedCallback = void Function(String value);

const InputDecoration kAppTextFieldInputDecoration = InputDecoration(
  fillColor: kAppBackgroundColor,
  filled: true,
  counterText: '',
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
  // constraints: BoxConstraints(minWidth: 50.0, maxWidth: 400.0),
);

const TextStyle kAppTextFieldTextStyle = TextStyle(
  color: kAppForegroundColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppTextField extends StatefulWidget {
  final AppTextFieldOnChangedCallback onChanged;
  final String hintText;
  final String initialValue;
  final bool focus;
  final int maxLength;

  const AppTextField(
      {Key? key,
      required this.onChanged,
      required this.hintText,
      this.initialValue = '',
      this.focus = false,
      this.maxLength = -1})
      : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      // keyboardType: TextInputType.emailAddress,
      controller: _controller,
      textAlign: TextAlign.left,
      onChanged: widget.onChanged,
      style: kAppTextFieldTextStyle,
      autofocus: widget.focus,
      maxLength: (widget.maxLength > 0) ? widget.maxLength : null,
      decoration: kAppTextFieldInputDecoration.copyWith(hintText: widget.hintText),
    );
  }
}
