import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssistantCapabilities extends StatefulWidget {
  const AssistantCapabilities({
    super.key,
    required this.assistant,
  });

  final Assistant assistant;

  @override
  State<AssistantCapabilities> createState() => _AssistantCapabilitiesState();
}

class _AssistantCapabilitiesState extends State<AssistantCapabilities> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    Set<String> capabilities =
        AssistantService.getCapabilities(widget.assistant).toSet();
    String? modelName = widget.assistant.model?.name;
    if (modelName != null) {
      bool canUseTools = widget.assistant.model?.canUseTools ?? false;
      if (canUseTools) capabilities.add("TOOL_USE");
    }
    return capabilities.isEmpty
        ? const SizedBox(height: 10)
        : Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          Strings.capabilities.tr,
                          style: TextStyle(
                              fontSize: isTablet ? 20 : 15,
                              fontWeight: FontWeight.w500,
                              color: MyStyles.pupauTheme(!Get.isDarkMode)
                                  .darkBlue),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          child: SingleChildScrollView(
                            scrollDirection:
                                _isOpen ? Axis.vertical : Axis.horizontal,
                            child: _isOpen
                                ? CapabilitiesOpen(capabilities: capabilities)
                                : CapabilitiesClosed(
                                    capabilities: capabilities),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isOpen = !_isOpen;
                      });
                    },
                    tooltip: _isOpen ? Strings.collapse.tr : Strings.expand.tr,
                    icon: Icon(
                        _isOpen ? Symbols.expand_less : Symbols.expand_more),
                  ),
                ),
              ],
            ),
          );
  }
}

class CapabilitiesClosed extends StatelessWidget {
  const CapabilitiesClosed({
    super.key,
    required this.capabilities,
  });

  final Set<String> capabilities;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Row(
      children: capabilities
          .map(
            (capability) => Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
              child: Tooltip(
                message: AssistantService.getCapabilityName(capability),
                child: Icon(
                  AssistantService.getCapabilityImage(capability),
                  size: isTablet ? 26 : 24,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class CapabilitiesOpen extends StatelessWidget {
  const CapabilitiesOpen({
    super.key,
    required this.capabilities,
  });

  final Set<String> capabilities;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Column(
      children: capabilities
          .map(
            (capability) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 8),
                    child: Icon(
                      AssistantService.getCapabilityImage(capability),
                      size: isTablet ? 26 : 24,
                    ),
                  ),
                  Text(
                    AssistantService.getCapabilityName(capability),
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
