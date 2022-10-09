import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:typed_data';

import '../utilities/password_validator.dart';
import '../utilities/screen_tools.dart';
import '../utilities/image_tools.dart';
import '../utilities/settings_manager.dart';

import '../server/server_auth.dart';

import '../controls/screen_frame.dart';
import '../controls/app_primary_prompt.dart';
import '../controls/app_form_field_spacer.dart';
import '../controls/app_choose_graphic_button.dart';
import '../controls/app_text_field.dart';
import '../controls/app_password_text_field.dart';
import '../controls/app_button.dart';
import '../controls/app_info_tag.dart';
import '../controls/app_error_tag.dart';
import '../controls/app_label.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({Key? key}) : super(key: key);

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String _email = '';
  String _avatarFilePath = '';
  String _backgroundFilePath = '';

  MemoryImage? _avatar;
  MemoryImage? _background;

  double _backgroundFormImageOpacity = 1.0;
  double _backgroundImageOpacity = 1.0;

  bool _processing = false;

  @override
  void initState() {
    super.initState();

    _email = ServerAuth.getCurrentUserEmail();
    _avatarFilePath = '';
    _backgroundFilePath = '';

    _avatar = ServerAuth.getCurrentUserAvatar();
    _background = ServerAuth.getCurrentUserBackground();

    _backgroundFormImageOpacity = SettingsManager.getFormScreenBackgroundImageOpacity();
    _backgroundImageOpacity = SettingsManager.getScreenBackgroundImageOpacity();

    _processing = false;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      formScreen: true,
      processing: _processing,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const AppFormFieldSpacer(spacerSize: 2),
              AppPrimaryPrompt(prompt: 'account settings'),
              const AppFormFieldSpacer(spacerSize: 2),
              AppLabel(
                message: _email,
                labelAlign: AppLabelAlign.center,
              ),
              const AppFormFieldSpacer(spacerSize: 2),
              Table(
                columnWidths: {
                  0: FixedColumnWidth(200),
                  1: FixedColumnWidth(AppChooseGraphicButton.getWidth()),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: AppLabel(
                          message: 'Avatar',
                          labelAlign: AppLabelAlign.left,
                        ),
                      ),
                      TableCell(
                        child: AppChooseGraphicButton(
                          prompt: 'choose avatar',
                          initialFillImage: _avatar,
                          onChanged: (String imageFilePath) {
                            _avatarFilePath = imageFilePath;
                          },
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(child: const AppFormFieldSpacer()),
                      TableCell(child: const AppFormFieldSpacer()),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: AppLabel(
                          message: 'Background',
                          labelAlign: AppLabelAlign.left,
                        ),
                      ),
                      TableCell(
                        child: AppChooseGraphicButton(
                          prompt: 'choose background',
                          initialFillImage: _background,
                          onChanged: (String imageFilePath) {
                            _backgroundFilePath = imageFilePath;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // TODO: change email option
              // TODO: change password option
              // TODO: opacity values for background
              const AppFormFieldSpacer(spacerSize: 2.0),
              _appendAppButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _updateButton() {
    return AppButton(
      title: 'Update',
      enabled: _isFormValid(),
      onPress: () async {
        setState(() {
          _processing = true;
        });

        bool modified = false;

        if (_avatarFilePath.isNotEmpty) {
          await ServerAuth.updateServerUserAvatar(_avatarFilePath);
          modified = true;
        }

        if (_backgroundFilePath.isNotEmpty) {
          await ServerAuth.updateServerUserBackground(_backgroundFilePath);
          modified = true;
        }

        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.of(context).pop(modified);
      },
    );
  }

  Widget _cancelButton() {
    return AppButton(
      title: 'Cancel',
      enabled: true,
      onPress: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.of(context).pop();
      },
    );
  }

  Widget _appendAppButtons() {
    if (ScreenTools.isScreenNarrow(context)) {
      return Column(
        children: [
          _updateButton(),
          const AppFormFieldSpacer(spacerSize: 0.5),
          _cancelButton(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _updateButton(),
        const AppFormFieldSpacer(),
        _cancelButton(),
      ],
    );
  }

  bool _isFormValid() {
    return true;
  }
}
