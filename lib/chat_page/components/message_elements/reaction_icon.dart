import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class ReactionIcon extends StatelessWidget {
  const ReactionIcon(
      {super.key,
      required this.reaction,
      required this.onTap,
      this.isAnonymous = false,
      this.isSelected});

  final Reaction reaction;
  final Function() onTap;
  final bool isAnonymous;
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Icon(
          color: isAnonymous
              ? Colors.white
              : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
          isSelected == null
              ? reaction == Reaction.like
                  ? Symbols.thumb_up
                  : Symbols.thumb_down
              : reaction == Reaction.like
                  ? isSelected!
                      ? Icons.thumb_up
                      : Symbols.thumb_up
                  : reaction == Reaction.dislike
                      ? isSelected!
                          ? Icons.thumb_down
                          : Symbols.thumb_down
                      : Symbols.thumb_down,
          size: isTablet ? 22 : 18,
        ),
      ),
    );
  }
}
