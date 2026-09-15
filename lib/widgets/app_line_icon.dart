import 'dart:math' as math;

import 'package:flutter/material.dart';

/// C/D 組圖示的語意名稱。SVG canonical source 位於 `assets/icons/`；
/// runtime 以 CustomPainter 描繪，避免為單色線性圖示新增 Flutter package。
enum AppLineIconKind {
  expiryExact,
  expiryRange,
  expiryMonthOnly,
  expiryUnknown,
  openedPackage,
  refrigerated,
  frozen,
  ambient,
  otherStorage,
}

class AppLineIcon extends StatelessWidget {
  const AppLineIcon({
    super.key,
    required this.kind,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  final AppLineIconKind kind;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColor =
        color ?? IconTheme.of(context).color ?? theme.colorScheme.onSurface;
    final icon = CustomPaint(
      size: Size.square(size),
      painter: _AppLineIconPainter(kind: kind, color: resolvedColor),
    );
    if (semanticLabel == null) return icon;
    return Semantics(image: true, label: semanticLabel, child: icon);
  }
}

class _AppLineIconPainter extends CustomPainter {
  const _AppLineIconPainter({required this.kind, required this.color});

  final AppLineIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 24;
    canvas.save();
    canvas.translate(
      (size.width - 24 * scale) / 2,
      (size.height - 24 * scale) / 2,
    );
    canvas.scale(scale);

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (kind) {
      case AppLineIconKind.expiryExact:
        _calendar(canvas, line, fill, _CalendarDetail.exact);
      case AppLineIconKind.expiryRange:
        _calendar(canvas, line, fill, _CalendarDetail.range);
      case AppLineIconKind.expiryMonthOnly:
        _calendar(canvas, line, fill, _CalendarDetail.monthOnly);
      case AppLineIconKind.expiryUnknown:
        _calendar(canvas, line, fill, _CalendarDetail.unknown);
      case AppLineIconKind.openedPackage:
        _openedPackage(canvas, line);
      case AppLineIconKind.refrigerated:
        _refrigerated(canvas, line);
      case AppLineIconKind.frozen:
        _frozen(canvas, line);
      case AppLineIconKind.ambient:
        _ambient(canvas, line);
      case AppLineIconKind.otherStorage:
        _otherStorage(canvas, line);
    }
    canvas.restore();
  }

  void _calendar(
    Canvas canvas,
    Paint line,
    Paint fill,
    _CalendarDetail detail,
  ) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTRB(3, 4, 21, 21),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, line);
    canvas.drawLine(const Offset(3, 9), const Offset(21, 9), line);
    canvas.drawLine(const Offset(8, 2), const Offset(8, 6), line);
    canvas.drawLine(const Offset(16, 2), const Offset(16, 6), line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(4, 5, 20, 8),
        const Radius.circular(1),
      ),
      fill,
    );

    switch (detail) {
      case _CalendarDetail.exact:
        canvas.drawCircle(const Offset(12, 15), 1.2, fill);
        canvas.drawCircle(const Offset(16, 15), 1.2, fill);
      case _CalendarDetail.range:
        final wave = Path()
          ..moveTo(6, 15)
          ..cubicTo(8, 12.5, 10, 17.5, 12, 15)
          ..cubicTo(14, 12.5, 16, 17.5, 18, 15);
        canvas.drawPath(wave, line);
      case _CalendarDetail.monthOnly:
        canvas.drawLine(const Offset(9, 11), const Offset(9, 19), line);
        canvas.drawLine(const Offset(15, 11), const Offset(15, 19), line);
        canvas.drawLine(const Offset(4, 15), const Offset(20, 15), line);
      case _CalendarDetail.unknown:
        final question = Path()
          ..moveTo(10.5, 14)
          ..cubicTo(10.5, 11.5, 14.5, 11.5, 14.5, 14)
          ..cubicTo(14.5, 15.5, 12.5, 15.5, 12.5, 17);
        canvas.drawPath(question, line);
        canvas.drawCircle(const Offset(12.5, 19), 0.9, fill);
    }
  }

  void _openedPackage(Canvas canvas, Paint line) {
    final box = Path()
      ..moveTo(4, 8)
      ..lineTo(20, 8)
      ..lineTo(19, 20)
      ..lineTo(5, 20)
      ..close();
    canvas.drawPath(box, line);
    canvas.drawLine(const Offset(4, 8), const Offset(12, 12), line);
    canvas.drawLine(const Offset(20, 8), const Offset(12, 12), line);
    canvas.drawLine(const Offset(12, 12), const Offset(12, 20), line);
    canvas.drawLine(const Offset(4, 8), const Offset(7, 4), line);
    canvas.drawLine(const Offset(7, 4), const Offset(17, 5), line);
    canvas.drawLine(const Offset(17, 5), const Offset(20, 8), line);
    canvas.drawLine(const Offset(7, 4), const Offset(12, 8), line);
  }

  void _refrigerated(Canvas canvas, Paint line) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(4, 2, 15, 22),
        const Radius.circular(2),
      ),
      line,
    );
    canvas.drawLine(const Offset(4, 11), const Offset(15, 11), line);
    canvas.drawLine(const Offset(7, 6), const Offset(7, 8), line);
    canvas.drawLine(const Offset(7, 14), const Offset(7, 16), line);
    canvas.drawLine(const Offset(19, 6), const Offset(19, 16), line);
    canvas.drawCircle(const Offset(19, 18), 2, line);
    canvas.drawLine(const Offset(19, 9), const Offset(19, 14), line);
  }

  void _frozen(Canvas canvas, Paint line) {
    const center = Offset(12, 12);
    canvas.drawCircle(center, 1.2, line);
    for (var index = 0; index < 3; index++) {
      final angle = index * math.pi / 3;
      final dx = math.cos(angle) * 8;
      final dy = math.sin(angle) * 8;
      canvas.drawLine(
        Offset(center.dx - dx, center.dy - dy),
        Offset(center.dx + dx, center.dy + dy),
        line,
      );
      final perpX = math.cos(angle + math.pi / 2) * 2;
      final perpY = math.sin(angle + math.pi / 2) * 2;
      canvas.drawLine(
        Offset(center.dx + dx * 0.72, center.dy + dy * 0.72),
        Offset(center.dx + dx * 0.72 - perpX, center.dy + dy * 0.72 - perpY),
        line,
      );
      canvas.drawLine(
        Offset(center.dx + dx * 0.72, center.dy + dy * 0.72),
        Offset(center.dx + dx * 0.72 + perpX, center.dy + dy * 0.72 + perpY),
        line,
      );
    }
  }

  void _ambient(Canvas canvas, Paint line) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(4, 3, 20, 21),
        const Radius.circular(2),
      ),
      line,
    );
    canvas.drawLine(const Offset(4, 9), const Offset(20, 9), line);
    canvas.drawLine(const Offset(4, 15), const Offset(20, 15), line);
    canvas.drawLine(const Offset(12, 5), const Offset(12, 7), line);
    canvas.drawLine(const Offset(12, 11), const Offset(12, 13), line);
    canvas.drawLine(const Offset(12, 17), const Offset(12, 19), line);
  }

  void _otherStorage(Canvas canvas, Paint line) {
    final box = Path()
      ..moveTo(3, 7)
      ..lineTo(12, 3)
      ..lineTo(21, 7)
      ..lineTo(12, 11)
      ..close();
    canvas.drawPath(box, line);
    canvas.drawLine(const Offset(3, 7), const Offset(3, 18), line);
    canvas.drawLine(const Offset(3, 18), const Offset(12, 22), line);
    canvas.drawLine(const Offset(12, 11), const Offset(12, 22), line);
    canvas.drawLine(const Offset(21, 7), const Offset(21, 18), line);
    canvas.drawLine(const Offset(21, 18), const Offset(12, 22), line);
    canvas.drawLine(const Offset(7, 5), const Offset(16, 9), line);
  }

  @override
  bool shouldRepaint(_AppLineIconPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}

enum _CalendarDetail { exact, range, monthOnly, unknown }
