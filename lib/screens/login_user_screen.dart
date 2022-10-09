import 'package:flutter/material.dart';

import '../devtools/logger.dart';

import '../server/server_auth.dart';

import '../utilities/settings_manager.dart';

import '../controls/app_form_field_spacer.dart';
import '../controls/app_primary_prompt.dart';
import '../controls/app_button.dart';
import '../controls/app_link.dart';
import '../controls/app_email_text_field.dart';
import '../controls/app_password_text_field.dart';
import '../controls/screen_frame.dart';

import '../dialogs/app_dialog.dart';

import 'create_account_screen.dart';
import 'open_project_screen.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class LoginUserScreen extends StatefulWidget {
  const LoginUserScreen({Key? key}) : super(key: key);

  @override
  State<LoginUserScreen> createState() => _LoginUserScreenState();
}

class _LoginUserScreenState extends State<LoginUserScreen> {
  bool _processing = false;
  String _email = '';
  String _password = '';

  @override
  void initState() {
    super.initState();

    _email = SettingsManager.getLastUser();
    _processing = false;

    Logger.print(
        'log in screen | user currently logged in: ${ServerAuth.isLoggedIn().toString()} | email: \'${ServerAuth.getCurrentUserEmail()}\'');

    if (ServerAuth.isLoggedIn()) {
      Logger.print('log in screen | user is currently logged in at startup, will update info and go to open project screen');
      ServerAuth.updateUserInfo().then((bool updatedUser) {
        if (updatedUser) Navigator.of(context).push(MaterialPageRoute(builder: (context) => OpenProjectScreen()));
      });
    }
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
              const AppPrimaryPrompt(prompt: 'please provide your credentials to log in'),
              const AppFormFieldSpacer(spacerSize: 2),
              AppEmailTextField(
                initialValue: _email,
                hintText: 'email address',
                focus: _email.isEmpty,
                onChanged: (value) {
                  _email = value;
                },
              ),
              const AppFormFieldSpacer(),
              AppPasswordTextField(
                hintText: 'password',
                focus: _email.isNotEmpty,
                obscureText: true,
                onChanged: (value) {
                  _password = value;
                },
              ),
              const AppFormFieldSpacer(spacerSize: 2),
              AppButton(
                title: 'Log In',
                enabled: true,
                onPress: () async {
                  setState(() {
                    _processing = true;
                  });

                  if (await ServerAuth.logIn(_email, _password)) {
                    if (SettingsManager.getLastUser() != _email) {
                      SettingsManager.setLastUser(_email);
                      await SettingsManager.save();
                    }

                    FocusManager.instance.primaryFocus?.unfocus();

                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => OpenProjectScreen()));

                    setState(() {
                      _processing = false;
                    });
                  } else {
                    setState(() {
                      _processing = false;
                    });

                    await AppDialog.showChoiceDialog(
                      context: context,
                      icon: Icons.error_outline_rounded,
                      title: 'Login Failed',
                      content: 'The email address and/or the password is incorrect.',
                      option1: 'Ok',
                    );
                  }
                },
              ),
              const AppFormFieldSpacer(),
              AppLink(
                linkName: 'I am a new user',
                tooltip: 'This will take you to the create account screen.',
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateAccountScreen()));
                  if (ServerAuth.isLoggedIn())
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => OpenProjectScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
