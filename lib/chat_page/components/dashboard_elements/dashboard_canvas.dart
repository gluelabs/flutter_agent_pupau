import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/canvas_header.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_content.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_item.dart';

class DashboardCanvas extends StatelessWidget {
  const DashboardCanvas({
    super.key,
    required this.item,
    required this.isAnonymous,
  });

  final DashboardCanvasItem item;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CanvasHeader(title: item.canvasTitle),
        Expanded(
          child: SingleChildScrollView(
            child: DashboardCanvasContent(item: item, isAnonymous: isAnonymous),
          ),
        ),
      ],
    );
  }
}
