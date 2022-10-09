import 'package:flutter/material.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../devtools/logger.dart';

import '../settings/app_colors.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef AppChooseGraphicOnChanged = void Function(String imageFilePath);

const TextStyle kAppChooseGraphicButtonTextStyle = TextStyle(
  fontSize: 14.0,
  color: kAppGraphicWellForegroundColor,
);

const double kAppChooseGraphicInnerRadius = 60.0;
const double kAppChooseGraphicOuterRadius = kAppChooseGraphicInnerRadius + 4.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class AppChooseGraphicButton extends StatefulWidget {
  final String prompt;
  final AppChooseGraphicOnChanged onChanged;
  final ImageProvider? initialFillImage;

  const AppChooseGraphicButton({Key? key, required this.prompt, required this.onChanged, this.initialFillImage})
      : super(key: key);

  @override
  State<AppChooseGraphicButton> createState() => _AppChooseGraphicButtonState();

  static double getWidth() {
    return kAppChooseGraphicOuterRadius * 2.0;
  }

  static double getHeight() {
    return kAppChooseGraphicOuterRadius * 2.0;
  }
}

class _AppChooseGraphicButtonState extends State<AppChooseGraphicButton> {
  String _imageFilePath = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppChooseGraphicButton.getWidth(),
      height: AppChooseGraphicButton.getHeight(),
      decoration: BoxDecoration(
        color: const Color(0x00FFFFFF),
        borderRadius: BorderRadius.circular(kAppChooseGraphicOuterRadius),
        border: Border.all(
          color: kAppPrimaryColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kAppChooseGraphicOuterRadius - kAppChooseGraphicInnerRadius),
        child: Material(
          elevation: 8.0,
          color: kAppGraphicWellFillColor,
          borderRadius: BorderRadius.circular(kAppChooseGraphicInnerRadius),
          child: Container(
            decoration: _imageFilePath.isNotEmpty
                ? BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(
                        File(_imageFilePath),
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    shape: BoxShape.circle,
                  )
                : (widget.initialFillImage != null)
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: widget.initialFillImage!,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                        shape: BoxShape.circle,
                      )
                    : null,
            child: MaterialButton(
              onPressed: () async {
                if (await Permission.storage.request().isGranted) {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();

                  if (result != null) {
                    setState(() {
                      _imageFilePath = result.files.single.path!;
                      Logger.print('image file path chosen: \'$_imageFilePath\'');
                      widget.onChanged(_imageFilePath);
                    });
                  } else {
                    // User canceled the picker
                  }
                }
              },
              child: Center(
                child: Text(
                  (_imageFilePath.isEmpty && widget.initialFillImage == null) ? widget.prompt : '',
                  style: kAppChooseGraphicButtonTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
