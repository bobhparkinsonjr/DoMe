import 'package:flutter/material.dart';

import 'screen_frame.dart';
import 'open_project_header_bar.dart';
import 'open_project_footer_bar.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class OpenProjectFrame extends StatefulWidget {
  final Widget child;
  final bool processing;

  const OpenProjectFrame({Key? key, required this.child, this.processing = false}) : super(key: key);

  @override
  State<OpenProjectFrame> createState() => _OpenProjectFrameState();
}

class _OpenProjectFrameState extends State<OpenProjectFrame> {
  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      child: Stack(
        children: [
          widget.child,
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpenProjectHeaderBar(),
              OpenProjectFooterBar(),
            ],
          ),
        ],
      ),
      processing: widget.processing,
    );
  }
}
