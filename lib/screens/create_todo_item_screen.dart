import 'package:flutter/material.dart';

import '../utilities/screen_tools.dart';

import '../server/server_auth.dart';
import '../server/server_project.dart';

import '../cards/comment_card.dart';

import '../controls/app_primary_prompt.dart';
import '../controls/app_text_field.dart';
import '../controls/app_multiline_text_field.dart';
import '../controls/app_button.dart';
import '../controls/app_bar_button.dart';
import '../controls/app_form_field_spacer.dart';
import '../controls/app_info_tag.dart';
import '../controls/screen_frame.dart';
import '../controls/app_label.dart';
import '../controls/app_tech_label.dart';

import '../project/dome_project.dart';
import '../project/dome_project_item.dart';
import '../project/dome_project_todo_item.dart';
import '../project/dome_project_comment.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const kCreateTodoItemScreenDescriptionFieldHeight = 120.0;
const kCreateTodoItemScreenCommentFieldHeight = 80.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class CreateTodoItemScreen extends StatefulWidget {
  final DomeProjectTodoItem? item;
  final DomeProject domeProject;

  const CreateTodoItemScreen({Key? key, this.item, required this.domeProject}) : super(key: key);

  @override
  State<CreateTodoItemScreen> createState() => _CreateTodoItemScreenState();
}

class _CreateTodoItemScreenState extends State<CreateTodoItemScreen> {
  String _itemName = '';
  String _itemDescription = '';
  String _comment = '';

  TextEditingController _commentController = TextEditingController();

  bool _processing = false;

  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      DomeProjectTodoItem item = widget.item!;

      _itemName = item.getName();
      _itemDescription = item.getDescription();

      setState(() {
        _processing = true;
      });

      ServerProject.updateClientComments(item).then((v) {
        setState(() {
          _processing = false;
        });
      });
    }
  }

  bool _isCreateMode() {
    return (widget.item == null);
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
              // const AppFormFieldSpacer(),
              // _backButton(),
              const AppFormFieldSpacer(),
              AppPrimaryPrompt(
                  prompt: _isCreateMode() ? 'create todo item' : 'todo',
                  prevChild: _backButton(),
                  nextChild: !(_isCreateMode()) ? _getPromptChild() : null),
              _getNameField(),
              _getDescriptionField(widget.domeProject),
              Visibility(
                visible: !(_isCreateMode()),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AppFormFieldSpacer(spacerSize: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                height: kCreateTodoItemScreenCommentFieldHeight,
                                child: AppMultilineTextField(
                                  hintText: 'add comment',
                                  maxLength: DomeProjectComment.messageMaxLength,
                                  controller: _commentController,
                                  onChanged: (value) {
                                    setState(() {
                                      _comment = value;
                                    });
                                  },
                                ),
                              ),
                              AppInfoTag(
                                  message: '${DomeProjectComment.messageMaxLength - _comment.length} characters available'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        AppBarButton(
                          icon: Icons.add,
                          onPress: () async {
                            if (_comment.isNotEmpty) {
                              setState(() {
                                _processing = true;
                              });

                              await widget.item!.appendComment(
                                  domeProjectComment:
                                      DomeProjectComment(commentMessage: _comment, author: ServerAuth.getCurrentUserEmail()),
                                  updateServer: true);

                              setState(() {
                                _processing = false;
                              });

                              FocusManager.instance.primaryFocus?.unfocus();

                              setState(() {
                                _comment = '';
                                _commentController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    // const AppFormFieldSpacer(spacerSize: 2),
                    _getCommentCards(),
                  ],
                ),
              ),
              const AppFormFieldSpacer(spacerSize: 2),
              // TODO: may want these back after adding row to attach graphics
              // _backButton(),
              // const AppFormFieldSpacer(spacerSize: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNameField() {
    if (_isCreateMode()) {
      return Column(
        children: [
          const AppFormFieldSpacer(),
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
        ],
      );
    }

    return Column(
      children: [
        const AppFormFieldSpacer(),
        AppLabel(message: _itemName),
        AppLabel(message: 'created by: ${(widget.item!.hasAuthor() ? widget.item!.getAuthor() : 'unknown')}'),
      ],
    );
  }

  Widget _getPromptChild() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppLabel(
          message: '[',
        ),
        AppTechLabel(
          message: widget.item!.getServerId(),
        ),
        // const SizedBox(width: 2.0),
        AppLabel(
          message: ']',
        ),
      ],
    );
  }

  Widget _getDescriptionField(DomeProject domeProject) {
    if (_isCreateMode() || widget.item!.isOwned() || !(widget.item!.hasAuthor())) {
      return Column(
        children: [
          const AppFormFieldSpacer(
            spacerSize: 2.0,
          ),
          SizedBox(
            height: kCreateTodoItemScreenDescriptionFieldHeight,
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
          const AppFormFieldSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppButton(
                title: _isCreateMode() ? 'Create Item' : 'Update',
                enabled: _isFormValid(),
                onPress: () async {
                  DomeProjectTodoItem todoItem = DomeProjectTodoItem(
                      project: domeProject,
                      itemName: _itemName,
                      itemDescription: _itemDescription,
                      author: ServerAuth.getCurrentUserEmail());

                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(context).pop(todoItem);
                },
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        const AppFormFieldSpacer(),
        AppLabel(message: _itemDescription),
      ],
    );
  }

  Widget _backButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppBarButton(
          icon: Icons.arrow_back,
          onPress: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(width: 4.0),
      ],
    );
  }

  Widget _getCommentCards() {
    if (widget.item != null) {
      return Column(
        children: [
          for (DomeProjectComment domeProjectComment in widget.item!.getComments()) CommentCard(comment: domeProjectComment)
        ],
      );
    }

    return Container();
  }

  bool _isFormValid() {
    return (_itemName.isNotEmpty);
  }
}
