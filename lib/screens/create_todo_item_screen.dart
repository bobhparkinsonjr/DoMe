import 'package:flutter/material.dart';

import '../utilities/screen_tools.dart';

import '../controls/app_primary_prompt.dart';
import '../controls/app_text_field.dart';
import '../controls/app_multiline_text_field.dart';
import '../controls/app_button.dart';
import '../controls/app_form_field_spacer.dart';
import '../controls/app_info_tag.dart';
import '../controls/screen_frame.dart';

import '../project/dome_project.dart';
import '../project/dome_project_item.dart';
import '../project/dome_project_todo_item.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

enum CreateTodoItemScreenMode {
  create,
  edit,
}

class CreateTodoItemScreen extends StatefulWidget {
  final CreateTodoItemScreenMode mode;
  final String initialItemName;
  final String initialItemDescription;
  final DomeProject domeProject;

  const CreateTodoItemScreen(
      {Key? key,
      this.mode = CreateTodoItemScreenMode.create,
      this.initialItemName = '',
      this.initialItemDescription = '',
      required this.domeProject})
      : super(key: key);

  @override
  State<CreateTodoItemScreen> createState() => _CreateTodoItemScreenState();
}

class _CreateTodoItemScreenState extends State<CreateTodoItemScreen> {
  String _itemName = '';
  String _itemDescription = '';

  @override
  void initState() {
    super.initState();
    _itemName = widget.initialItemName;
    _itemDescription = widget.initialItemDescription;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      formScreen: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const AppFormFieldSpacer(spacerSize: 2),
              AppPrimaryPrompt(
                  prompt: (widget.mode == CreateTodoItemScreenMode.create) ? 'create a new todo item' : 'edit todo item'),
              const AppFormFieldSpacer(spacerSize: 2),
              AppTextField(
                hintText: 'name',
                initialValue: _itemName,
                focus: true,
                maxLength: DomeProjectItem.nameMaxLength,
                onChanged: (value) {
                  setState(() {
                    _itemName = value;
                  });
                },
              ),
              AppInfoTag(message: '${DomeProjectItem.nameMaxLength - _itemName.length} characters available'),
              const AppFormFieldSpacer(),
              SizedBox(
                height: 80.0,
                child: AppMultilineTextField(
                  hintText: 'description',
                  initialValue: _itemDescription,
                  focus: false,
                  maxLength: DomeProjectTodoItem.descriptionMaxLength,
                  onChanged: (value) {
                    setState(() {
                      _itemDescription = value;
                    });
                  },
                ),
              ),
              AppInfoTag(message: '${DomeProjectTodoItem.descriptionMaxLength - _itemDescription.length} characters available'),
              const AppFormFieldSpacer(spacerSize: 2),
              _appendAppButtons(widget.domeProject),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createButton(DomeProject domeProject) {
    return AppButton(
      title: (widget.mode == CreateTodoItemScreenMode.create) ? 'Create Item' : 'Update Item',
      enabled: _isFormValid(),
      onPress: () async {
        DomeProjectTodoItem todoItem =
            DomeProjectTodoItem(project: domeProject, itemName: _itemName, itemDescription: _itemDescription);

        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.of(context).pop(todoItem);
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
          _createButton(domeProject),
          const AppFormFieldSpacer(spacerSize: 0.5),
          _cancelButton(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createButton(domeProject),
        const AppFormFieldSpacer(),
        _cancelButton(),
      ],
    );
  }

  bool _isFormValid() {
    return (_itemName.isNotEmpty);
  }
}
