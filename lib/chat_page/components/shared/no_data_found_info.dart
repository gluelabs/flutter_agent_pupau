import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';

class NoDataFoundInfo extends StatelessWidget {
  const NoDataFoundInfo({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: isTablet ? 18 : 14)),
    ));
  }
}
