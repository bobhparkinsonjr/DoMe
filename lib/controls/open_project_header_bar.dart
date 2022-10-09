import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/app_colors.dart';

import '../project/dome_project_list.dart';

import '../server/server_auth.dart';

import '../screens/edit_account_screen.dart';

import 'clip_bottom_center_rect_shape.dart';
import 'app_bar_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kOpenProjectHeaderTextStyle = TextStyle(
  fontSize: 18.0, // 14.0,
  color: kAppBarLabelTextColor,
  height: 1.0,
  fontWeight: FontWeight.w900,
);

const TextStyle kOpenProjectHeaderSubTextStyle = TextStyle(
  fontSize: 16.0, // 14.0,
  color: kAppBarLabelTextColor,
  height: 1.1,
  // fontWeight: FontWeight.w900,
  fontStyle: FontStyle.italic,
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
                        const SizedBox(width: 2.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Open Project',
                              textAlign: TextAlign.center,
                              style: kOpenProjectHeaderTextStyle,
                            ),
                            const SizedBox(height: 2.0),
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
