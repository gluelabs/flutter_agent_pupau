import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selection_modal.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomSelectionField extends StatelessWidget {
  const CustomSelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.modalTitle,
    required this.modalItems,
    this.stickyActionBar,
    this.onTap,
    this.readOnly = false,
    this.showDeleteButton = false,
    this.onDeleteButtonTap,
  });

  final String label;
  final String value;
  final String modalTitle;
  final List<Widget> modalItems;
  final Widget? stickyActionBar;
  final Function()? onTap;
  final bool readOnly;
  final bool showDeleteButton;
  final Function()? onDeleteButtonTap;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Text(
              label,
              style: StyleService.fieldLabelStyle(Get.isDarkMode),
            ),
          ),
        ),
        AbsorbPointer(
          absorbing: readOnly,
          child: SizedBox(
            width: Get.width,
            child: Material(
              color: MyStyles.pupauTheme(!Get.isDarkMode).white,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onTap?.call();
                  if (modalItems.isNotEmpty) {
                    showCustomSelectionModal(
                      title: modalTitle,
                      items: modalItems,
                      stickyActionBar: stickyActionBar,
                    );
                  }
                },
                child: Container(
                  width: Get.width,
                  height: 42,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MyStyles.pupauTheme(!Get.isDarkMode).grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 12),
                      Expanded(
                        child: Opacity(
                          opacity: readOnly ? 0.5 : 1,
                          child: Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: isTablet ? 16 : 14),
                          ),
                        ),
                      ),
                      if (!readOnly && showDeleteButton)
                        IconButton(
                          onPressed: onDeleteButtonTap,
                          icon: Icon(Symbols.close, size: isTablet ? 20 : 18),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          splashRadius: isTablet ? 20 : 18,
                        ),
                      if (!readOnly)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Icon(
                                Symbols.chevron_right,
                                size: isTablet ? 26 : 24,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
