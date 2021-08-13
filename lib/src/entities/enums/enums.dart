class _Enum<T> {
  final T _value;

  T get value => _value;

  const _Enum(this._value);

  @override
  String toString() => '$_value';

  String toJson() => '$this';
}

class InstructionType extends _Enum<String> {
  static const messageContent = InstructionType._('MESSAGE_CONTENT');
  static const command = InstructionType._('COMMAND');
  static const regex = InstructionType._('REGEX');
  static const event = InstructionType._('EVENT');
  static const none = InstructionType._('NONE');

  static const values = {
    'MESSAGE_CONTENT': messageContent,
    'COMMAND': command,
    'REGEX': regex,
    'EVENT': event,
    'NONE': none,
  };

  const InstructionType._(String value) : super(value);

  static InstructionType forValue(String value) {
    if (!values.containsKey(value.toUpperCase())) {
      throw Exception('InstructionType $value does not exist');
    }
    return InstructionType.values[value.toUpperCase()]!;
  }
}

class InstructionEventType extends _Enum<String> {
  static const userJoined = InstructionEventType._('USER_JOINED');
  static const userLeft = InstructionEventType._('USER_LEFT');
  static const kyaruJoined = InstructionEventType._('KYARU_JOINED');
  static const none = InstructionEventType._('NONE');

  static const values = {
    'USER_JOINED': userJoined,
    'USER_LEFT': userLeft,
    'KYARU_JOINED': kyaruJoined,
    'NONE': none,
  };

  const InstructionEventType._(String value) : super(value);

  static InstructionEventType forValue(String value) =>
      InstructionEventType.values[value]!;
}

class CommandType extends _Enum<String> {
  static const image = CommandType._('IMAGE');
  static const video = CommandType._('VIDEO');
  static const sticker = CommandType._('STICKER');
  static const text = CommandType._('TEXT');
  static const photo = CommandType._('PHOTO');
  static const animation = CommandType._('ANIMATION');
  static const unknown = CommandType._('UNKNOWN');
  static const document = CommandType._('DOCUMENT');

  static const values = {
    'IMAGE': image,
    'VIDEO': video,
    'STICKER': sticker,
    'TEXT': text,
    'PHOTO': photo,
    'ANIMATION': animation,
    'UNKNOWN': unknown,
    'DOCUMENT': document,
  };

  const CommandType._(String value) : super(value);

  static CommandType forValue(String value) =>
      CommandType.values[value.toUpperCase()]!;
}
