import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';

class AdminsModule implements IModule {
  final _log = Logger('AdminsModule');

  final Kyaru _kyaru;

  late List<ModuleFunction> _moduleFunctions;

  AdminsModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(
        addCustomCommand,
        'Adds a custom command in this chat',
        'command',
        core: true,
      ),
      ModuleFunction(
        welcome,
        'Sets a custom welcome in this group',
        'welcome',
        core: true,
      ),
      ModuleFunction(
        commandList,
        'Sends the list of custom commands in this chat',
        'commands',
        core: true,
      ),
      ModuleFunction(
        forceExecuteCustomCommand,
        'Executes a custom command, useful to check its content',
        'execute',
        core: true,
      ),
      ModuleFunction(
        forgetCustomCommand,
        'Removes a custom command from this chat',
        'forget',
        core: true,
      ),
      ModuleFunction(
        setNsfw,
        'Enables NSFW content in this chat',
        'nsfw',
        core: true,
      ),
      ModuleFunction(
        executeCustomCommand,
        null,
        'executeCustomCommand',
      ),
    ];
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future commandList(Update update, _) async {
    var isAdmin = await AdminUtils.isAdmin(
      _kyaru,
      update.message!.chat,
      update.message!.from,
    );
    if (!isAdmin) {
      return _kyaru.reply(
        update,
        'Sorry, you must be an admin to use that command',
      );
    }

    var instructions = _kyaru.brain.db.getInstructions(
      InstructionType.command,
      update.message!.chat.id,
    );

    if (instructions.isEmpty) {
      return _kyaru.reply(
        update,
        'No custom messages are set in this chat yet',
      );
    }
    var commandMap = <String?, List<CustomCommand>>{};
    for (var inst in instructions) {
      if (inst.command == null) continue;
      if (!commandMap.containsKey(inst.command!.command)) {
        commandMap[inst.command!.command] = [];
      }

      commandMap[inst.command!.command]!.add(inst.command!);
    }

    var instructionsCount = instructions.length;

    var reply = 'In this chat $instructionsCount custom commands are set:\n';
    for (var commandEntry in commandMap.entries) {
      reply += '/${commandEntry.key}\n';

      for (var entry in commandEntry.value.asMap().entries) {
        var type = UpperEnums.encodeUpper(entry.value.commandType);
        reply += '  (${entry.key + 1}) $type\n';
      }
    }

    return _kyaru.reply(update, reply);
  }

  Future forgetCustomCommand(Update update, _) async {
    var isAdmin = await AdminUtils.isAdmin(
      _kyaru,
      update.message!.chat,
      update.message!.from,
    );
    if (!isAdmin) {
      return _kyaru.reply(
        update,
        'Sorry, you must be an admin to use that command',
      );
    }

    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'Please specify the command to be executed and which reply index',
      );
    }

    if (args.length != 2) {
      return _kyaru.reply(
        update,
        'Wrong argument count:\n'
        'Please specify the command to be executed and which reply index',
      );
    }

    var command = args[0];
    var commandLower = command.toLowerCase();
    var index = int.tryParse(args[1]);

    if (index == null) {
      return _kyaru.reply(update, 'The index must be a number');
    }

    var commandInstructions = _kyaru.brain.db.getInstructions(
      InstructionType.command,
      update.message!.chat.id,
    );
    if (!commandInstructions
        .map((i) => i.command?.command?.toLowerCase())
        .where((i) => i != null)
        .contains(commandLower)) {
      return _kyaru.reply(
        update,
        'Command not found.\n'
        'Please use /commands to check the custom command list.',
      );
    }

    var customInstructions = commandInstructions
        .where((i) => i.command?.command?.toLowerCase() == commandLower)
        .toList();

    if (commandInstructions.length < index - 1) {
      return _kyaru.reply(
        update,
        'Invalid index specified.\n'
        'The maximum index seems to be ${commandInstructions.length + 1}',
      );
    }

    var instruction = customInstructions[index - 1];
    _kyaru.brain.db.deleteCustomInstruction(instruction);
    return _kyaru.reply(update, 'Deleted!');
  }

  Future forceExecuteCustomCommand(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'Please specify the command to be executed and which reply index',
      );
    }

    if (args.length != 2) {
      return _kyaru.reply(
        update,
        'Wrong argument count:\n'
        'Please specify the command to be executed and which reply index',
      );
    }

    var command = args[0];
    var commandLower = command.toLowerCase();
    var index = int.tryParse(args[1]);

    if (index == null) {
      return _kyaru.reply(update, 'The index must be a number');
    }

    var commandInstructions = _kyaru.brain.db.getInstructions(
      InstructionType.command,
      update.message!.chat.id,
    );
    if (!commandInstructions
        .map((i) => i.command?.command?.toLowerCase())
        .contains(commandLower)) {
      return _kyaru.reply(
        update,
        'Command not found.\n'
        'Please use /commands to check the custom command list.',
      );
    }

    var customInstructions = commandInstructions
        .where((i) => i.command?.command?.toLowerCase() == commandLower)
        .toList();

    if (commandInstructions.length < index - 1) {
      return _kyaru.reply(
        update,
        'Invalid index specified.\n'
        'The maximum index seems to be ${commandInstructions.length + 1}',
      );
    }

    var instruction = customInstructions[index - 1];
    await executeCustomCommand(update, instruction);
    return _kyaru.reply(
      update,
      'Executed command /${instruction.command?.command}'
      ' with reply index $index\n'
      'If you want me to forget this command use '
      '/forget ${instruction.command?.command} $index',
    );
  }

  Future addCustomCommand(Update update, _) async {
    var isAdmin = await AdminUtils.isAdmin(
      _kyaru,
      update.message!.chat,
      update.message!.from,
    );
    if (!isAdmin) {
      return _kyaru.reply(
        update,
        'Sorry, you must be an admin to use that command',
      );
    }

    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'Please specify a custom command as first argument',
      );
    }

    var command = args[0];
    var cmdLow = command.toLowerCase();
    args.removeAt(0); // Remove custom command

    var instructionList = List.of(_kyaru.brain.db
        .getInstructions(InstructionType.command, 0)
        .map((f) => f.command?.command?.toLowerCase()));

    if ([...instructionList, ..._kyaru.brain.coreFunctions].contains(cmdLow)) {
      return _kyaru.reply(
        update,
        'You can\'t override one of my commands.\n'
        'Please choose a different command',
      );
    }

    var quote = args.contains('q') || args.contains('quote');

    if (update.message!.replyToMessage == null) {
      return _kyaru.reply(
        update,
        'Please quote a message to be sent '
        'when the command /$command is issued',
      );
    }

    var customText = update.message!.replyToMessage!.text;

    var customFileId = MessageUtils.getMessageMediaFileId(
      update.message!.replyToMessage!,
    );
    var commandType = MessageUtils.getMessageCommandType(
      update.message!.replyToMessage!,
    );

    if (commandType == CommandType.unknown) {
      return _kyaru.reply(update, 'Unknown message type, sorry!');
    }

    var customCommand = CustomCommand(
      command,
      commandType,
      text: customText,
      fileId: customFileId,
      quoteQuoted: quote,
    );

    var customInstruction = Instruction(
      update.message!.chat.id,
      InstructionType.command,
      InstructionEventType.none,
      customCommand,
      'executeCustomCommand',
      null,
      quote,
      false,
    );

    _kyaru.brain.db.addCustomInstruction(customInstruction);
    return _kyaru.reply(
      update,
      'I will reply ${quote ? 'and quote ' : ''}'
      'with that message when /$command is issued',
    );
  }

  Future executeCustomCommand(
    Update update,
    Instruction? instruction,
  ) async {
    if (instruction == null) {
      _log.severe(
        'Error, cannot run executeCustomCommand with instruction == null',
      );
      return;
    }

    var customCommand = instruction.command;
    if (customCommand == null) {
      _log.severe(
        'Error, cannot run executeCustomCommand with customCommand == null',
      );
      return;
    }

    if (customCommand.commandType == CommandType.text) {
      return _kyaru.reply(
        update,
        customCommand.text!,
        quoteQuoted: customCommand.quoteQuoted,
      );
    }

    if (customCommand.commandType == CommandType.sticker) {
      return _kyaru.replySticker(
        update,
        customCommand.fileId!,
        quoteQuoted: customCommand.quoteQuoted,
      );
    }

    if (customCommand.commandType == CommandType.photo) {
      return _kyaru.replyPhoto(
        update,
        HttpFile.fromToken(customCommand.fileId!),
        quoteQuoted: customCommand.quoteQuoted,
      );
    }

    if (customCommand.commandType == CommandType.video) {
      return _kyaru.replyVideo(
        update,
        HttpFile.fromToken(customCommand.fileId!),
        quoteQuoted: customCommand.quoteQuoted,
      );
    }

    if (customCommand.commandType == CommandType.animation) {
      return _kyaru.replyAnimation(
        update,
        HttpFile.fromToken(customCommand.fileId!),
        quoteQuoted: customCommand.quoteQuoted,
      );
    }

    if (customCommand.commandType == CommandType.document) {
      return _kyaru.replyDocument(
        update,
        HttpFile.fromToken(customCommand.fileId!),
        quoteQuoted: customCommand.quoteQuoted,
      );
    }

    return _kyaru.reply(update, 'Something went wrong...');
  }

  Future welcome(Update update, _) async {
    if (update.message!.chat.type == 'private') {
      return _kyaru.reply(update, 'This command works only in groups');
    }

    var isAdmin = await AdminUtils.isAdmin(
      _kyaru,
      update.message!.chat,
      update.message!.from,
    );

    if (!isAdmin) {
      return _kyaru.reply(
        update,
        'Sorry, you must be an admin to use that command',
      );
    }

    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.isEmpty) return addCustomWelcome(update, _);

    var commands = {
      'list': customWelcomeList,
      'del': removeCustomWelcome,
      'exec': execCustomWelcome,
    };

    var lower = args[0].toLowerCase();

    if (!commands.containsKey(lower)) {
      return _kyaru.reply(update, 'Unknown argument supplied');
    }

    return commands[lower]!(update, _);
  }

  Future execCustomWelcome(Update update, _) async {
    var welcomeReplies = _kyaru.brain.db.getInstructions(
      InstructionType.event,
      update.message!.chat.id,
      eventType: InstructionEventType.userJoined,
    );

    if (welcomeReplies.isEmpty) {
      return _kyaru.reply(
        update,
        'No custom welcome set here yet',
      );
    }

    var args = update.message!.text!.split(' ')..removeAt(0)..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'Wrong argument count:\n'
        'Please specify the command to be executed and which reply index',
      );
    }

    var index = int.tryParse(args[0]);

    if (index == null) {
      return _kyaru.reply(update, 'The index must be a number');
    }

    if (welcomeReplies.length < index - 1) {
      return _kyaru.reply(
        update,
        'Invalid index specified.\n'
        'The maximum index seems to be ${welcomeReplies.length + 1}',
      );
    }

    var instruction = welcomeReplies[index - 1];
    await executeCustomCommand(update, instruction);
    return _kyaru.reply(
      update,
      'Executed custom welcome with index $index\n'
      'If you want me to forget this welcome use /welcome del $index',
    );
  }

  Future removeCustomWelcome(Update update, _) async {
    var welcomeReplies = _kyaru.brain.db.getInstructions(
      InstructionType.event,
      update.message!.chat.id,
      eventType: InstructionEventType.userJoined,
    );

    if (welcomeReplies.isEmpty) {
      return _kyaru.reply(update, 'No custom welcome set here yet');
    }

    var args = update.message!.text!.split(' ')..removeAt(0)..removeAt(0);

    if (args.isEmpty) {
      return _kyaru.reply(
        update,
        'Wrong argument count:\n'
        'Please specify the command to be executed and which reply index',
      );
    }

    var index = int.tryParse(args[0]);

    if (index == null) {
      return _kyaru.reply(update, 'The index must be a number');
    }

    if (welcomeReplies.length < index - 1) {
      return _kyaru.reply(
        update,
        'Invalid index specified.\n'
        'The maximum index seems to be ${welcomeReplies.length + 1}',
      );
    }

    var instruction = welcomeReplies[index - 1];
    _kyaru.brain.db.deleteCustomInstruction(instruction);
    return _kyaru.reply(
      update,
      'Custom welcome of type '
      '${UpperEnums.encodeUpper(instruction.command!.commandType)} removed!',
    );
  }

  Future customWelcomeList(Update update, _) async {
    var welcomeReplies = _kyaru.brain.db.getInstructions(
      InstructionType.event,
      update.message!.chat.id,
      eventType: InstructionEventType.userJoined,
    );

    if (welcomeReplies.isEmpty) {
      return _kyaru.reply(update, 'No custom welcome set here yet');
    }

    var index = 0;
    var listText = welcomeReplies.map((r) {
      index++;
      var type = UpperEnums.encodeUpper(r.command!.commandType);
      return '($index) $type';
    }).join('\n ');
    var reply = 'Here\'s the custom welcome list:\n $listText';

    return _kyaru.reply(update, reply);
  }

  Future addCustomWelcome(Update update, _) async {
    if (update.message!.replyToMessage == null) {
      return _kyaru.reply(
        update,
        'Please quote a message that will be used as a welcome message',
      );
    }

    var customFileId = MessageUtils.getMessageMediaFileId(
      update.message!.replyToMessage!,
    );
    var commandType = MessageUtils.getMessageCommandType(
      update.message!.replyToMessage!,
    );

    var customCommand = CustomCommand(
      null,
      commandType,
      text: null,
      fileId: customFileId,
    );

    var customInstruction = Instruction(
      update.message!.chat.id,
      InstructionType.event,
      InstructionEventType.userJoined,
      customCommand,
      'executeCustomCommand',
      null,
      false,
      false,
    );

    _kyaru.brain.db.addCustomInstruction(customInstruction);
    return _kyaru.reply(
      update,
      'I will send that when a new user joins this chat',
    );
  }

  Future setNsfw(Update update, _) async {
    var isAdmin = await AdminUtils.isAdmin(
      _kyaru,
      update.message!.chat,
      update.message!.from,
    );
    String replyText;
    if (!isAdmin) {
      replyText = 'Only an admin can use this command.';
    } else {
      var chatData = _kyaru.brain.db.getChatData(update.message!.chat.id);
      chatData ??= ChatData(
        update.message!.chat.id,
        nsfw: false,
        isPrivate: update.message!.chat.type == 'private',
      );
      chatData.nsfw = !chatData.nsfw;
      _kyaru.brain.db.updateChatData(chatData);
      replyText = 'NSFW ${chatData.nsfw ? 'enabled' : 'disabled'}';
    }
    return _kyaru.reply(update, replyText);
  }
}
