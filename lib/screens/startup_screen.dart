import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import '../utilities/settings_manager.dart';

import 'login_user_screen.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class StartupScreen extends StatefulWidget {
  const StartupScreen({Key? key}) : super(key: key);

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    Firebase.initializeApp().then((v) {
      SettingsManager.setup().then((v) {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => LoginUserScreen()), (Route<dynamic> route) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // TODO: loading indicator of some kind
  }
}
