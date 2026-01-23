import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachment_card.dart';

class AttachmentsList extends StatelessWidget {
  const AttachmentsList(
      {super.key, required this.attachments, required this.category});

  final List<Attachment> attachments;
  final String category;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return attachments.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(category,
                          style: TextStyle(
                              fontSize: isTablet ? 17 : 15,
                              color:
                                  MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                              fontWeight: FontWeight.w500))),
                ),
                ListView.builder(
                  itemCount: attachments.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      AttachmentCard(attachment: attachments[index]),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
