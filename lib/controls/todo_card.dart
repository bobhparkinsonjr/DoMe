import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../devtools/logger.dart';

import '../settings/app_colors.dart';
import '../settings/app_progress.dart';
import '../settings/app_styles.dart';

import '../dialogs/app_dialog.dart';

import '../screens/create_todo_item_screen.dart';

import '../project/dome_project_todo_item.dart';

import 'clip_br_rect_shape.dart';
import 'clip_br_rect_shape_border.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kTodoCardNameStyle = TextStyle(
  fontSize: 20.0,
  color: kAppProjectCardPrimaryColor,
  fontWeight: FontWeight.bold,

  // using this to vertically align the name with the checkbox
  height: 1.3,

  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

const TextStyle kTodoCardDateTimeStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.w900,
  color: kAppProjectCardSecondaryColor,
);

const TextStyle kTodoCardDescriptionStyle = TextStyle(
  fontSize: 16.0,
  color: kAppProjectCardSecondaryColor,
);

const double kTodoCardCheckBoxSize = 30.0;
const double kTodoCardToolCheckBoxSize = 24.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class TodoCard extends StatefulWidget {
  final DomeProjectTodoItem todoItem;

  const TodoCard({Key? key, required this.todoItem}) : super(key: key);

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.todoItem,
      child: Consumer<DomeProjectTodoItem>(
        builder: (context, todoItem, child) {
          return Container(
            margin: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
            padding: const EdgeInsets.only(right: 8.0, top: 12.0, bottom: 12.0),
            decoration: ShapeDecoration(
              shape: ClipBRRectShapeBorder(
                clipRatio: 0.35,
                maxSize: 20.0,
                thickness: 1.0,
                outlineColor: kAppProjectCardOutlineColor,
              ),
              color: todoItem.isDragging() ? kAppCardDragFillColor : kAppProjectCardFillColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await todoItem.toggleComplete(updateServer: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                    child: Icon(
                      todoItem.isComplete() ? Icons.check_circle_outlined : Icons.radio_button_unchecked,
                      size: kTodoCardCheckBoxSize,
                      color: todoItem.isComplete() ? kAppProjectCardCompleteColor : kAppProjectCardIncompleteColor,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await todoItem.toggleComplete(updateServer: true);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todoItem.getName(),
                          style: kTodoCardNameStyle,
                        ),
                        Visibility(
                          visible: todoItem.isDetailsVisible(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todoItem.getCreatedDateTimeLocalDescription(),
                                style: kTodoCardDateTimeStyle,
                              ),
                              Visibility(
                                visible: todoItem.isComplete(),
                                child: Text(
                                  todoItem.getCompleteDateTimeLocalDescription(),
                                  style: kTodoCardDateTimeStyle,
                                ),
                              ),
                              Visibility(
                                visible: todoItem.getDescription().isNotEmpty,
                                child: Text(
                                  todoItem.getDescription(),
                                  textAlign: TextAlign.start,
                                  style: kTodoCardDescriptionStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      todoItem.toggleDetailsVisible();
                    });
                  },
                  child: Icon(
                    Icons.remove_red_eye,
                    size: kTodoCardToolCheckBoxSize,
                    color: kAppProjectCardPrimaryColor,
                  ),
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () async {
                    DomeProjectTodoItem? updatedTodoItem = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return CreateTodoItemScreen(
                            mode: CreateTodoItemScreenMode.edit,
                            initialItemName: todoItem.getName(),
                            initialItemDescription: todoItem.getDescription(),
                            domeProject: todoItem.getProject(),
                          );
                        },
                      ),
                    ) as DomeProjectTodoItem;

                    if (updatedTodoItem != null) {
                      await todoItem.updateContent(source: updatedTodoItem, updateServer: true);
                    }
                  },
                  child: Icon(
                    Icons.edit_rounded,
                    size: kTodoCardToolCheckBoxSize,
                    color: kAppProjectCardPrimaryColor,
                  ),
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () async {
                    AppDialogResult? result = await AppDialog.showChoiceDialog(
                        context: context,
                        icon: Icons.warning_amber_rounded,
                        title: 'Delete Todo Item',
                        content: 'Are you sure you want to delete this todo item?\n\n${todoItem.getName()}',
                        option1: 'Yes',
                        option2: 'No');

                    if (result != null && result == AppDialogResult.option1) {
                      Logger.print('user chose to delete the todo item');
                      await todoItem.deleteTodoItem(updateServer: true);
                    }
                  },
                  child: Icon(
                    Icons.delete,
                    size: kTodoCardToolCheckBoxSize,
                    color: kAppProjectCardPrimaryColor,
                  ),
                ),
                const SizedBox(width: 10.0),
              ],
            ),
          );
        },
        // child: ,
      ),
    );
  }
}
