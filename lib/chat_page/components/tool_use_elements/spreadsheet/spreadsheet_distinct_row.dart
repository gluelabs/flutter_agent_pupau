import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpreadsheetDistinctRow extends StatelessWidget {
  const SpreadsheetDistinctRow({
    super.key,
    required this.label,
    required this.count,
    required this.total,
    required this.max,
    required this.metaStyle,
    required this.isAnonymous,
  });

  final String label;
  final int count;
  final int total;
  final int max;
  final TextStyle metaStyle;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final double pct = total > 0 ? (count / total) : 0;
    final double barPct = pct.isFinite ? pct : 0;
    final String pctText = '${(pct * 100).round()}%';

    final Color trackColor = (Get.isDarkMode || isAnonymous)
        ? Colors.white12
        : Colors.black12;
    final Color fillColor = (Get.isDarkMode || isAnonymous)
        ? Colors.white70
        : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: metaStyle,
              ),
            ),
            const SizedBox(width: 10),
            Text('$count ($pctText)', style: metaStyle),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 10,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double w = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : 0;
                final double factor = barPct.clamp(0, 1).toDouble();
                final double fillW = w * factor;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: trackColor),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: fillW,
                        height: double.infinity,
                        child: ColoredBox(color: fillColor),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
