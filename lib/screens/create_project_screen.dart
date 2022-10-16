import 'package:flutter/material.dart';

import '../devtools/logger.dart';

import '../utilities/password_validator.dart';
import '../utilities/screen_tools.dart';

import '../server/server_project.dart';

import '../project/dome_project_manager.dart';
import '../project/dome_project.dart';

import '../controls/screen_frame.dart';
import '../controls/app_primary_prompt.dart';
import '../controls/app_choose_graphic_button.dart';
import '../controls/app_button.dart';
// import '../controls/app_radio_button.dart';
import '../controls/app_error_tag.dart';
import '../controls/app_text_field.dart';
import '../controls/app_password_text_field.dart';
import '../controls/app_form_field_spacer.dart';

import '../dialogs/app_dialog.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({Key? key}) : super(key: key);

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  bool _processing = false;
  String _name = '';
  String _password = '';
  String _imageFilePath = '';
  DomeProjectType _currentProjectType = DomeProjectType.todo;

  PasswordValidateType _passwordValidateType = PasswordValidateType.invalidEmpty;

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
              const AppPrimaryPrompt(prompt: 'create a new project'),
              const AppFormFieldSpacer(spacerSize: 2),
              AppChooseGraphicButton(
                prompt: 'choose graphic',
                onChanged: (String imageFilePath, int sourceSizeBytes) {
                  _imageFilePath = imageFilePath;
                },
              ),
              const AppFormFieldSpacer(),
              AppTextField(
                hintText: 'project name',
                focus: false,
                onChanged: (value) {
                  _name = value;
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
                    _passwordValidateType = PasswordValidator.validate(_password);
                  });
                },
              ),
              AppErrorTag(
                message: PasswordValidator.getValidateMessage(_passwordValidateType),
                visible: _passwordValidateType != PasswordValidateType.valid &&
                    _passwordValidateType != PasswordValidateType.invalidEmpty,
              ),
              /*
              const AppFormFieldSpacer(),
              for (DomeProjectType projectType in DomeProjectType.values)
                if (projectType != DomeProjectType.none)
                  AppRadioButton(
                    caption: DomeProject.getProjectTypeName(projectType),
                    description: DomeProject.getProjectTypeDescription(projectType),
                    id: projectType.index,
                    currentId: _currentProjectType.index,
                    onSelected: () {
                      setState(() {
                        _currentProjectType = projectType;
                      });
                    },
                  ),
              */
              const AppFormFieldSpacer(),
              _appendAppButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createProjectButton() {
    return AppButton(
      title: 'Create Project',
      enabled: _isFormValid(),
      onPress: () async {
        if (_currentProjectType != DomeProjectType.todo) {
          await AppDialog.showChoiceDialog(
            context: context,
            icon: Icons.error_outline_rounded,
            title: 'Unsupported Project Type',
            content: 'Currently only the todo project type is supported.',
            option1: 'Ok',
          );

          return;
        }

        setState(() {
          _processing = true;
        });

        DomeProject? activeProject = await ServerProject.createProject(
            projectName: _name, projectPassword: _password, projectType: _currentProjectType, graphicFilePath: _imageFilePath);

        if (activeProject != null) {
          DomeProjectManager.setActiveProject(activeProject);

          switch (_currentProjectType) {
            case DomeProjectType.todo:
              Navigator.pop(context);
              break;
            default:
              // TODO: error, unknown project type
              break;
          }
        } else {
          await AppDialog.showChoiceDialog(
            context: context,
            icon: Icons.error_outline_rounded,
            title: 'Create Project Failed',
            content: 'Failed to create the project.  Please try again later.',
            option1: 'Ok',
          );
        }

        setState(() {
          _processing = false;
        });
      },
    );
  }

  Widget _cancelButton() {
    return AppButton(
      title: 'Cancel',
      enabled: true,
      onPress: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _appendAppButtons() {
    if (ScreenTools.isScreenNarrow(context)) {
      return Column(
        children: [
          _createProjectButton(),
          const AppFormFieldSpacer(spacerSize: 0.5),
          _cancelButton(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createProjectButton(),
        const AppFormFieldSpacer(),
        _cancelButton(),
      ],
    );
  }

  bool _isFormValid() {
    return (_name.isNotEmpty &&
        _passwordValidateType == PasswordValidateType.valid &&
        _currentProjectType != DomeProjectType.none);
  }
}
