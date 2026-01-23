class Setting {
  String id;
  List<SettingValue> settingValues;
  String? assistantId;
  Map<String, dynamic> data; //Goes in "value > data"

  Setting(
      {required this.id,
      required this.settingValues,
      required this.assistantId,
      this.data = const {}});
}

class SettingValue {
  String settingName;
  dynamic settingData;

  SettingValue({required this.settingName, required this.settingData});
}
