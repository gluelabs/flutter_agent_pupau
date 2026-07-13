import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_input_field.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AttachmentNoteSkeleton extends StatelessWidget {
  const AttachmentNoteSkeleton({super.key, required this.isEditable});

  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomInputField(
              label: Strings.noteName.tr,
              textController: TextEditingController(text: 'Note name placeholder'),
              readOnly: true,
              onChange: (_) {},
            ),
            CustomInputField(
              hint: Strings.noteHint.tr,
              textController: TextEditingController(text: 'Content line\nContent line\nContent line\nContent line\nContent line\nContent line\nContent line\nContent line'),
              maxlines: 8,
              readOnly: true,
              onChange: (_) {},
            ),
            const SizedBox(height: 24),
            if (isEditable)
              SizedBox(
                width: DeviceService.width,
                child: CustomButton(
                  text: Strings.create.tr,
                  onPressed: () {},
                ),
              ),
            if (isTablet) const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
