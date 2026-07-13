import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Groundedness verification badge (§3.2), only for `CITATIONS_VERIFIED`
/// turns. Status → action:
/// - absent/`SKIPPED`/`FAILED` → nothing (fail-open, never a "0% grounded").
/// - `PENDING` → "Verifying…" placeholder, never blocks.
/// - `DONE` → score badge.
class GroundingVerificationBadge extends StatelessWidget {
  const GroundingVerificationBadge({super.key, required this.message});

  final PupauMessage message;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final GroundingInfo? grounding = message.grounding;
    if (grounding == null || grounding.overridden) return const SizedBox.shrink();
    final GroundingVerificationStatus? status = grounding.verificationStatus;
    if (status == null ||
        status == GroundingVerificationStatus.skipped ||
        status == GroundingVerificationStatus.failed) {
      return const SizedBox.shrink();
    }

    final bool isTablet = DeviceService.isTablet;
    final double fontSize = isTablet ? 15 : 13;

    if (status == GroundingVerificationStatus.pending) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 11,
              height: 11,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: MyStyles.pupauTheme(!Get.isDarkMode).primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              Strings.citationVerificationPending.tr,
              style: TextStyle(fontSize: fontSize),
            ),
          ],
        ),
      );
    }

    final GroundingVerification? verification = grounding.verification;
    if (verification == null) return const SizedBox.shrink();
    final int scorePercent = (verification.score.clamp(0, 1) * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.verified,
              size: isTablet ? 18 : 16,
              color: MyStyles.pupauTheme(!Get.isDarkMode).green,
            ),
            const SizedBox(width: 4),
            Text(
              '$scorePercent% ${Strings.citationVerificationGrounded.tr}',
              style: TextStyle(fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}
