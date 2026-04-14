import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

class SpreadsheetRowCard extends StatefulWidget {
  const SpreadsheetRowCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.row,
    required this.isAnonymous,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Map<String, dynamic> row;
  final bool isAnonymous;

  @override
  State<SpreadsheetRowCard> createState() => _SpreadsheetRowCardState();
}

class _SpreadsheetRowCardState extends State<SpreadsheetRowCard> {
  static const int _pageSize = 20;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || widget.isAnonymous;
    final preview = widget.row.entries.toList();
    final TextStyle titleStyle = StyleService.toolHeaderTextStyle(isDark);
    final TextStyle metaStyle = StyleService.toolNormalTextStyle(isDark);

    final int visibleCount = preview.length.clamp(0, (_page + 1) * _pageSize);
    final visible = preview.take(visibleCount).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 20, color: widget.iconColor),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.title, style: titleStyle)),
            ],
          ),
          if (visible.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                for (final e in visible)
                  Text('${e.key}: ${e.value}', style: metaStyle),
              ],
            ),
          ],
          if (preview.length > visibleCount)
            Align(
              alignment: Alignment.centerLeft,
              child: CustomButton(
                onPressed: () => setState(() => _page += 1),
                text: Strings.continue_.tr,
                isPrimary: false,
                textStyle: metaStyle,
              ),
            ),
        ],
      ),
    );
  }
}
