import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_badge.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_native_database_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

String nativeDbScopeLabelKey(NativeDbScope scope) {
  switch (scope) {
    case NativeDbScope.user:
      return Strings.nativeDbScopePrivate;
    case NativeDbScope.company:
      return Strings.nativeDbScopeCompany;
    case NativeDbScope.conversation:
      return Strings.nativeDbScopeConversation;
  }
}

class NativeDatabaseScopeBadge extends StatelessWidget {
  const NativeDatabaseScopeBadge({
    super.key,
    required this.scope,
    required this.isAnonymous,
  });

  final NativeDbScope scope;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final Color bg = isAnonymous
        ? Colors.white12
        : MyStyles.pupauTheme(!Get.isDarkMode).primary.withValues(alpha: 0.12);
    final Color fg = isAnonymous
        ? Colors.white
        : MyStyles.getTextTheme(
                isLightTheme: !Get.isDarkMode,
              ).bodyMedium?.color ??
              Colors.black;
    return CustomBadge(
      text: nativeDbScopeLabelKey(scope).tr,
      background: bg,
      foreground: fg,
    );
  }
}

class NativeDatabaseBadge extends StatelessWidget {
  const NativeDatabaseBadge({
    super.key,
    required this.text,
    required this.isAnonymous,
  });

  final String text;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final Color border = isAnonymous
        ? Colors.white70
        : MyStyles.pupauTheme(!Get.isDarkMode).grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: Text(text, style: StyleService.toolNormalTextStyle(isDark)),
    );
  }
}

class NativeDatabaseChip extends StatelessWidget {
  const NativeDatabaseChip({
    super.key,
    required this.text,
    required this.isAnonymous,
  });

  final String text;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final Color border = isAnonymous
        ? Colors.white70
        : MyStyles.pupauTheme(!Get.isDarkMode).grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: Text(text, style: StyleService.toolNormalTextStyle(isDark)),
    );
  }
}
