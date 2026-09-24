import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_badge.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomExpansionController extends GetxController {
  final RxBool isExpanded = false.obs;

  void toggleExpanded({bool? value}) {
    isExpanded.value = value ?? !isExpanded.value;
    update();
  }
}

class ConfigExpandableSection extends StatelessWidget {
  const ConfigExpandableSection({
    super.key,
    required this.content,
    required this.label,
    this.initiallyExpanded = false,
    this.duration,
    this.itemCount,
  });

  final Widget content;
  final String label;
  final bool initiallyExpanded;
  final Duration? duration;

  /// Shown as a small badge next to the arrow while the section is
  /// collapsed, so the count is visible without expanding it.
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    final bool wasRegistered = Get.isRegistered<CustomExpansionController>(
      tag: label,
    );
    final CustomExpansionController expansionController = wasRegistered
        ? Get.find<CustomExpansionController>(tag: label)
        : Get.put<CustomExpansionController>(
            CustomExpansionController(),
            tag: label,
          );
    if (!wasRegistered) {
      expansionController.isExpanded.value = initiallyExpanded;
    }
    final ExpandedTileController controller = ExpandedTileController(
      isExpanded: initiallyExpanded,
    );
    return ExpandedTile(
      controller: controller,
      expansionDuration: duration ?? Duration(milliseconds: 200),
      onTap: () => expansionController.toggleExpanded(),
      theme: ExpandedTileThemeData(
        headerColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        contentBackgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        footerBackgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        headerSplashColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        contentSeparatorColor: Colors.transparent,
        footerSeparatorColor: Colors.transparent,
        titlePadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        footerPadding: const EdgeInsets.all(0),
        headerPadding: const EdgeInsets.all(0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 2),
        leadingPadding: const EdgeInsets.all(0),
        trailingPadding: const EdgeInsets.only(
          right: 12,
          left: 12,
          bottom: 8,
          top: 8,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Obx(() {
        final bool isExpanded = expansionController.isExpanded.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isExpanded && itemCount != null)
              _CollapsedCountBadge(itemCount!),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isExpanded ? 0 : 0.75,
              child: const Icon(Symbols.chevron_left, size: 20),
            ),
          ],
        );
      }),
      content: content,
    );
  }
}

/// Same solid-background style as the app's other inline chips (e.g. the
/// "KB" chip on a message) so it reads clearly against the section header.
class _CollapsedCountBadge extends StatelessWidget {
  const _CollapsedCountBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CustomBadge(
        text: count.toString(),
        background: MyStyles.pupauTheme(!Get.isDarkMode).primary,
        foreground: MyStyles.pupauTheme(true).white,
      ),
    );
  }
}
