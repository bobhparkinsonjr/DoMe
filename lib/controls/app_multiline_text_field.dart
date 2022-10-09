import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppMultilineTextFieldOnChangedCallback = void Function(String value);

const InputDecoration kAppMultilineTextFieldInputDecoration = InputDecoration(
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
);

const TextStyle kAppMultilineTextFieldTextStyle = TextStyle(
  color: kAppForegroundColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppMultilineTextField extends StatefulWidget {
  final AppMultilineTextFieldOnChangedCallback onChanged;
  final String hintText;
  final String initialValue;
  final bool focus;
  final int maxLength;

  const AppMultilineTextField(
      {Key? key,
      required this.onChanged,
      required this.hintText,
      this.initialValue = '',
      this.focus = false,
      this.maxLength = -1})
      : super(key: key);

  @override
  State<AppMultilineTextField> createState() => _AppMultilineTextFieldState();
}

class _AppMultilineTextFieldState extends State<AppMultilineTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      controller: _controller,
      minLines: null,
      maxLines: null,
      expands: true,
      textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.top,
      onChanged: widget.onChanged,
      style: kAppMultilineTextFieldTextStyle,
      autofocus: widget.focus,
      maxLength: (widget.maxLength > 0) ? widget.maxLength : null,
      decoration: kAppMultilineTextFieldInputDecoration.copyWith(hintText: widget.hintText),
    );
  }
}
