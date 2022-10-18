import 'package:flutter/material.dart';
import 'dart:math';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../settings/app_colors.dart';
import '../settings/app_progress.dart';

import '../utilities/settings_manager.dart';

import '../server/server_auth.dart';

// import '../controls/clip_br_rect_shape_border.dart';
// import '../controls/clip_bl_rect_shape_border.dart';
import '../controls/clip_rect_shape_border.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

const double kScreenFrameTileMargin = 2.0;

///////////////////////////////////////////////////////////////////////////////////////////////////

class ScreenFrame extends StatefulWidget {
  final Widget child;
  final bool processing;
  final bool formScreen;

  const ScreenFrame({Key? key, required this.child, this.processing = false, this.formScreen = false}) : super(key: key);

  @override
  State<ScreenFrame> createState() => _ScreenFrameState();
}

class _ScreenFrameState extends State<ScreenFrame> {
  static const int tileBackdropTotalColumns = 4;
  static const int tileBackdropTotalRows = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (_getBackgroundImageOpacity() > 0.0) ? Color(0xFF000000) : kAppScreenBackgroundColor,
      body: ModalProgressHUD(
        inAsyncCall: widget.processing,
        blur: kAppProgressBlur,
        child: SafeArea(
          child: Stack(
            children: [
              _getBackdrop(),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }

  double _getBackgroundImageOpacity() {
    double backgroundImageOpacity;

    if (widget.formScreen)
      backgroundImageOpacity = SettingsManager.getFormScreenBackgroundImageOpacity();
    else
      backgroundImageOpacity = SettingsManager.getScreenBackgroundImageOpacity();

    return backgroundImageOpacity;
  }

  BoxDecoration _getDecoration() {
    double backgroundImageOpacity = _getBackgroundImageOpacity();
    MemoryImage? backgroundImage = ServerAuth.getCurrentUserBackground();

    if (backgroundImage != null) {
      return BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(backgroundImageOpacity),
            BlendMode.dstATop,
          ),
          image: backgroundImage, // AssetImage('assets/background_placeholder_01.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      );
    }

    return BoxDecoration(color: kAppScreenBackgroundColor);
  }

  Widget _getTile(Color tileColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(kScreenFrameTileMargin),
        decoration: ShapeDecoration(
          shape: ClipRectShapeBorder(
            clipRatio: 0.35,
            maxSize: 20.0,
            thickness: 1.0,
            outlineColor: kAppBackgroundTileShapeOutlineColor,
          ),
          color: tileColor,
        ),
      ),
    );
  }

  /*
  Widget _getTileBR() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(kScreenFrameTileMargin),
        decoration: ShapeDecoration(
          shape: ClipBRRectShapeBorder(
            clipRatio: 0.35,
            maxSize: 20.0,
            thickness: 1.0,
            outlineColor: kAppBackgroundTileShapeOutlineColor,
          ),
          color: _getRandomTileColor(),
        ),
      ),
    );
  }
  */

  /*
  Widget _getTileBL() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(kScreenFrameTileMargin),
        decoration: ShapeDecoration(
          shape: ClipBLRectShapeBorder(
            clipRatio: 0.35,
            maxSize: 20.0,
            thickness: 1.0,
            outlineColor: kAppBackgroundTileShapeOutlineColor,
          ),
          color: _getRandomTileColor(),
        ),
      ),
    );
  }
  */

  /*
  Color _getRandomTileColor() {
    int v = Random().nextInt(3);

    switch (v) {
      case 0:
        return kAppBackgroundTileShapeColor2;

      case 1:
        return kAppBackgroundTileShapeColor3;

      default:
        // empty
        break;
    }

    return kAppBackgroundTileShapeColor1;
  }
  */

  /*
  Widget _getRandomTile() {
    int v = Random().nextInt(3);

    switch (v) {
      case 0:
        return _getTileBL();

      case 1:
        return _getTileBR();

      default:
        // empty
        break;
    }

    return _getTile();
  }
  */

  Widget _getTileRow({int flex = 1}) {
    List<Widget> row = [];
    int c0 = 1;
    int c1 = tileBackdropTotalColumns - 2;

    for (int i = 0; i < tileBackdropTotalColumns; ++i) {
      if (i != c0 && i != c1) {
        row.add(_getTile(kAppBackgroundTileShapeColor1));
      } else {
        row.add(_getTile(kAppBackgroundTileShapeColor2));
      }
    }

    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: row,
      ),
    );
  }

  Widget _getTileBackdrop() {
    // TODO: these tiles would look nicer if animated, could have the columns slowly scrolling up/down
    return Container(
      color: kAppScreenBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (int i = 0; i < tileBackdropTotalRows; ++i) _getTileRow(flex: (i == 1) ? 1 : 2),
        ],
      ),
    );
  }

  Widget _getBackdrop() {
    if (widget.formScreen && ServerAuth.getCurrentUserBackground() == null) return _getTileBackdrop();

    return Container(
      decoration: _getDecoration(),
    );
  }
}
