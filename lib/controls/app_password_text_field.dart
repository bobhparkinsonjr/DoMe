import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

import '../utilities/password_validator.dart';

import 'app_bar_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppPasswordOnChangedCallback = void Function(String value);

const InputDecoration kAppPasswordInputDecoration = InputDecoration(
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

const TextStyle kAppPasswordTextStyle = TextStyle(
  color: kAppForegroundColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppPasswordTextField extends StatefulWidget {
  final AppPasswordOnChangedCallback onChanged;
  final String hintText;
  final String initialValue;
  final bool focus;
  final bool obscureText;

  const AppPasswordTextField(
      {Key? key,
      required this.onChanged,
      required this.hintText,
      this.initialValue = '',
      this.focus = false,
      this.obscureText = true})
      : super(key: key);

  @override
  State<AppPasswordTextField> createState() => _AppPasswordTextFieldState();
}

class _AppPasswordTextFieldState extends State<AppPasswordTextField> {
  late TextEditingController _controller;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: TextField(
            controller: _controller,
            obscureText: _obscureText,
            textAlign: TextAlign.left,
            onChanged: widget.onChanged,
            style: kAppPasswordTextStyle,
            autofocus: widget.focus,
            maxLength: PasswordValidator.passwordMaxLength,
            decoration: kAppPasswordInputDecoration.copyWith(hintText: widget.hintText),
          ),
        ),
        const SizedBox(width: 4.0),
        AppBarButton(
          icon: _obscureText ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
          onPress: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ],
    );
  }
}
