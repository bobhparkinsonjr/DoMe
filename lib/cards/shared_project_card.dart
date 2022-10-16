import 'package:flutter/material.dart';

import '../devtools/logger.dart';

import '../settings/app_colors.dart';

import '../project/dome_project.dart';

import '../controls/clip_br_rect_shape_border.dart';
import '../controls/app_bar_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef SharedProjectCardOnDeleteCallback = void Function();

const TextStyle kSharedProjectCardNameStyle = TextStyle(
  fontSize: 18.0,
  color: kAppProjectCardPrimaryColor,
  fontWeight: FontWeight.bold,
  shadows: [
    Shadow(
      blurRadius: 2.0,
      color: Color(0xC0000000),
      offset: Offset(2.0, 2.0),
    ),
  ],
);

const double kSharedProjectCardToolSize = 24.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class SharedProjectCard extends StatelessWidget {
  final DomeProject domeProject;
  final String shareToEmail;
  final SharedProjectCardOnDeleteCallback onDelete;

  const SharedProjectCard({Key? key, required this.domeProject, required this.shareToEmail, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        color: kAppProjectCardFillColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
          Container(
            padding: const EdgeInsets.only(left: 8.0, right: 10.0),
            child: AppBarButton(
              fillImage: domeProject.getGraphicImage(),
              scale: 2.0,
              onPress: onPressed,
            ),
          ),
          */
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shareToEmail,
                  style: kSharedProjectCardNameStyle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5.0),
          Visibility(
            visible: domeProject.isOwned(),
            child: GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.delete,
                size: kSharedProjectCardToolSize,
                color: kAppProjectCardPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
        ],
      ),
    );
  }
}
