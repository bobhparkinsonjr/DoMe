import 'package:flutter/material.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppRadioButtonSelected = void Function();

const List<Shadow> kAppRadioButtonCaptionShadowStyle = [
  Shadow(
    blurRadius: 6.0,
    color: Color(0xC0000000),
    offset: Offset(2.0, 2.0),
  ),
];

const TextStyle kAppRadioButtonCaptionStyle = TextStyle(
  fontSize: 18.0,
  color: kAppLabelPrimaryColor,
  fontWeight: FontWeight.w500,
  shadows: kAppRadioButtonCaptionShadowStyle,
);

const TextStyle kAppRadioButtonDescriptionStyle = TextStyle(
  fontSize: 16.0,
  color: kAppLabelSecondaryColor,
  fontWeight: FontWeight.normal,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppRadioButton extends StatefulWidget {
  final int id;
  final int currentId;
  final String caption;
  final String description;
  final AppRadioButtonSelected onSelected;

  const AppRadioButton(
      {Key? key,
      required this.id,
      required this.currentId,
      required this.caption,
      this.description = '',
      required this.onSelected})
      : super(key: key);

  @override
  State<AppRadioButton> createState() => _AppRadioButtonState();
}

class _AppRadioButtonState extends State<AppRadioButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            widget.onSelected();
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _isChecked() ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: kAppLabelPrimaryColor,
              shadows: kAppRadioButtonCaptionShadowStyle,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.caption,
                    style: kAppRadioButtonCaptionStyle,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    widget.description,
                    style: kAppRadioButtonDescriptionStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isChecked() {
    return (widget.id == widget.currentId);
  }
}
