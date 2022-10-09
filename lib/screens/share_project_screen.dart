import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:typed_data';

import '../project/dome_project.dart';

import '../server/server_project.dart';

import '../utilities/screen_tools.dart';

import '../controls/screen_frame.dart';
import '../controls/app_primary_prompt.dart';
import '../controls/app_form_field_spacer.dart';
import '../controls/app_text_field.dart';
import '../controls/app_button.dart';
import '../controls/app_bar_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ShareProjectScreen extends StatefulWidget {
  final DomeProject domeProject;

  const ShareProjectScreen({Key? key, required this.domeProject}) : super(key: key);

  @override
  State<ShareProjectScreen> createState() => _ShareProjectScreenState();
}

class _ShareProjectScreenState extends State<ShareProjectScreen> {
  String _shareToEmail = '';
  bool _processing = false;

  @override
  void initState() {
    super.initState();
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
              AppPrimaryPrompt(prompt: 'share project'),
              const AppFormFieldSpacer(spacerSize: 2),
              AppBarButton(
                fillImage: widget.domeProject.getGraphicImage(),
                scale: 3.0,
                onPress: () {
                  // empty
                },
              ),
              const AppFormFieldSpacer(),
              AppTextField(
                hintText: 'email to share to',
                initialValue: _shareToEmail,
                focus: false,
                onChanged: (value) {
                  setState(() {
                    _shareToEmail = value;
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

  Widget _shareButton(DomeProject domeProject) {
    return AppButton(
      title: 'Share Project',
      enabled: _isFormValid(),
      onPress: () async {
        setState(() {
          _processing = true;
        });

        if (await ServerProject.shareProject(domeProject, _shareToEmail)) {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.of(context).pop();
        } else {
          // TODO: error message
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
          _shareButton(domeProject),
          const AppFormFieldSpacer(spacerSize: 0.5),
          _cancelButton(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _shareButton(domeProject),
        const AppFormFieldSpacer(),
        _cancelButton(),
      ],
    );
  }

  bool _isFormValid() {
    return (_shareToEmail.isNotEmpty);
  }
}
