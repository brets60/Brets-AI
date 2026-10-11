import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ProgressAssessmentChart extends StatefulWidget {
  final List<AssessmentPoint> points;

  const ProgressAssessmentChart({
    super.key,
    required this.points,
  });

  @override
  State<ProgressAssessmentChart> createState() => _ProgressAssessmentChartState();
}

class _ProgressAssessmentChartState extends State<ProgressAssessmentChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161C2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF263048), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selected point tooltip if user tapped
          if (selectedIndex != null && selectedIndex! < widget.points.length) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGlow),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.points[selectedIndex!].dateLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Overall: ${widget.points[selectedIndex!].overall.toInt()} • Grammar: ${widget.points[selectedIndex!].grammar.toInt()} • Fluency: ${widget.points[selectedIndex!].fluency.toInt()}',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Chart Drawing Canvas
          SizedBox(
            height: 320,
            child: GestureDetector(
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box != null && widget.points.isNotEmpty) {
                  final width = box.size.width - 70; // rough left padding
                  final localX = (details.localPosition.dx - 45).clamp(0, width);
                  final step = width / (widget.points.length - 1);
                  final idx = (localX / step).round().clamp(0, widget.points.length - 1);
                  setState(() => selectedIndex = idx);
                }
              },
              child: CustomPaint(
                painter: _MultiLineProgressPainter(
                  points: widget.points,
                  selectedIndex: selectedIndex,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // X-Axis Subtitle
          const Center(
            child: Text(
              'Assessment Date',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Legend (matching Image 5)
          const Text(
            'Legend:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _buildLegendItem('Overall', AppColors.overall),
              _buildLegendItem('Fluency', AppColors.fluency),
              _buildLegendItem('Grammar', AppColors.grammar),
              _buildLegendItem('Pronunciation', AppColors.pronunciation),
              _buildLegendItem('Vocabulary', AppColors.vocabulary),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MultiLineProgressPainter extends CustomPainter {
  final List<AssessmentPoint> points;
  final int? selectedIndex;

  _MultiLineProgressPainter({
    required this.points,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPadding = 40.0;
    const rightPadding = 16.0;
    const topPadding = 20.0;
    const bottomPadding = 36.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = const Color(0xFF283248)
      ..strokeWidth = 1.0;

    final textStyle = const TextStyle(
      color: Color(0xFF8895A8),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    // Draw horizontal dashed grid lines and Y-axis labels (20, 40, 60, 80, 100)
    final yLevels = [20, 40, 60, 80, 100];
    for (final level in yLevels) {
      final y = topPadding + chartHeight - (level / 100.0) * chartHeight;

      // Draw label
      final textSpan = TextSpan(text: '$level', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(leftPadding - 32, y - 6));

      // Draw dashed horizontal line
      _drawDashedLine(canvas, Offset(leftPadding, y), Offset(size.width - rightPadding, y), gridPaint);
    }

    // Y Axis Title: 'Score'
    final scorePainter = TextPainter(
      text: const TextSpan(
        text: 'Score',
        style: TextStyle(
          color: Color(0xFF9AA7BC),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(8, topPadding + chartHeight / 2 + 18);
    canvas.rotate(-1.5708); // -90 deg
    scorePainter.paint(canvas, Offset.zero);
    canvas.restore();

    // Calculate X positions for each data point
    final stepX = chartWidth / (points.length - 1);
    final xCoords = List.generate(points.length, (i) => leftPadding + i * stepX);

    // Draw X-axis date labels (Sep 1 to Oct 13)
    if (points.isNotEmpty) {
      // First label
      final firstPainter = TextPainter(
        text: TextSpan(text: points.first.dateLabel, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      firstPainter.paint(canvas, Offset(leftPadding - 4, size.height - bottomPadding + 10));

      // Last label
      final lastPainter = TextPainter(
        text: TextSpan(text: points.last.dateLabel, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      lastPainter.paint(
        canvas,
        Offset(size.width - rightPadding - lastPainter.width + 4, size.height - bottomPadding + 10),
      );
    }

    // Helper to calculate Y from 0-100 score
    double getY(double score) => topPadding + chartHeight - (score / 100.0) * chartHeight;

    // Series Definitions matching Image 5
    final seriesList = [
      _Series(
        color: AppColors.overall,
        values: points.map((p) => p.overall).toList(),
      ),
      _Series(
        color: AppColors.fluency,
        values: points.map((p) => p.fluency).toList(),
      ),
      _Series(
        color: AppColors.grammar,
        values: points.map((p) => p.grammar).toList(),
      ),
      _Series(
        color: AppColors.pronunciation,
        values: points.map((p) => p.pronunciation).toList(),
      ),
      _Series(
        color: AppColors.vocabulary,
        values: points.map((p) => p.vocabulary).toList(),
      ),
    ];

    // Draw each series line and dots
    for (final series in seriesList) {
      final linePaint = Paint()
        ..color = series.color
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final dotPaint = Paint()
        ..color = series.color
        ..style = PaintingStyle.fill;

      final dotBorderPaint = Paint()
        ..color = const Color(0xFF161C2C)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < points.length; i++) {
        final x = xCoords[i];
        final y = getY(series.values[i]);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevX = xCoords[i - 1];
          final prevY = getY(series.values[i - 1]);
          final midX = (prevX + x) / 2;
          path.cubicTo(midX, prevY, midX, y, x, y);
        }
      }

      // Draw smooth line
      canvas.drawPath(path, linePaint);

      // Draw node dots
      for (int i = 0; i < points.length; i++) {
        final x = xCoords[i];
        final y = getY(series.values[i]);
        final isSelected = selectedIndex == i;

        canvas.drawCircle(Offset(x, y), isSelected ? 6.5 : 4.5, dotPaint);
        canvas.drawCircle(Offset(x, y), isSelected ? 6.5 : 4.5, dotBorderPaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(startX + dashWidth < p2.dx ? startX + dashWidth : p2.dx, p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _MultiLineProgressPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.points != points;
  }
}

class _Series {
  final Color color;
  final List<double> values;
  _Series({required this.color, required this.values});
}
