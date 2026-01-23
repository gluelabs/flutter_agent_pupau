import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ToolUseBrowserUseData {
  final String name;
  final String url;
  final bool getDataLayer;
  final bool getNetwork;

  // Browser metadata
  final String? status;
  final String? timestamp;
  final bool browserConnected;
  final bool browserLaunched;
  final String? pageUrl;
  final int actualWidth;
  final int actualHeight;
  final String? executionTime;

  // Results and errors
  final List<String> results;
  final String? error;
  final List<String> logs;

  // Page content
  final String? visibleHtml;
  final String? screenshot;

  // Data layer
  final List<Map<String, dynamic>> datalayerData;

  // Network information
  final List<NetworkItem> networkItems;

  // Frontend only
  final bool isLoadingPlaceholder;

  ToolUseBrowserUseData({
    required this.name,
    required this.url,
    required this.getDataLayer,
    required this.getNetwork,
    this.status,
    this.timestamp,
    this.browserConnected = false,
    this.browserLaunched = false,
    this.pageUrl,
    this.actualWidth = 0,
    this.actualHeight = 0,
    this.executionTime,
    this.results = const [],
    this.error,
    this.logs = const [],
    this.visibleHtml,
    this.screenshot,
    this.datalayerData = const [],
    this.networkItems = const [],
    this.isLoadingPlaceholder = false,
  });

  String getBrowserUseActionName() {
    try {
      const String prefix = 'playwright_';
      if (name.startsWith(prefix)) {
        final String action =
            "Browser: ${name.substring(prefix.length).toUpperCase()}";
        return action;
      }
      return "Browser: ${name.toUpperCase()}";
    } catch (e) {
      return "Browser: ${name.toUpperCase()}";
    }
  }

  BrowserAction getBrowserUseAction() {
    String actionName = getBrowserUseActionName();
    switch (actionName) {
      case "Browser: NAVIGATE":
        return BrowserAction.navigate;
      case "Browser: SCREENSHOT":
        return BrowserAction.screenshot;
      default:
        return BrowserAction.navigate;
    }
  }

  int get inspectorTabsCount {
    int count = 0;
    if (hasNetwork) count++;
    if (hasDatalayer) count++;
    return count;
  }

  bool get hasDatalayer => datalayerData.isNotEmpty;
  bool get hasNetwork => networkItems.isNotEmpty;

  factory ToolUseBrowserUseData.fromJson(
      Map<String, dynamic> json, Map<String, dynamic>? jsonTypeDetails) {
    List info = json['info'] ?? [];
    Map<String, dynamic> firstInfo = info.firstOrNull ?? {};
    Map<String, dynamic> cleanedInfo =
        jsonDecode(firstInfo["result"]?['cleaned'] ?? "{}") ?? {};
    Map<String, dynamic> network = cleanedInfo['network'] ?? {};
    List<NetworkItem> networkItems = [];
    if (network['items'] != null) {
      networkItems = (network['items'] as List)
          .map((item) => NetworkItem.fromJson(item))
          .toList();
    }

    // Extract datalayer
    Map<String, dynamic> datalayer = cleanedInfo['datalayer'] ?? {};

    Map<String, dynamic> metadata = cleanedInfo['metadata'] ?? {};

    return ToolUseBrowserUseData(
      url: jsonTypeDetails?["toolArgs"]?["url"] ?? "",
      getDataLayer: jsonTypeDetails?["toolArgs"]?["getDataLayer"] ?? false,
      getNetwork: jsonTypeDetails?["toolArgs"]?["getNetwork"] ?? false,

      // Browser metadata
      name: metadata["toolName"] ?? "",
      status: metadata['status'],
      timestamp: metadata['timestamp'],
      browserConnected: metadata['browserConnected'] ?? false,
      browserLaunched: metadata['browserLaunched'] ?? false,
      pageUrl: metadata['pageUrl'],
      actualWidth: getInt(metadata['actualWidth']),
      actualHeight: getInt(metadata['actualHeight']),
      executionTime: metadata['executionTime'],
      results: cleanedInfo['results'] != null
          ? (cleanedInfo['results'] as List)
              .where((item) => item != null)
              .map((item) => item?.toString() ?? "")
              .toList()
          : [],
      error: cleanedInfo['error'],
      logs: cleanedInfo['logs'] != null
          ? (cleanedInfo['logs'] as List)
              .where((item) => item != null)
              .map((item) => item?.toString() ?? "")
              .toList()
          : [],
      visibleHtml: cleanedInfo['visibleHtml'],
      screenshot: cleanedInfo['screenshot'],
      datalayerData: datalayer['data'] != null
          ? (datalayer['data'] as List)
              .where((item) => item != null)
              .map((item) => item == null ? <String, dynamic>{} : Map<String, dynamic>.from(item as Map))
              .toList()
          : [],
      networkItems: networkItems.isNotEmpty ? networkItems : [],
    );
  }
}

class NetworkItem {
  final String id;
  final String status;
  final int timestamp;
  final String method;
  final String url;
  final String host;
  final String pageId;
  final String resourceType;
  final Map<String, String> requestHeaders;
  final String? postData;
  final String pageUrl;
  final String? error;

  NetworkItem({
    required this.id,
    required this.status,
    required this.timestamp,
    required this.method,
    required this.url,
    required this.host,
    required this.pageId,
    required this.resourceType,
    required this.requestHeaders,
    this.postData,
    required this.pageUrl,
    this.error,
  });

  Color getStatusColor() {
    if (status.startsWith("2") || status.startsWith("3")) {
      return MyStyles.pupauTheme(!Get.isDarkMode).green;
    } else if (status.startsWith("4") || status.startsWith("5")) {
      return MyStyles.pupauTheme(!Get.isDarkMode).redAlarm;
    } else if (status.startsWith("1")) {
      return MyStyles.pupauTheme(!Get.isDarkMode).blueInfo;
    } else {
      return MyStyles.pupauTheme(!Get.isDarkMode).grey;
    }
  }

  factory NetworkItem.fromJson(Map<String, dynamic> json) {
    Map<String, String> headers = {};
    if (json['requestHeaders'] != null) {
      headers = Map<String, String>.from(json['requestHeaders']);
    }

    return NetworkItem(
      id: json['id'] ?? '',
      status: json['status'] == null ? "" : json['status'].toString(),
      timestamp: getInt(json['timestamp']),
      method: json['method'] ?? '',
      url: json['url'] ?? '',
      host: json['host'] ?? '',
      pageId: json['pageId'] ?? '',
      resourceType: json['resourceType'] ?? '',
      requestHeaders: headers,
      postData: json['postData'],
      pageUrl: json['pageUrl'] ?? '',
      error: json['error'],
    );
  }
}

enum BrowserAction { navigate, screenshot }
