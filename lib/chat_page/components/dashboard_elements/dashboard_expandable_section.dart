import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/config_expandable_section.dart';

class DashboardExpandableSection extends StatelessWidget {
  const DashboardExpandableSection({
    super.key,
    required this.label,
    required this.childCount,
    required this.childBuilder,
  });

  final String label;
  final int childCount;
  final Widget Function(int index) childBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ConfigExpandableSection(
          initiallyExpanded: true,
          label: label,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List<Widget>.generate(childCount, (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 0 : 4,
                  bottom: index == childCount - 1 ? 12 : 0,
                ),
                child: childBuilder(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}
