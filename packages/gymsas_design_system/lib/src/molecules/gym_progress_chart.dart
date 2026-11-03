import 'dart:math' as math;
import 'package:flutter/material.dart';

class GymChartPoint {
  const GymChartPoint({
    required this.label,
    required this.value,
    required this.valueLabel,
  });
  final String label, valueLabel;
  final double? value;
}

class GymProgressChart extends StatelessWidget {
  const GymProgressChart({
    super.key,
    required this.points,
    required this.title,
    required this.emptyLabel,
  });
  final List<GymChartPoint> points;
  final String title, emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = points.map((p) => p.value).toList(growable: false);
    final maximum = values.whereType<double>().fold<double>(0, math.max);
    final hasValues = values.any((v) => v != null);
    return Semantics(
      label:
          '$title. ${points.map((p) => '${p.label}: ${p.valueLabel}').join('. ')}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasValues)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(emptyLabel, textAlign: TextAlign.center),
            )
          else ...[
            Text(
              maximum.toStringAsFixed(
                maximum == maximum.roundToDouble() ? 0 : 1,
              ),
              style: theme.textTheme.labelSmall,
            ),
            SizedBox(
              height: 190,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(Object.hashAll(values)),
                tween: Tween(begin: 0, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                builder: (context, factor, _) => CustomPaint(
                  painter: _ProgressPainter(
                    values,
                    maximum,
                    factor,
                    theme.colorScheme.primary,
                    theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
            const Text('0'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(points.first.label, style: theme.textTheme.labelSmall),
                if (points.length > 1)
                  Text(points.last.label, style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter(
    this.values,
    this.maximum,
    this.factor,
    this.color,
    this.gridColor,
  );
  final List<double?> values;
  final double maximum, factor;
  final Color color, gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 6.0;
    final height = size.height - inset * 2;
    final width = size.width - inset * 2;
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = inset + height * i / 3;
      canvas.drawLine(Offset(inset, y), Offset(size.width - inset, y), grid);
    }
    final line = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    bool connected = false;
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        connected = false;
        continue;
      }
      final x =
          inset +
          (values.length == 1 ? width / 2 : width * i / (values.length - 1));
      final y =
          inset +
          height -
          height * (maximum == 0 ? 0 : value / maximum) * factor;
      if (connected) {
        path.lineTo(x, y);
      } else {
        path.moveTo(x, y);
      }
      connected = true;
      if (values.length < 50) {
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
      }
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(_ProgressPainter old) =>
      old.values != values ||
      old.factor != factor ||
      old.color != color ||
      old.gridColor != gridColor;
}
