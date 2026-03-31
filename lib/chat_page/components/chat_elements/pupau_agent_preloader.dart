import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/bindings/chat_bindings.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/assistants_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';

/// Headless preloader for Pupau agent data.
///
/// **Use from the plugin package** so the plugin's state is warmed:
/// ```dart
/// import 'package:flutter_agent_pupau/flutter_agent_pupau.dart';
/// // ...
/// PupauAgentPreloader(config: config, builder: (context, assistant, isLoading) => ...);
/// ```
/// Do not copy this widget into your app; a local copy would warm your app's
/// controllers, not the plugin's, so opening chat would still fetch again.
///
/// This widget:
/// - Ensures chat bindings/controllers are registered for the provided [config]
/// - Preloads the [Assistant] model for the assistantId in [config]
/// - Lets the parent render any custom UI via [builder], without imposing layout
///
/// Safe for large lists (100+ assistants): controllers are shared, assistants
/// list is loaded once and reused across instances.
class PupauAgentPreloader extends StatefulWidget {
  const PupauAgentPreloader({
    super.key,
    required this.config,
    required this.builder,
  });

  /// Configuration for this assistant instance.
  final PupauConfig config;

  /// Builder that receives the loaded [Assistant] (or null while loading)
  /// and a boolean [isLoading]. The builder is responsible for all UI.
  final Widget Function(
    BuildContext context,
    Assistant? assistant,
    bool isLoading,
  ) builder;

  @override
  State<PupauAgentPreloader> createState() => _PupauAgentPreloaderState();
}

class _PupauAgentPreloaderState extends State<PupauAgentPreloader> {
  Assistant? _assistant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer heavy work until after first frame to avoid build-time side effects.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preload();
    });
  }

  Future<void> _preload() async {
    if (!mounted) return;

    // Ensure all chat-related controllers are registered once.
    ChatBinding(config: widget.config).dependencies();

    final PupauAssistantsController assistantsController =
        Get.find<PupauAssistantsController>();

    // If no assistants are loaded yet, trigger a batched load.
    if (assistantsController.assistants.isEmpty) {
      await assistantsController.getAssistants();
    } else {
      // If this specific assistant is missing and we are in apiKey mode,
      // fall back to loading just this assistant to avoid extra list calls.
      final AssistantType type = widget.config.isMarketplace
          ? AssistantType.marketplace
          : AssistantType.assistant;
      final existing = assistantsController.getAssistantById(
        widget.config.assistantId,
        type,
      );
      final bool isApiKey =
          widget.config.apiKey != null && widget.config.apiKey!.trim().isNotEmpty;
      if (existing == null && isApiKey) {
        await assistantsController.getSingleAssistant(
          widget.config.assistantId,
          widget.config.isMarketplace,
        );
      }
    }

    if (!mounted) return;

    final AssistantType type = widget.config.isMarketplace
        ? AssistantType.marketplace
        : AssistantType.assistant;
    final Assistant? assistant = assistantsController.getAssistantById(
      widget.config.assistantId,
      type,
    );

    setState(() {
      _assistant = assistant;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _assistant, _isLoading);
  }
}

