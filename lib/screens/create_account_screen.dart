import 'package:flutter/material.dart';

import '../devtools/logger.dart';

import '../utilities/email_validator.dart';
import '../utilities/password_validator.dart';
import '../utilities/screen_tools.dart';

import '../server/server_auth.dart';

import '../controls/screen_frame.dart';
import '../controls/app_form_field_spacer.dart';
import '../controls/app_primary_prompt.dart';
import '../controls/app_choose_graphic_button.dart';
import '../controls/app_button.dart';
import '../controls/app_link.dart';
import '../controls/app_error_tag.dart';
import '../controls/app_email_text_field.dart';
import '../controls/app_password_text_field.dart';

import '../dialogs/app_dialog.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _processing = false;
  String _email = '';
  String _password = '';
  String _imageFilePath = '';

  EmailValidateType emailValidateType = EmailValidateType.invalidEmpty;
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
              const AppPrimaryPrompt(prompt: 'please provide the following information to create a new account'),
              const AppFormFieldSpacer(spacerSize: 2),
              AppChooseGraphicButton(
                prompt: 'choose avatar',
                onChanged: (String imageFilePath) {
                  _imageFilePath = imageFilePath;
                },
              ),
              const AppFormFieldSpacer(),
              AppEmailTextField(
                hintText: 'email address',
                focus: false,
                onChanged: (value) {
                  _email = value;
                  setState(() {
                    emailValidateType = EmailValidator.validate(_email);
                  });
                },
              ),
              const AppFormFieldSpacer(),
              AppPasswordTextField(
                hintText: 'password',
                focus: false,
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
              AppButton(
                title: 'Create Account',
                enabled: _isFormValid(),
                onPress: () async {
                  setState(() {
                    _processing = true;
                  });

                  if (await ServerAuth.createAccount(_email, _password, _imageFilePath)) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      _processing = false;
                    });

                    await AppDialog.showChoiceDialog(
                      context: context,
                      icon: Icons.error_outline_rounded,
                      title: 'Create Account Failed',
                      content: 'Failed to create the account.  Please try again later.',
                      option1: 'Ok',
                    );
                  }
                },
              ),
              const AppFormFieldSpacer(),
              AppLink(
                linkName: 'I already have an account',
                tooltip: 'This will take you to the login screen.',
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFormValid() {
    return (emailValidateType == EmailValidateType.valid && passwordValidateType == PasswordValidateType.valid);
  }
}
