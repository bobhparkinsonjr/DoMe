import 'package:flutter/material.dart';

import '../project/dome_project.dart';

import '../utilities/screen_tools.dart';

import '../server/server_project.dart';

import '../dialogs/app_dialog.dart';

import '../controls/screen_frame.dart';
import '../controls/app_primary_prompt.dart';
import '../controls/app_form_field_spacer.dart';
import '../controls/app_bar_button.dart';
import '../controls/app_password_text_field.dart';
import '../controls/app_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ProjectPasswordScreen extends StatefulWidget {
  final DomeProject domeProject;

  const ProjectPasswordScreen({Key? key, required this.domeProject}) : super(key: key);

  @override
  State<ProjectPasswordScreen> createState() => _ProjectPasswordScreenState();
}

class _ProjectPasswordScreenState extends State<ProjectPasswordScreen> {
  String _password = '';
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _password = widget.domeProject.getPassword();
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
              AppBarButton(
                fillImage: widget.domeProject.getGraphicImage(),
                scale: 3.0,
                onPress: () {
                  // empty
                },
              ),
              const AppFormFieldSpacer(spacerSize: 2),
              AppPrimaryPrompt(prompt: 'enter project password'),
              const AppFormFieldSpacer(),
              AppPasswordTextField(
                hintText: 'password',
                initialValue: _password,
                focus: false,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              const AppFormFieldSpacer(spacerSize: 2),
              _appendAppButtons(widget.domeProject),
            ],
          ),
        ),
      ),
    );
  }

  Widget _applyButton(DomeProject domeProject) {
    return AppButton(
      title: 'Apply',
      enabled: _isFormValid(),
      onPress: () async {
        if (await domeProject.setPassword(_password)) {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.of(context).pop(true);
        } else {
          await AppDialog.showChoiceDialog(
            context: context,
            // icon: Icons.warning_amber_rounded,
            icon: Icons.error_outline_rounded,
            title: 'Invalid Password',
            content: 'The password you have entered is invalid.',
            option1: 'Ok',
          );
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
          _applyButton(domeProject),
          const AppFormFieldSpacer(spacerSize: 0.5),
          _cancelButton(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _applyButton(domeProject),
        const AppFormFieldSpacer(),
        _cancelButton(),
      ],
    );
  }

  bool _isFormValid() {
    return (_password.isNotEmpty);
  }
}
