import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../devtools/logger.dart';

import '../settings/app_colors.dart';
import '../settings/app_styles.dart';

import '../project/dome_project.dart';
import '../project/dome_project_list.dart';
import '../project/dome_project_manager.dart';

import '../screens/create_project_screen.dart';
import '../screens/todo_list_screen.dart';

import 'app_bar_button.dart';
import 'clip_top_center_rect_shape.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kOpenProjectFooterTextStyle = TextStyle(
  fontSize: 14.0,
  color: kAppBarLabelTextColor,
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class OpenProjectFooterBar extends StatefulWidget {
  static const double _clipWidthRatio = 0.4;
  static const double _clipHeightRatio = 0.2;
  static const double _barFullHeight = 70.0;

  const OpenProjectFooterBar({Key? key}) : super(key: key);

  @override
  State<OpenProjectFooterBar> createState() => _OpenProjectFooterBarState();
}

class _OpenProjectFooterBarState extends State<OpenProjectFooterBar> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipTopCenterRectShape(
          clipWidthRatio: OpenProjectFooterBar._clipWidthRatio, clipHeightRatio: OpenProjectFooterBar._clipHeightRatio),
      child: Container(
        height: OpenProjectFooterBar._barFullHeight,
        color: kAppProjectBackgroundColor,
        child: Stack(
          children: [
            Container(
              height: OpenProjectFooterBar._barFullHeight,
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
                      DomeProjectList domeProjectList = Provider.of<DomeProjectList>(context, listen: false);

                      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateProjectScreen()));
                      if (DomeProjectManager.hasActiveProject()) {
                        switch (DomeProjectManager.getActiveProject().getProjectType()) {
                          case DomeProjectType.todo:
                            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TodoListScreen()));
                            await domeProjectList.setupProjects();
                            break;
                          // TODO: support the value collection project type
                          default:
                            // TODO: error, unknown project type
                            break;
                        }
                      }
                    },
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  // right side button go here
                  const SizedBox(width: 20.0),
                ],
              ),
            ),
            Container(
              height: OpenProjectFooterBar._barFullHeight * (1.0 - OpenProjectFooterBar._clipHeightRatio),
              margin: EdgeInsets.only(top: OpenProjectFooterBar._barFullHeight * OpenProjectFooterBar._clipHeightRatio),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      Provider.of<DomeProjectList>(context).getTotalProjectsDescription(),
                      textAlign: TextAlign.center,
                      style: kOpenProjectFooterTextStyle,
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
