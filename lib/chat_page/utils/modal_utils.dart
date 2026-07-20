import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/theme_extensions/pupau_theme_data.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Helper function to get safe context for modals
/// This ensures modals work correctly when the plugin is used in other projects
BuildContext? getSafeModalContext() {
  try {
    PupauChatController chatController = Get.find();
    return chatController.safeContext;
  } catch (e) {
    return null;
  }
}

/// Central entry point for every Wolt modal in this plugin — use this
/// instead of calling `WoltModalSheet.show` directly.
///
/// `WoltModalSheetPage`'s own `pageListBuilder` callback runs exactly once
/// per modal (cached internally by the package), so anything it reads
/// directly — e.g. `MyStyles.pupauTheme(!Get.isDarkMode)` passed straight
/// into a page's `backgroundColor:` — is frozen at modal-open time and
/// never updates if the app's light/dark theme toggles while the modal is
/// still open. `modalDecorator`, by contrast, is re-invoked on every
/// rebuild of the modal's own persistent state, so re-supplying the theme
/// extensions here — read fresh each call — makes the modal chrome
/// (background/surface tint) genuinely live. See
/// WOLT_MODAL_SHEET_THEME_FIX_HANDOFF.md for the full mechanism.
///
/// Individual `WoltModalSheetPage`s must NOT set their own
/// `backgroundColor`/`surfaceTintColor` — an explicit override always wins
/// over this theme default and would silently defeat the fix. Any other
/// theme-dependent content inside a page (`child:`, `topBarTitle:`, …)
/// still needs its own `Builder` reading
/// `Theme.of(context).extension<PupauThemeData>()!` to be live — this
/// helper only fixes the modal's own chrome.
Future<T?> showPupauModalSheet<T>({
  required BuildContext context,
  required WoltModalSheetPageListBuilder pageListBuilder,
}) {
  return WoltModalSheet.show<T>(
    context: context,
    pageListBuilder: pageListBuilder,
    modalDecorator: (Widget child) {
      final PupauThemeData pupauTheme = MyStyles.pupauTheme(!Get.isDarkMode);
      return Theme(
        data: Theme.of(context).copyWith(
          extensions: [
            pupauTheme,
            WoltModalSheetThemeData(
              backgroundColor: pupauTheme.white,
              surfaceTintColor: pupauTheme.white,
            ),
          ],
        ),
        child: child,
      );
    },
  );
}



