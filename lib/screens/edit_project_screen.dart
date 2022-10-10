import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:typed_data';

import '../devtools/logger.dart';

import '../project/dome_project.dart';

import '../utilities/password_validator.dart';
import '../utilities/screen_tools.dart';
import '../utilities/image_tools.dart';

import '../controls/screen_frame.dart';
import '../controls/app_primary_prompt.dart';
import '../controls/app_form_field_spacer.dart';
import '../controls/app_choose_graphic_button.dart';
import '../controls/app_text_field.dart';
import '../controls/app_password_text_field.dart';
import '../controls/app_button.dart';
import '../controls/app_info_tag.dart';
import '../controls/app_error_tag.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class EditProjectScreen extends StatefulWidget {
  final DomeProject domeProject;

  const EditProjectScreen({Key? key, required this.domeProject}) : super(key: key);

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  String _name = '';
  String _password = '';
  String _imageFilePath = '';

  PasswordValidateType _passwordValidateType = PasswordValidateType.valid;

  bool _processing = false;

  @override
  void initState() {
    super.initState();

    _name = widget.domeProject.getName();

    _password = widget.domeProject.getPassword();
    _passwordValidateType = PasswordValidator.validate(_password);

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
              AppPrimaryPrompt(prompt: 'edit project'),
              const AppFormFieldSpacer(spacerSize: 2),
              AppChooseGraphicButton(
                prompt: 'choose graphic',
                initialFillImage: widget.domeProject.getGraphicImage(),
                onChanged: (String imageFilePath) {
                  _imageFilePath = imageFilePath;
                },
              ),
              const AppFormFieldSpacer(),
              AppTextField(
                hintText: 'project name',
                initialValue: _name,
                focus: false,
                maxLength: DomeProject.nameMaxLength,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              AppInfoTag(message: '${DomeProject.nameMaxLength - _name.length} characters available'),
              const AppFormFieldSpacer(spacerSize: 2),
              Visibility(
                visible: widget.domeProject.isOwned(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppPasswordTextField(
                      hintText: 'password',
                      initialValue: _password,
                      focus: false,
                      obscureText: true,
                      onChanged: (value) {
                        _password = value;
                        setState(() {
                          _passwordValidateType = PasswordValidator.validate(_password);
                        });
                      },
                    ),
                    AppErrorTag(
                      message: PasswordValidator.getValidateMessage(_passwordValidateType),
                      visible: _passwordValidateType != PasswordValidateType.valid &&
                          _passwordValidateType != PasswordValidateType.invalidEmpty,
                    ),
                    const AppFormFieldSpacer(spacerSize: 2),
                  ],
                ),
              ),
              _appendAppButtons(widget.domeProject),
            ],
          ),
        ),
      ),
    );
  }

  Widget _updateButton(DomeProject domeProject) {
    return AppButton(
      title: 'Update Project',
      enabled: _isFormValid(),
      onPress: () async {
        setState(() {
          _processing = true;
        });

        Logger.print('updating project | image file path: \'$_imageFilePath\'');

        Uint8List? graphicBytes = await ImageTools.getImageBytes(_imageFilePath);

        DomeProject updateDomeProject = DomeProject(
          name: _name,
          password: _password,
          graphicBytes: graphicBytes,
          graphicPath: _imageFilePath,
        );

        if (await domeProject.updateContent(source: updateDomeProject, updateServer: true)) {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.of(context).pop(domeProject);
        } else {
          setState(() {
            _processing = false;
          });
        }
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

  Widget _appendAppButtons(DomeProject domeProject) {
    if (ScreenTools.isScreenNarrow(context)) {
      return Column(
        children: [
          _updateButton(domeProject),
          const AppFormFieldSpacer(spacerSize: 0.5),
          _cancelButton(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _updateButton(domeProject),
        const AppFormFieldSpacer(),
        _cancelButton(),
      ],
    );
  }

  bool _isFormValid() {
    return (_name.isNotEmpty && _passwordValidateType == PasswordValidateType.valid);
  }
}
