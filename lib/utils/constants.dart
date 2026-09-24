import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class Constants {
  static const String assetPath = 'packages/flutter_agent_pupau/assets';
  static const String missingImage = '$assetPath/images/missing_image.png';

  /// Bundle id / applicationId of the official Pupau app. When the plugin runs
  /// inside any other host app, conversation sources are suffixed with `_PLUGIN`.
  static const String officialAppPackageName = 'ai.pupau.app';

  /// Material symbol used for all skills-related UI (FAB, stream bubbles, cards, badges).
  static const IconData skillIcon = Symbols.psychology;
}