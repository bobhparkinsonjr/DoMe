import 'package:flutter/material.dart';

import '../devtools/logger.dart';

import '../settings/app_colors.dart';

import '../project/dome_project.dart';

import 'clip_br_rect_shape_border.dart';
import 'app_bar_button.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef ProjectCardOnPressedCallback = void Function();
typedef ProjectCardOnShareCallback = void Function();
typedef ProjectCardOnDeleteCallback = void Function();

const TextStyle kProjectCardNameStyle = TextStyle(
  fontSize: 24.0,
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

const TextStyle kProjectCardOwnerStyle = TextStyle(
  fontSize: 14.0,
  color: kAppProjectCardPrimaryColor,
  fontStyle: FontStyle.normal,
);

const TextStyle kProjectCardTypeStyle = TextStyle(
  fontSize: 14.0,
  color: kAppProjectCardPrimaryColor,
  fontStyle: FontStyle.normal,
);

const TextStyle kProjectCardDateTimeStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.w900,
  color: kAppProjectCardSecondaryColor,
);

const double kProjectCardToolSize = 24.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class ProjectCard extends StatelessWidget {
  final DomeProject domeProject;
  final ProjectCardOnPressedCallback onPressed;
  final ProjectCardOnShareCallback onShare;
  final ProjectCardOnDeleteCallback onDelete;

  const ProjectCard(
      {Key? key, required this.domeProject, required this.onPressed, required this.onShare, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
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
            Container(
              padding: const EdgeInsets.only(left: 8.0, right: 10.0),
              child: AppBarButton(
                fillImage: domeProject.getGraphicImage(),
                scale: 2.0,
                onPress: onPressed,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domeProject.getName(),
                    style: kProjectCardNameStyle,
                  ),
                  Text(
                    'owner: ${domeProject.getOwner()}',
                    style: kProjectCardOwnerStyle,
                  ),
                  Text(
                    DomeProject.getProjectTypeName(domeProject.getProjectType()).toLowerCase(),
                    style: kProjectCardTypeStyle,
                  ),
                  Text(
                    domeProject.getCreatedDateTimeLocalDescription(),
                    style: kProjectCardDateTimeStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5.0),
            Visibility(
              visible: domeProject.isOwned(),
              child: GestureDetector(
                onTap: onShare,
                child: Icon(
                  Icons.share,
                  size: kProjectCardToolSize,
                  color: kAppProjectCardPrimaryColor,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Visibility(
              visible: domeProject.isOwned(),
              child: GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete,
                  size: kProjectCardToolSize,
                  color: kAppProjectCardPrimaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10.0),
          ],
        ),
      ),
    );
  }
}
