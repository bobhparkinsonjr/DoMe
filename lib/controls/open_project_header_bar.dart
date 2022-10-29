import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/app_colors.dart';

import '../utilities/app_info.dart';

import '../project/dome_project_list.dart';

import '../server/server_auth.dart';

import '../screens/edit_account_screen.dart';

import '../dialogs/app_dialog.dart';

import 'clip_bottom_center_rect_shape.dart';
import 'app_bar_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kOpenProjectHeaderTextStyle = TextStyle(
  fontSize: 28.0, // 14.0,
  color: kAppLabelPrimaryColor,
  height: 1.0,
  fontWeight: FontWeight.w900,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

const TextStyle kOpenProjectHeaderSubTextStyle = TextStyle(
  fontSize: 20.0, // 14.0,
  color: kAppLabelSecondaryColor,
  fontStyle: FontStyle.italic,
  fontWeight: FontWeight.bold,
  shadows: [
    Shadow(
      blurRadius: 1.0,
      color: Color(0xC0000000),
      offset: Offset(1.0, 1.0),
    ),
  ],
);

///////////////////////////////////////////////////////////////////////////////////////////////////

class OpenProjectHeaderBar extends StatefulWidget {
  static const double _clipWidthRatio = 0.4;
  static const double _clipHeightRatio = 0.2;
  static const double _barFullHeight = 70.0;

  const OpenProjectHeaderBar({Key? key}) : super(key: key);

  @override
  State<OpenProjectHeaderBar> createState() => _OpenProjectHeaderBarState();
}

class _OpenProjectHeaderBarState extends State<OpenProjectHeaderBar> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipBottomCenterRectShape(
          clipWidthRatio: OpenProjectHeaderBar._clipWidthRatio, clipHeightRatio: OpenProjectHeaderBar._clipHeightRatio),
      child: Container(
        height: OpenProjectHeaderBar._barFullHeight,
        color: kAppProjectBackgroundColor,
        child: Stack(
          children: [
            Container(
              height: OpenProjectHeaderBar._barFullHeight * (1.0 - OpenProjectHeaderBar._clipHeightRatio),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 20.0),
                  AppBarButton(
                    icon: Icons.arrow_back,
                    onPress: () async {
                      await ServerAuth.logOut();
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  AppBarButton(
                    fillImage: ServerAuth.getCurrentUserAvatar(),
                    onPress: () async {
                      DomeProjectList domeProjectList = Provider.of<DomeProjectList>(context, listen: false);
                      domeProjectList.setProcessing(true);

                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditAccountScreen(),
                        ),
                      );

                      domeProjectList.setProcessing(false);
                    },
                  ),
                  const SizedBox(width: 20.0),
                ],
              ),
            ),
            Container(
              height: OpenProjectHeaderBar._barFullHeight,
              child: Stack(
                children: [
                  Container(
                    height: OpenProjectHeaderBar._barFullHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            String version = AppInfo.getDisplayVersion();
                            String buildDate = AppInfo.getBuildDate();

                            AppDialogResult? result = await AppDialog.showChoiceDialog(
                              context: context,
                              // icon: Icons.warning_amber_rounded,
                              title: 'DoMe',
                              content: '\ntrack the things you have to do\n'
                                  '\n\nversion $version'
                                  '\nbuild date $buildDate'
                                  '\n\nCopyright 2022 Bob H. Parkinson Jr.',
                              option1: 'OK',
                            );
                          },
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/dome_checker_icon.png'),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: OpenProjectHeaderBar._barFullHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 2.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 14.0),
                            Text(
                              'DoMe',
                              textAlign: TextAlign.center,
                              style: kOpenProjectHeaderTextStyle,
                            ),
                            /*
                            Text(
                              '1.0.0.0',
                              textAlign: TextAlign.center,
                              style: kOpenProjectHeaderSubTextStyle,
                            ),
                            */
                            // const SizedBox(height: 2.0),
                          ],
                        )
                      ],
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
