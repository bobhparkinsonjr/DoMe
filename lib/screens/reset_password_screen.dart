import 'package:flutter/material.dart';

import '../utilities/password_validator.dart';

import '../server/server_auth.dart';

import '../dialogs/app_dialog.dart';

import '../controls/app_form_field_spacer.dart';
import '../controls/app_primary_prompt.dart';
import '../controls/app_text_field.dart';
import '../controls/app_button.dart';
import '../controls/app_password_text_field.dart';
import '../controls/screen_frame.dart';
import '../controls/app_error_tag.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _processing = false;

  String _code = '';

  String _password = '';
  String _confirmPassword = '';

  PasswordValidateType passwordValidateType = PasswordValidateType.invalidEmpty;

  @override
  void initState() {
    super.initState();
    _processing = false;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      processing: _processing,
      formScreen: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const AppFormFieldSpacer(spacerSize: 2),
              const AppPrimaryPrompt(prompt: 'reset password'),
              const AppFormFieldSpacer(spacerSize: 2),
              AppTextField(
                hintText: 'code from email',
                onChanged: (value) {
                  _code = value;
                },
              ),
              const AppFormFieldSpacer(spacerSize: 2.0),
              AppPasswordTextField(
                hintText: 'password',
                obscureText: true,
                onChanged: (value) {
                  _password = value;

                  setState(() {
                    passwordValidateType = PasswordValidator.validate(_password);
                  });
                },
              ),
              AppErrorTag(
                message: PasswordValidator.getValidateMessage(passwordValidateType),
                visible: passwordValidateType != PasswordValidateType.valid &&
                    passwordValidateType != PasswordValidateType.invalidEmpty,
              ),
              const AppFormFieldSpacer(),
              AppPasswordTextField(
                hintText: 'confirm password',
                obscureText: true,
                onChanged: (value) {
                  _confirmPassword = value;
                },
              ),
              const AppFormFieldSpacer(),
              AppButton(
                title: 'Reset Password',
                enabled: _isFormValid(),
                onPress: () async {
                  if (_password != _confirmPassword) {
                    await AppDialog.showChoiceDialog(
                      context: context,
                      icon: Icons.error_outline_rounded,
                      title: 'Password Mismatch',
                      content: 'The passwords entered here must match.',
                      option1: 'Ok',
                    );

                    return;
                  }

                  setState(() {
                    _processing = true;
                  });

                  bool confirmResult = await ServerAuth.confirmResetPassword(_code, _password);

                  setState(() {
                    _processing = false;
                  });

                  if (confirmResult) {
                    await AppDialog.showChoiceDialog(
                      context: context,
                      // icon: Icons.info_outline_rounded,
                      title: 'Password Reset',
                      content: 'Your password has been reset.  Please login to continue.',
                      option1: 'Ok',
                    );

                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.of(context).pop();
                  } else {
                    await AppDialog.showChoiceDialog(
                      context: context,
                      icon: Icons.error_outline_rounded,
                      title: 'Password Reset Failed',
                      content: 'Failed to reset the password.  Please try again later.',
                      option1: 'Ok',
                    );
                  }
                },
              ),
              AppButton(
                title: 'Cancel',
                onPress: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(context).pop();
                },
              ),
              const AppFormFieldSpacer(),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFormValid() {
    return (_code.isNotEmpty && passwordValidateType == PasswordValidateType.valid);
  }
}
