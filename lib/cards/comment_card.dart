import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../devtools/logger.dart';

import '../settings/app_colors.dart';
import '../settings/app_progress.dart';
import '../settings/app_styles.dart';

import '../server/server_project.dart';

import '../dialogs/app_dialog.dart';

import '../screens/create_todo_item_screen.dart';

import '../project/dome_project_todo_item.dart';
import '../project/dome_project_comment.dart';

import '../controls/clip_br_rect_shape.dart';
import '../controls/clip_br_rect_shape_border.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const TextStyle kCommentCardMessageStyle = TextStyle(
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

const TextStyle kCommentCardDateTimeStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.w900,
  color: kAppProjectCardSecondaryColor,
);

const TextStyle kCommentCardAuthorStyle = TextStyle(
  fontSize: 16.0,
  color: kAppProjectCardSecondaryColor,
);

const double kCommentCardToolCheckBoxSize = 24.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class CommentCard extends StatefulWidget {
  final DomeProjectComment comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.comment,
      child: Consumer<DomeProjectComment>(
        builder: (context, comment, child) {
          return Container(
            margin: const EdgeInsets.only(top: 16.0, left: 4.0, right: 4.0),
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
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      // TODO
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.getCommentMessage(),
                            style: kCommentCardMessageStyle,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.getCreatedDateTimeLocalDescription(),
                                  style: kCommentCardDateTimeStyle,
                                ),
                                Text(
                                  comment.getAuthor(),
                                  textAlign: TextAlign.start,
                                  style: kCommentCardAuthorStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () async {
                    AppDialogResult? result = await AppDialog.showChoiceDialog(
                        context: context,
                        icon: Icons.warning_amber_rounded,
                        title: 'Delete Comment',
                        content: 'Are you sure you want to delete this comment?',
                        option1: 'Yes',
                        option2: 'No');

                    if (result != null && result == AppDialogResult.option1) {
                      Logger.print('user chose to delete the comment');
                      // TODO
                    }
                  },
                  child: Icon(
                    Icons.delete,
                    size: kCommentCardToolCheckBoxSize,
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
