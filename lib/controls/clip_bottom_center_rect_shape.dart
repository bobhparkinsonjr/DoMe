import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

/*

sample usage:

  ClipPath(
    clipper: ClipBRRectShape(clipRatio: 0.03),
    child:
  )

*/

/*
           1                 4
------------                 ------------
            \               /
             --------------
             2            3

*/

///////////////////////////////////////////////////////////////////////////////////////////////////

class ClipBottomCenterRectShape extends CustomClipper<Path> {
  ClipBottomCenterRectShape({this.clipWidthRatio = 0.4, this.clipHeightRatio = 0.2});

  double clipWidthRatio;
  double clipHeightRatio;

  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    double xr = width * clipWidthRatio;
    double yr = height * clipHeightRatio;

    double p1x = (width - xr) * 0.5;
    double p1y = height - yr;

    double p2x = p1x + yr;
    double p2y = height;

    double p4x = width - p1x - 1.0;
    double p4y = height - yr;

    double p3x = p4x - yr;
    double p3y = height;

    Path p = Path();

    p.lineTo(width, 0.0);
    p.lineTo(width, p4y);
    p.lineTo(p4x, p4y);
    p.lineTo(p3x, p3y);
    p.lineTo(p2x, p2y);
    p.lineTo(p1x, p1y);
    p.lineTo(0.0, p1y);
    p.close();

    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
