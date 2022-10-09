import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

/*

sample usage:

  ClipPath(
    clipper: ClipBRRectShape(clipRatio: 0.03),
    child:
  )

*/

///////////////////////////////////////////////////////////////////////////////////////////////////

class ClipBRRectShape extends CustomClipper<Path> {
  ClipBRRectShape({this.clipRatio = 0.1, this.maxSize = -1.0});

  double clipRatio;
  double maxSize;

  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    double xr;
    double yr;

    if (width < height) {
      xr = width * clipRatio;
      if (maxSize > 0.0 && xr > maxSize) xr = maxSize;
      yr = xr;
    } else {
      yr = height * clipRatio;
      if (maxSize > 0.0 && yr > maxSize) yr = maxSize;
      xr = yr;
    }

    if (xr >= width) xr = width - 1;
    if (yr >= height) yr = height - 1;

    Path p = Path();

    p.lineTo(0, height - 1);
    p.lineTo(width - xr, height - 1);
    p.lineTo(width - 1, height - yr);
    p.lineTo(width - 1, 0);
    p.close();

    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
