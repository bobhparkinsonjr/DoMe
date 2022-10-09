import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../devtools/logger.dart';

import '../settings/app_colors.dart';
import '../settings/app_styles.dart';

import '../project/dome_project.dart';
import '../project/dome_project_todo_item.dart';

import 'app_bar_button.dart';
import 'clip_top_center_rect_shape.dart';

import '../screens/create_todo_item_screen.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kProjectFooterTextStyle = TextStyle(
  fontSize: 14.0,
  color: kAppBarLabelTextColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class ViewProjectFooterBar extends StatefulWidget {
  static const double _clipWidthRatio = 0.4;
  static const double _clipHeightRatio = 0.2;
  static const double _barFullHeight = 70.0;

  const ViewProjectFooterBar({Key? key}) : super(key: key);

  @override
  State<ViewProjectFooterBar> createState() => _ViewProjectFooterBarState();
}

class _ViewProjectFooterBarState extends State<ViewProjectFooterBar> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipTopCenterRectShape(
          clipWidthRatio: ViewProjectFooterBar._clipWidthRatio, clipHeightRatio: ViewProjectFooterBar._clipHeightRatio),
      child: Container(
        height: ViewProjectFooterBar._barFullHeight,
        color: kAppProjectBackgroundColor,
        child: Stack(
          children: [
            Container(
              height: ViewProjectFooterBar._barFullHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 20.0),
                  AppBarButton(
                    // title: '+',
                    icon: Icons.add,
                    scale: kFooterAppBarButtonScale,
                    onPress: () async {
                      // Logger.print('detected add button in project footer bar');

                      DomeProject domeProject = Provider.of<DomeProject>(context, listen: false);

                      switch (domeProject.getProjectType()) {
                        case DomeProjectType.todo:
                          DomeProjectTodoItem? todoItem = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return CreateTodoItemScreen(
                                  domeProject: domeProject,
                                );
                              },
                            ),
                          ) as DomeProjectTodoItem;

                          if (todoItem != null) {
                            // Logger.print('created a todo item \'${todoItem.getName()}\'');

                            if (await domeProject.appendTodoItem(item: todoItem, updateServer: true)) {
                              // Logger.print('updated display for changed project after adding of new item');
                            } else {
                              Logger.print('failed to append new todo item');
                              // TODO: error window
                            }
                          }

                          break;

                        // TODO: value collection item type

                        default:
                          // empty
                          break;
                      }
                    },
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  // right side button go here
                  AppBarButton(
                    icon: Icons.remove_red_eye,
                    scale: kFooterAppBarButtonScale,
                    onPress: () async {
                      Logger.print('toggle all details visible');
                      Provider.of<DomeProject>(context, listen: false).toggleDetailsVisible();
                    },
                  ),
                  const SizedBox(width: 20.0),
                ],
              ),
            ),
            Container(
              height: ViewProjectFooterBar._barFullHeight * (1.0 - ViewProjectFooterBar._clipHeightRatio),
              margin: EdgeInsets.only(top: ViewProjectFooterBar._barFullHeight * ViewProjectFooterBar._clipHeightRatio),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      Provider.of<DomeProject>(context).getProjectCountStatus(),
                      textAlign: TextAlign.center,
                      style: kProjectFooterTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
