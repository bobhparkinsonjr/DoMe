import 'package:flutter/material.dart';

import 'screen_frame.dart';
import 'view_project_header_bar.dart';
import 'view_project_footer_bar.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ViewProjectFrame extends StatefulWidget {
  final Widget child;
  final bool processing;

  const ViewProjectFrame({Key? key, required this.child, this.processing = false}) : super(key: key);

  @override
  State<ViewProjectFrame> createState() => _ViewProjectFrameState();
}

class _ViewProjectFrameState extends State<ViewProjectFrame> {
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
              ViewProjectHeaderBar(),
              ViewProjectFooterBar(),
            ],
          ),
        ],
      ),
      processing: widget.processing,
    );
  }
}
