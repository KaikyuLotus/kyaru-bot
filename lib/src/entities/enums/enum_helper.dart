class EnumHelper {
  static String _getEnumClassFromValues<T>(Iterable<T> values) {
    return values.first.runtimeType.toString();
  }

  static String _getEnumValue<T>(T enumType) {
    if (enumType == null) return null;
    return enumType.toString().split('.')[1];
  }

  static T get<T>(Iterable<T> values, String value) {
    if (value == null) return null;
    return values.firstWhere((e) => e.toString() == _getEnumClassFromValues(values) + '.' + value);
  }

  static String encode<T>(T menum) {
    return _getEnumValue(menum);
  }
}
