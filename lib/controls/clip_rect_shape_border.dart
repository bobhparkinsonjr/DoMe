import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class ClipRectShapeBorder extends ShapeBorder {
  double clipRatio;
  double maxSize;
  double thickness;
  Color outlineColor;

  ClipRectShapeBorder({this.clipRatio = 0.1, this.maxSize = -1.0, this.thickness = 1.0, this.outlineColor = Colors.black});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    double x0 = rect.left;
    double y0 = rect.top;

    double x1 = rect.right;
    double y1 = rect.bottom;

    double height = rect.height;
    double width = rect.width;

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

    p.moveTo(x0, y0 + yr);
    p.lineTo(x0, y1 - yr);
    p.lineTo(x0 + xr, y1);
    p.lineTo(x1 - xr, y1);
    p.lineTo(x1, y1 - yr);
    p.lineTo(x1, y0 + yr);
    p.lineTo(x1 - xr, y0);
    p.lineTo(x0 + xr, y0);
    p.close();

    return p;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    Paint paint = new Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
