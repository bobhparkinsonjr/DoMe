import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/app_colors.dart';

import '../utilities/screen_tools.dart';

import '../project/dome_project.dart';
import '../project/dome_project_manager.dart';

import '../server/server_auth.dart';

import '../screens/edit_project_screen.dart';
import '../screens/edit_account_screen.dart';

import 'clip_bottom_center_rect_shape.dart';
import 'app_bar_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const double kProjectHeaderNormalFontSize = 26.0;
const double kProjectHeaderNarrowFontSize = 20.0;

const TextStyle kProjectHeaderTextStyle = TextStyle(
  fontSize: 26.0, // 30.0,
  color: kAppBarLabelTextColor,
  height: 1.0,
  fontWeight: FontWeight.bold,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(-2.0, -2.0),
    ),
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, -2.0),
    ),
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(-2.0, 2.0),
    ),
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

/*
TextStyle kProjectHeaderOutlineTextStyle = TextStyle(
  fontSize: 28.0, // 14.0,
  height: 1.0,
  fontWeight: FontWeight.bold,
  foreground: Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = kAppBarControlFillColor,
);
*/

const TextStyle kProjectHeaderSubTextStyle = TextStyle(
  fontSize: 16.0, // 14.0,
  color: kAppBarLabelTextColor,
  height: 1.1,
  // fontWeight: FontWeight.w900,
  fontStyle: FontStyle.italic,
);

const double kViewProjectHeaderBarSideButtonsScale = 1.4;
const double kViewProjectHeaderBarCentralButtonsScale = 2.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class ViewProjectHeaderBar extends StatefulWidget {
  static const double _clipWidthRatio = 0.52;
  static const double _clipHeightRatio = 0.25;
  static const double _barFullHeight = 110.0;

  const ViewProjectHeaderBar({Key? key}) : super(key: key);

  @override
  State<ViewProjectHeaderBar> createState() => _ViewProjectHeaderBarState();
}

class _ViewProjectHeaderBarState extends State<ViewProjectHeaderBar> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipBottomCenterRectShape(
          clipWidthRatio: ViewProjectHeaderBar._clipWidthRatio, clipHeightRatio: ViewProjectHeaderBar._clipHeightRatio),
      child: Container(
        height: ViewProjectHeaderBar._barFullHeight,
        color: kAppProjectBackgroundColor,
        child: Stack(
          children: [
            Container(
              height: ViewProjectHeaderBar._barFullHeight * (1.0 - ViewProjectHeaderBar._clipHeightRatio),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 20.0),
                  AppBarButton(
                    icon: Icons.arrow_back,
                    scale: kViewProjectHeaderBarSideButtonsScale,
                    onPress: () {
                      DomeProjectManager.clearActiveProject();
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  AppBarButton(
                    fillImage: ServerAuth.getCurrentUserAvatar(),
                    scale: kViewProjectHeaderBarSideButtonsScale,
                    onPress: () async {
                      bool? modifiedSettings = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditAccountScreen(),
                        ),
                      );

                      if (modifiedSettings != null && modifiedSettings) {
                        // need to redraw whole widget tree, not just this header bar
                        DomeProject domeProject = Provider.of<DomeProject>(context, listen: false);
                        domeProject.notifyListeners();
                      }
                    },
                  ),
                  const SizedBox(width: 20.0),
                ],
              ),
            ),
            Container(
              height: ViewProjectHeaderBar._barFullHeight,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 4.0),
                          AppBarButton(
                            fillImage: Provider.of<DomeProject>(context).getGraphicImage(),
                            scale: kViewProjectHeaderBarCentralButtonsScale,
                            onPress: () {
                              DomeProject domeProject = Provider.of<DomeProject>(context, listen: false);
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                                return EditProjectScreen(
                                  domeProject: domeProject,
                                );
                              }));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width -
                                (MediaQuery.of(context).size.width * ViewProjectHeaderBar._clipWidthRatio) -
                                (ViewProjectHeaderBar._barFullHeight * ViewProjectHeaderBar._clipHeightRatio),
                            child: Text(
                              Provider.of<DomeProject>(context).getName(),
                              textAlign: TextAlign.center,
                              style: kProjectHeaderTextStyle.copyWith(
                                  fontSize: ScreenTools.isScreenNarrow(context)
                                      ? kProjectHeaderNarrowFontSize
                                      : kProjectHeaderNormalFontSize),
                            ),
                          ),
                          const SizedBox(height: 6.0),
                        ],
                      ),
                    ],
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
