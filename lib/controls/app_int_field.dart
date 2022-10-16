import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

import '../utilities/screen_tools.dart';

import 'app_label.dart';
import 'app_bar_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppIntFieldOnChangedCallback = void Function(int value);

const InputDecoration kAppIntFieldInputDecoration = InputDecoration(
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

const TextStyle kAppIntFieldTextStyle = TextStyle(
  color: kAppForegroundColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppIntField extends StatefulWidget {
  final String prompt;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final AppIntFieldOnChangedCallback onChanged;

  const AppIntField(
      {Key? key, required this.prompt, required this.onChanged, this.initialValue = 0, this.minValue = -10, this.maxValue = 10})
      : super(key: key);

  @override
  State<AppIntField> createState() => _AppIntFieldState();
}

class _AppIntFieldState extends State<AppIntField> {
  late TextEditingController _controller;
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    if (ScreenTools.isScreenNarrow(context)) {
      return Column(
        children: [
          AppLabel(
            message: widget.prompt,
          ),
          const SizedBox(height: 8.0),
          _getEditControlGroup(),
        ],
      );
    }

    return Row(
      children: [
        Flexible(
          child: AppLabel(
            message: widget.prompt,
          ),
        ),
        _getEditControlGroup(),
      ],
    );
  }

  Widget _getEditControlGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100.0,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _controller,
            textAlign: TextAlign.left,
            onChanged: (String value) {
              _value = int.tryParse(value) ?? 0;
              widget.onChanged(_value);
            },
            style: kAppIntFieldTextStyle,
            // autofocus: widget.focus,
            // maxLength: (widget.maxLength > 0) ? widget.maxLength : null,
            decoration: kAppIntFieldInputDecoration,
          ),
        ),
        const SizedBox(width: 8.0),
        AppBarButton(
          icon: Icons.arrow_upward_rounded,
          onPress: () {
            setState(() {
              ++_value;
              _controller.text = _value.toString();
              widget.onChanged(_value);
            });
          },
        ),
        const SizedBox(width: 4.0),
        AppBarButton(
          icon: Icons.arrow_downward_rounded,
          onPress: () {
            setState(() {
              --_value;
              _controller.text = _value.toString();
              widget.onChanged(_value);
            });
          },
        )
      ],
    );
  }
}
