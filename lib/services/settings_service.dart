import 'dart:convert';
import 'package:flutter_agent_pupau/models/setting_model.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/settings.dart';

class SettingsService {

  static String getCompanySettingById(String settingId,
          {String? assistantId, bool isMarketplace = false}) =>
      "${ApiUrls.settingsUrl(isMarketplace)}?availableSettingId=$settingId${assistantId != null ? "&assistantId=$assistantId" : ""}";

  static String getCompanySettingGroupById(String groupSettingId,
          {String? assistantId, bool isMarketplace = false}) =>
      "${ApiUrls.settingsUrl(isMarketplace)}?settingGroupId=$groupSettingId${assistantId != null ? "&assistantId=$assistantId" : ""}";

  static String getUserSettingById({
    required String settingId,
    required String assistantId,
    bool isMarketplace = false,
  }) =>
      "${ApiUrls.settingsUserUrl(isMarketplace: isMarketplace)}?availableSettingId=$settingId&assistantId=$assistantId";

  static String generateSettingData(Setting setting) {
    String valueContent = "";
    for (int i = 0; i < setting.settingValues.length; i++) {
      valueContent +=
          '"${setting.settingValues[i].settingName}": ${jsonEncode(setting.settingValues[i].settingData)}';
      if (i < setting.settingValues.length - 1) {
        valueContent += ",";
      }
    }
    return '''
        [
          {
            "availableSettingId": "${setting.id}",
            "value": {
              $valueContent
              ${setting.data != {} ? ',"data": ${jsonEncode(setting.data)}' : ""}
            }
            ${setting.assistantId != null ? ',"assistantId": "${setting.assistantId}"' : ""}
          }
        ]
      ''';
  }

  static String generateSettingGroupData(List<Setting> settings) {
    String data = "[";
    for (Setting setting in settings) {
      String valueContent = "";
      for (int i = 0; i < setting.settingValues.length; i++) {
        valueContent +=
            '"${setting.settingValues[i].settingName}": ${jsonEncode(setting.settingValues[i].settingData)}';
        if (i < setting.settingValues.length - 1) {
          valueContent += ",";
        }
      }
      bool isLast = setting.id == settings.last.id;
      data += '''
          {
            "availableSettingId": "${setting.id}",
            "value": {
              $valueContent
              ${setting.data != {} ? ',"data": ${jsonEncode(setting.data)}' : ""}
            }
            ${setting.assistantId != null ? ',"assistantId": "${setting.assistantId}"' : ""}
          } ${!isLast ? ',' : ''}
        ''';
    }
    data += "]";
    return data;
  }

  static Future<dynamic> readSetting(String settingUrl,
      {bool isMarketplace = false}) async {
    dynamic settingData;
    await ApiService.call(
      settingUrl + (isMarketplace ? "&isMarketplace=true" : ""),
      RequestType.get,
      onSuccess: (response) => settingData = response.data,
      onError: (error) {},
    );
    return settingData;
  }

  static Future<bool> readSettingAttachmentsEnabled(String? assistantId) async {
    if (assistantId == null) return false;
    dynamic response = await readSetting(getCompanySettingById(
        Settings.settingAttachmentId,
        assistantId: assistantId));
    if (response != null) return response[Settings.settingEnableName] ?? true;
    return false;
  }

  static Future<bool> readSettingMultiTagEnabled(String? assistantId) async {
    if (assistantId == null) return false;
    dynamic response = await readSetting(getCompanySettingById(
        Settings.settingMultiTagId,
        assistantId: assistantId));
    if (response != null) return response[Settings.settingEnableName] ?? true;
    return false;
  }

  static Future<Map<String, dynamic>?> readUserSettingById({
    required String settingId,
    required String assistantId,
    bool isMarketplace = false,
  }) async {
    Map<String, dynamic>? settingData;
    await ApiService.call(
      getUserSettingById(
        settingId: settingId,
        assistantId: assistantId,
        isMarketplace: isMarketplace,
      ),
      RequestType.get,
      onSuccess: (response) {
        if (response.data is Map<String, dynamic>) {
          settingData = Map<String, dynamic>.from(response.data);
        }
      },
      onError: (_) {},
    );
    return settingData;
  }

  static Future<void> setUserSettings({
    required List<Setting> settings,
    bool isMarketplace = false,
  }) async {
    final List<Map<String, dynamic>> payload = settings
        .map(
          (Setting setting) => <String, dynamic>{
            "availableSettingId": setting.id,
            "value": <String, dynamic>{
              for (SettingValue v in setting.settingValues)
                v.settingName: v.settingData,
            },
            if (setting.assistantId != null) "assistantId": setting.assistantId,
          },
        )
        .toList();

    await ApiService.call(
      "${ApiUrls.settingsUserUrl(isMarketplace: false)}${isMarketplace ? "?isMarketplace=true" : ""}",
      RequestType.put,
      data: payload,
      onSuccess: (_) {},
      onError: (_) {},
    );
  }

}