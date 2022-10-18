import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:typed_data';

import '../devtools/logger.dart';

import '../server/server_project.dart';

import '../project/dome_project.dart';

import '../utilities/password_validator.dart';
import '../utilities/screen_tools.dart';
import '../utilities/image_tools.dart';

import '../cards/shared_project_card.dart';

import '../dialogs/app_dialog.dart';

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
import '../controls/app_int_field.dart';

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
  int _detailsTotalLatestComments = 0;

  int _graphicSizeBytes = 0;

  PasswordValidateType _passwordValidateType = PasswordValidateType.valid;

  List<String> _shareToEmails = [];

  bool _processing = false;

  @override
  void initState() {
    super.initState();

    _name = widget.domeProject.getName();

    _password = widget.domeProject.getPassword();
    _passwordValidateType = PasswordValidator.validate(_password);

    _detailsTotalLatestComments = widget.domeProject.getDetailsTotalLatestComments();

    MemoryImage? graphicImage = widget.domeProject.getGraphicImage();
    if (graphicImage != null) {
      _graphicSizeBytes = graphicImage.bytes.length;
    } else {
      _graphicSizeBytes = 0;
    }

    setState(() {
      _processing = true;
    });

    ServerProject.getShareToEmails(widget.domeProject).then((shareToEmails) {
      setState(() {
        _shareToEmails = shareToEmails;
        _processing = false;
      });
    });
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
              AppPrimaryPrompt(prompt: 'project settings'),
              const AppFormFieldSpacer(spacerSize: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppChooseGraphicButton(
                    prompt: 'choose graphic',
                    initialFillImage: widget.domeProject.getGraphicImage(),
                    onChanged: (String imageFilePath, int sourceSizeBytes) {
                      _imageFilePath = imageFilePath;
                      _graphicSizeBytes = sourceSizeBytes;
                    },
                  ),
                  const SizedBox(width: 12.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppLabel(message: 'Image Info'),
                      AppLabel(
                          message:
                              '${(_graphicSizeBytes / 1024.0 / 1024.0).toStringAsFixed(1)} MB of ${(DomeProject.graphicMaxSizeBytes / 1024.0 / 1024.0).toStringAsFixed(1)} MB'),
                    ],
                  ),
                ],
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
              AppIntField(
                prompt: 'Max Comments In Details',
                initialValue: widget.domeProject.getDetailsTotalLatestComments(),
                minValue: 0,
                maxValue: DomeProject.maxDetailsTotalLatestComments,
                onChanged: (int value) {
                  _detailsTotalLatestComments = value;
                },
              ),
              const AppFormFieldSpacer(),
              AppLabel(message: 'owner: ${widget.domeProject.getOwner()}'),
              const AppFormFieldSpacer(),
              Visibility(
                visible: _shareToEmails.isNotEmpty,
                child: Column(
                  children: [
                    AppLabel(message: 'This project is shared with:'),
                    const AppFormFieldSpacer(spacerSize: 0.5),
                    for (String shareToEmail in _shareToEmails)
                      SharedProjectCard(
                        domeProject: widget.domeProject,
                        shareToEmail: shareToEmail,
                        onDelete: () async {
                          AppDialogResult? result = await AppDialog.showChoiceDialog(
                              context: context,
                              icon: Icons.warning_amber_rounded,
                              title: 'Stop Sharing',
                              content: 'Are you sure you want to stop sharing this project with \'$shareToEmail\'?',
                              option1: 'Yes',
                              option2: 'No');

                          if (result != null && result == AppDialogResult.option1) {
                            Logger.print('user chose to stop sharing project');

                            setState(() {
                              _processing = true;
                            });

                            await ServerProject.unshareProject(widget.domeProject, shareToEmail);
                            List<String> shareToEmails = await ServerProject.getShareToEmails(widget.domeProject);

                            setState(() {
                              _shareToEmails = shareToEmails;
                              _processing = false;
                            });
                          }
                        },
                      ),
                    const AppFormFieldSpacer(spacerSize: 2.0),
                  ],
                ),
              ),
              _appendAppButtons(widget.domeProject),
              const AppFormFieldSpacer(),
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
          detailsTotalLatestComments: _detailsTotalLatestComments,
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
          const AppFormFieldSpacer(spacerSize: 2.0),
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
