// ignore_for_file: constant_identifier_names

library;

import 'package:flutter/material.dart';

import 'package:card_swiper/src/transformer_page_view/transformer_page_view.dart';

class WarmPainter extends BasePainter {
  WarmPainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    final progress = page - index;
    final distance = size + space;
    final start = index * (size + space);

    if (progress > 0.5) {
      final right = start + size + distance;
      //progress=>0.5-1.0
      //left:0.0=>distance

      final left = index * distance + distance * (progress - 0.5) * 2;
      canvas.drawRRect(
        RRect.fromLTRBR(left, 0.0, right, size, Radius.circular(radius)),
        _paint,
      );
    } else {
      final right = start + size + distance * progress * 2;

      canvas.drawRRect(
        RRect.fromLTRBR(start, 0.0, right, size, Radius.circular(radius)),
        _paint,
      );
    }
  }
}

class DropPainter extends BasePainter {
  DropPainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    final progress = page - index;
    final dropHeight = widget.dropHeight;
    final rate = (0.5 - progress).abs() * 2;
    final scale = widget.scale;

    //lerp(begin, end, progress)

    canvas.drawCircle(
      Offset(
        radius + (page * (size + space)),
        radius - dropHeight * (1 - rate),
      ),
      radius * (scale + rate * (1.0 - scale)),
      _paint,
    );
  }
}

class NonePainter extends BasePainter {
  NonePainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    final progress = page - index;
    final secondOffset =
        index == widget.count - 1
            ? radius
            : radius + ((index + 1) * (size + space));

    if (progress > 0.5) {
      canvas.drawCircle(Offset(secondOffset, radius), radius, _paint);
    } else {
      canvas.drawCircle(
        Offset(radius + (index * (size + space)), radius),
        radius,
        _paint,
      );
    }
  }
}

class SlidePainter extends BasePainter {
  SlidePainter(super.widget, super.page, super.index, super.paint);

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    canvas.drawCircle(
      Offset(radius + (page * (size + space)), radius),
      radius,
      _paint,
    );
  }
}

class ScalePainter extends BasePainter {
  ScalePainter(super.widget, super.page, super.index, super.paint);

  @override
  bool _shouldSkip(int index) {
    if (this.index == widget.count - 1) {
      return index == 0 || index == this.index;
    }
    return index == this.index || index == this.index + 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    final space = widget.space;
    final size = widget.size;
    final radius = size / 2;
    final c = widget.count;
    for (var i = 0; i < c; ++i) {
      if (_shouldSkip(i)) {
        continue;
      }
      canvas.drawCircle(
        Offset(i * (size + space) + radius, radius),
        radius * widget.scale,
        _paint,
      );
    }

    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    final secondOffset =
        index == widget.count - 1
            ? radius
            : radius + ((index + 1) * (size + space));

    final progress = page - index;
    _paint.color = Color.lerp(widget.activeColor, widget.color, progress)!;
    //last
    canvas.drawCircle(
      Offset(radius + (index * (size + space)), radius),
      lerp(radius, radius * widget.scale, progress),
      _paint,
    );
    //first
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress)!;
    canvas.drawCircle(
      Offset(secondOffset, radius),
      lerp(radius * widget.scale, radius, progress),
      _paint,
    );
  }
}

class ColorPainter extends BasePainter {
  ColorPainter(super.widget, super.page, super.index, super.paint);

  @override
  bool _shouldSkip(int index) {
    if (this.index == widget.count - 1) {
      return index == 0 || index == this.index;
    }
    return index == this.index || index == this.index + 1;
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    final progress = page - index;
    final secondOffset =
        index == widget.count - 1
            ? radius
            : radius + ((index + 1) * (size + space));

    _paint.color = Color.lerp(widget.activeColor, widget.color, progress)!;
    //left
    canvas.drawCircle(
      Offset(radius + (index * (size + space)), radius),
      radius,
      _paint,
    );
    //right
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress)!;
    canvas.drawCircle(Offset(secondOffset, radius), radius, _paint);
  }
}

abstract class BasePainter extends CustomPainter {
  final PageIndicator widget;
  final double page;
  final int index;
  final Paint _paint;

  double lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }

  BasePainter(this.widget, this.page, this.index, this._paint);

  void draw(Canvas canvas, double space, double size, double radius);

  bool _shouldSkip(int index) {
    return false;
  }

  //double secondOffset = index == widget.count-1 ? radius : radius + ((index + 1) * (size + space));

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    final space = widget.space;
    final size = widget.size;
    final radius = size / 2;
    final c = widget.count;
    for (var i = 0; i < c; ++i) {
      if (_shouldSkip(i)) {
        continue;
      }
      canvas.drawCircle(
        Offset(i * (size + space) + radius, radius),
        radius,
        _paint,
      );
    }

    var page = this.page;
    if (page < index) {
      page = 0.0;
    }
    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  bool shouldRepaint(BasePainter oldDelegate) {
    return oldDelegate.page != page;
  }
}

class _PageIndicatorState extends State<PageIndicator> {
  int index = 0;
  double page = 0;
  final _paint = Paint();

  BasePainter _createPainter() {
    switch (widget.layout) {
      case PageIndicatorLayout.NONE:
        return NonePainter(widget, page, index, _paint);
      case PageIndicatorLayout.SLIDE:
        return SlidePainter(widget, page, index, _paint);
      case PageIndicatorLayout.WARM:
        return WarmPainter(widget, page, index, _paint);
      case PageIndicatorLayout.COLOR:
        return ColorPainter(widget, page, index, _paint);
      case PageIndicatorLayout.SCALE:
        return ScalePainter(widget, page, index, _paint);
      case PageIndicatorLayout.DROP:
        return DropPainter(widget, page, index, _paint);
      default:
        throw Exception('Not a valid layout');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      width: widget.count * widget.size + (widget.count - 1) * widget.space,
      height: widget.size,
      child: CustomPaint(painter: _createPainter()),
    );

    if (widget.layout == PageIndicatorLayout.SCALE ||
        widget.layout == PageIndicatorLayout.COLOR) {
      child = ClipRect(child: child);
    }

    return IgnorePointer(child: child);
  }

  void _setInitialPage() {
    // use the initial page index but cut off
    // the offset specified when looping (kMiddleValue)
    index = widget.controller.initialPage % kMiddleValue;
    page = index.toDouble();
  }

  void _onController() {
    if (!widget.controller.hasClients) return;
    page = widget.controller.page ?? 0.0;
    index = page.floor();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _setInitialPage();
  }

  @override
  void didUpdateWidget(PageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }
}

enum PageIndicatorLayout { NONE, SLIDE, WARM, COLOR, SCALE, DROP }

class PageIndicator extends StatefulWidget {
  /// size of the dots
  final double size;

  /// space between dots.
  final double space;

  /// count of dots
  final int count;

  /// active color
  final Color activeColor;

  /// normal color
  final Color color;

  /// layout of the dots,default is [PageIndicatorLayout.SLIDE]
  final PageIndicatorLayout? layout;

  // Only valid when layout==PageIndicatorLayout.scale
  final double scale;

  // Only valid when layout==PageIndicatorLayout.drop
  final double dropHeight;

  final PageController controller;

  final double activeSize;

  const PageIndicator({
    required this.count,
    required this.controller,
    super.key,
    this.size = 20.0,
    this.space = 5.0,
    this.activeSize = 20.0,
    this.color = Colors.white30,
    this.layout = PageIndicatorLayout.SLIDE,
    this.activeColor = Colors.white,
    this.scale = 0.6,
    this.dropHeight = 20.0,
  });

  @override
  State<StatefulWidget> createState() {
    return _PageIndicatorState();
  }
}
