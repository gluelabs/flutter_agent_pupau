// ignore_for_file: type_literal_in_constant_pattern

int getInt(dynamic value) {
  try {
    if (value == null) return 0;
    switch (value.runtimeType) {
      case int:
        return value;
      case double:
      case BigInt:
        return value.toInt();
      case String:
        try {
          if (value.contains(".")) return double.parse(value).toInt();
          return int.parse(value);
        } catch (_) {
          return 0;
        }
      case bool:
        return value ? 1 : 0;
      default:
        return 0;
    }
  } catch (e) {
    return 0;
  }
}

double getDouble(dynamic value) {
  try {
    if (value == null) return 0.0;
    switch (value.runtimeType) {
      case double:
        return value;
      case int:
      case BigInt:
        return value.toDouble();
      case String:
        try {
          return double.parse(value);
        } catch (_) {
          return 0.0;
        }
      case bool:
        return value ? 1.0 : 0.0;
      default:
        return 0.0;
    }
  } catch (e) {
    return 0.0;
  }
}

String getString(dynamic value) {
  try {
    if (value == null) return "";
    return value.toString();
  } catch (e) {
    return "";
  }
}

bool getBool(dynamic value) {
  try {
    if (value == null) return false;
    switch (value.runtimeType) {
      case bool:
        return value;
      case String:
        return value.toLowerCase() == "true";
      case int:
        return value != 0;
      case double:
        return value != 0.0;
      default:
        return false;
    }
  } catch (e) {
    return false;
  }
}

DateTime getDateTime(dynamic value) {
  try {
    if (value == null) return DateTime.now();
    switch (value.runtimeType) {
      case DateTime:
        return value;
      case String:
        return DateTime.tryParse(value.toString()) ?? DateTime.now();
      default:
        return DateTime.now();
    }
  } catch (e) {
    return DateTime.now();
  }
}