// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/setting_denied_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceService {
  static bool? _isTablet;
  static bool _isTabletInitialized = false;

  static bool get isTablet => _isTablet ?? false;

  static void initializeTabletCheck(BuildContext context) {
    if (_isTabletInitialized) return;
    try {
      final mediaQuery = MediaQuery.of(context);
      _isTablet = mediaQuery.size.shortestSide > 600;
    } catch (e) {
      _isTablet = false;
    }
    _isTabletInitialized = true;
  }

  static String getDeviceType() {
    if (Platform.isAndroid) return "android";
    if (Platform.isIOS) return "ios";
    return "web";
  }

  static Future<bool> openLink(
    String link, {
    String? href,
    String title = "",
  }) async {
    try {
      String urlString = GetUtils.isURL(link) ? link : (href ?? "");
      if (!urlString.contains("https://") && !urlString.contains("http://")) {
        urlString = "https://$urlString";
      }
      Uri url = Uri.parse(urlString);
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }

  static DateTime? getLocalDate(DateTime? date) {
    if (date == null) return null;
    final localTimeZone = DateTime.now().timeZoneOffset;
    return date.add(localTimeZone);
  }

  static void isCameraDeniedError(dynamic error) {
    if (error is PlatformException && error.code == "camera_access_denied") {
      showSettingDeniedDialog(Strings.cameraAccessDenied.tr);
    }
  }

  /// Safely gets the screen width, handling cases where context might not be available
  static double get width {
    try {
      BuildContext? context = getSafeModalContext();
      if (context != null) {
        try {
          return MediaQuery.of(context).size.width;
        } catch (e) {
          // MediaQuery failed, try Get.width
          try {
            return Get.width;
          } catch (e) {
            // Fallback to default
            return 400.0;
          }
        }
      } else {
        // No context, try Get.width
        try {
          return Get.width;
        } catch (e) {
          // Fallback to default
          return 400.0;
        }
      }
    } catch (e) {
      // Complete fallback
      return 400.0;
    }
  }

  /// Safely gets the screen height, handling cases where context might not be available
  static double get height {
    try {
      BuildContext? context = getSafeModalContext();
      if (context != null) {
        try {
          return MediaQuery.of(context).size.height;
        } catch (e) {
          // MediaQuery failed, try Get.height
          try {
            return Get.height;
          } catch (e) {
            // Fallback to default
            return 800.0;
          }
        }
      } else {
        // No context, try Get.height
        try {
          return Get.height;
        } catch (e) {
          // Fallback to default
          return 800.0;
        }
      }
    } catch (e) {
      // Complete fallback
      return 800.0;
    }
  }
}
