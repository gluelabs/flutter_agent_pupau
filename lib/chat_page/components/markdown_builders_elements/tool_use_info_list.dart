import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/tool_use_info.dart';

class ToolUseInfoList extends StatelessWidget {
  const ToolUseInfoList({
    super.key,
    required this.infoList,
    required this.isAnonymous,
    this.forceExpanded = false,
  });

  final Map<String, dynamic> infoList;
  final bool isAnonymous;
  final bool forceExpanded;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: infoList.length,
      itemBuilder: (context, index) {
        String infoKey = infoList.keys.elementAt(index);
        String infoValue = infoList[infoKey].toString();
        return Padding(
          padding: forceExpanded || infoList.length == 1
              ? const EdgeInsets.only(bottom: 6)
              : const EdgeInsets.only(bottom: 0),
          child: ToolUseInfo(
              infoKey: infoKey,
              infoValue: infoValue,
              isAnonymous: isAnonymous,
              forceExpanded:  forceExpanded || infoList.length == 1),
        );
      },
    );
  }
}
