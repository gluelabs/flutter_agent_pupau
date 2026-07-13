import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_element_data.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/citation_source_panel_modal.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Tappable `[n]` citation chip rendered inline in assistant message text
/// (§2 of the citations spec). Opens the source panel on tap.
class CitationChip extends StatelessWidget {
  const CitationChip({super.key, required this.data});

  final CitationElementData data;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final bool isTablet = DeviceService.isTablet;
    final Color primary = MyStyles.pupauTheme(!Get.isDarkMode).primary;
    final double fontSize = isTablet ? 14 : 13;
    final double diameter = isTablet ? 22 : 20;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Tooltip(
        message: data.tooltipLabel,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showCitationSourcePanel(data: data),
          child: Container(
            width: diameter,
            height: diameter,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary),
            ),
            child: Text(
              '${data.citationNumber}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
