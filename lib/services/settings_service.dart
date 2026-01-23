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

}