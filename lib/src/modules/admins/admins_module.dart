import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../../kyaru.dart';

class AdminsModule implements IModule {
  final Kyaru _kyaru;

  List<ModuleFunction> _moduleFunctions;

  AdminsModule(this._kyaru) {
    _moduleFunctions = [
      ModuleFunction(addCustomCommand, 'Adds a custom command in this chat', 'command', core: true),
      ModuleFunction(welcome, 'Sets a custom welcome in this group', 'welcome', core: true),
      ModuleFunction(commandList, 'Sends the list of custom commands in this chat', 'commands', core: true),
      ModuleFunction(forceExecuteCustomCommand, 'Executes a custom command, useful to check its content', 'execute',
          core: true),
      ModuleFunction(forgetCustomCommand, 'Removes a custom command from this chat', 'forget', core: true),
      ModuleFunction(setNsfw, 'Enables NSFW content in this chat', 'nsfw', core: true),
      ModuleFunction(executeCustomCommand, null, 'executeCustomCommand'),
    ];
  }

  @override
  List<ModuleFunction> getModuleFunctions() => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future commandList(Update update, Instruction instruction) async {
    var isAdmin = await AdminUtils.isAdmin(_kyaru, update.message.chat, update.message.from);
    if (!isAdmin) {
      return await _kyaru.reply(update, 'Sorry, you must be an admin to use that command');
    }

    var instructions = _kyaru.kyaruDB.getInstructions(InstructionType.command, update.message.chat.id);
    var reply = 'No custom messages are set in this chat yet';

    if (instructions.isNotEmpty) {
      var commandMap = <String, List<CustomCommand>>{};
      for (var inst in instructions) {
        if (!commandMap.containsKey(inst.command.command)) {
          commandMap[inst.command.command] = [];
        }

        commandMap[inst.command.command].add(inst.command);
      }

      reply = 'In this chat ${instructions.length} custom commands are set:\n${commandMap.map((c, v) {
            var index = 0;
            return MapEntry(
                c,
                '/$c\n  ${v.map((t) {
                  index++;
                  var type = EnumHelper.encode(t.commandType);
                  return '($index) $type';
                }).join('\n  ')}');
          }).values.join('\n')}';
    }

    await _kyaru.reply(update, reply);
  }

  Future forgetCustomCommand(Update update, Instruction instruction) async {
    var isAdmin = await AdminUtils.isAdmin(_kyaru, update.message.chat, update.message.from);
    if (!isAdmin) {
      return await _kyaru.reply(update, 'Sorry, you must be an admin to use that command');
    }

    var args = update.message.text.split(' ')..removeAt(0); // Remove user command

    if (args.isEmpty) {
      return await _kyaru.reply(update, 'Please specify the command to be executed and which reply index');
    }

    if (args.length != 2) {
      return await _kyaru.reply(
          update,
          'Wrong argument count:\n'
          'Please specify the command to be executed and which reply index');
    }

    var command = args[0];
    var index = int.tryParse(args[1]);

    if (index == null) {
      return await _kyaru.reply(update, 'The index must be a number');
    }

    var commandInstructions = _kyaru.kyaruDB.getInstructions(InstructionType.command, update.message.chat.id);
    if (!commandInstructions.map((i) => i.command.command.toLowerCase()).contains(command.toLowerCase())) {
      return await _kyaru.reply(update, 'Command not found.\nPlease use /commands to check the custom command list.');
    }

    var customInstructions = List<Instruction>.from(
        commandInstructions.where((i) => i.command.command.toLowerCase() == command.toLowerCase()));

    if (commandInstructions.length < index - 1) {
      return await _kyaru.reply(
          update, 'Invalid index specified.\nThe maximum index seems to be ${commandInstructions.length + 1}');
    }

    var instruction = customInstructions[index - 1];
    _kyaru.kyaruDB.deleteCustomInstruction(instruction);
    return await _kyaru.reply(update, 'Deleted!');
  }

  Future forceExecuteCustomCommand(Update update, Instruction instruction) async {
    var args = update.message.text.split(' ')..removeAt(0);

    if (args.isEmpty) {
      return await _kyaru.reply(update, 'Please specify the command to be executed and which reply index');
    }

    if (args.length != 2) {
      return await _kyaru.reply(
          update,
          'Wrong argument count:\n'
          'Please specify the command to be executed and which reply index');
    }

    var command = args[0];
    var index = int.tryParse(args[1]);

    if (index == null) {
      return await _kyaru.reply(update, 'The index must be a number');
    }

    var commandInstructions = _kyaru.kyaruDB.getInstructions(InstructionType.command, update.message.chat.id);
    if (!commandInstructions.map((i) => i.command.command.toLowerCase()).contains(command.toLowerCase())) {
      return await _kyaru.reply(update, 'Command not found.\nPlease use /commands to check the custom command list.');
    }

    var customInstructions = List<Instruction>.from(
        commandInstructions.where((i) => i.command.command.toLowerCase() == command.toLowerCase()));

    if (commandInstructions.length < index - 1) {
      return await _kyaru.reply(
          update, 'Invalid index specified.\nThe maximum index seems to be ${commandInstructions.length + 1}');
    }

    var instruction = customInstructions[index - 1];
    await executeCustomCommand(update, instruction);
    return await _kyaru.reply(
        update,
        'Executed command /${instruction.command.command} with reply index $index\n'
        'If you want me to forget this command use /forget ${instruction.command.command} $index');
  }

  Future addCustomCommand(Update update, Instruction instruction) async {
    var isAdmin = await AdminUtils.isAdmin(_kyaru, update.message.chat, update.message.from);
    if (!isAdmin) {
      return await _kyaru.reply(update, 'Sorry, you must be an admin to use that command');
    }

    var args = update.message.text.split(' ')..removeAt(0); // Remove user command

    if (args.isEmpty) {
      return await _kyaru.reply(update, 'Please specify a custom command as first argument');
    }

    var command = args[0];
    args.removeAt(0); // Remove custom command

    var instructionList =
        List.of(_kyaru.kyaruDB.getInstructions(InstructionType.command, 0).map((f) => f.command.command.toLowerCase()));

    if (instructionList.contains(command.toLowerCase()) || _kyaru.coreFunctions.contains(command.toLowerCase())) {
      return await _kyaru.reply(update, 'You can\'t override one of my commands.\nPlease choose a different command');
    }

    var quote = args.contains('q') || args.contains('quote');

    if (update.message.replyToMessage == null) {
      return await _kyaru.reply(update, 'Please quote a message to be sent when the command /$command is issued');
    }

    var customText = update.message.replyToMessage.text;

    var customFileId = MessageUtils.getMessageMediaFileId(update.message.replyToMessage);
    var commandType = MessageUtils.getMessageCommandType(update.message.replyToMessage);

    if (commandType == null || commandType == CommandType.unknown) {
      print(update.message.replyToMessage.animation);
      return await _kyaru.reply(update, 'Unknown message type, sorry!');
    }

    var customCommand = CustomCommand(
      command,
      commandType,
      text: customText,
      fileId: customFileId,
      quoteQuoted: quote,
    );

    var customInstruction = Instruction(
      update.message.chat.id,
      InstructionType.command,
      null,
      customCommand,
      'executeCustomCommand',
      null,
      quote,
      false,
    );

    _kyaru.kyaruDB.addCustomInstruction(customInstruction);
    await _kyaru.reply(update, 'I will reply ${quote ? 'and quote ' : ''}with that message when /$command is issued');
  }

  Future executeCustomCommand(Update update, Instruction instruction) {
    var customCommand = instruction.command;

    if (customCommand.commandType == CommandType.text) {
      return _kyaru
          .reply(update, customCommand.text, quoteQuoted: customCommand.quoteQuoted)
          .catchError((e, s) => _kyaru.onError(update, e, s));
    }

    if (customCommand.commandType == CommandType.sticker) {
      return _kyaru
          .replySticker(update, customCommand.fileId, quoteQuoted: customCommand.quoteQuoted)
          .catchError((e, s) => _kyaru.onError(update, e, s));
    }

    if (customCommand.commandType == CommandType.photo) {
      return _kyaru
          .replyPhoto(update, HttpFile.fromToken(customCommand.fileId), quoteQuoted: customCommand.quoteQuoted)
          .catchError((e, s) => _kyaru.onError(update, e, s));
    }

    if (customCommand.commandType == CommandType.video) {
      return _kyaru
          .replyVideo(update, HttpFile.fromToken(customCommand.fileId), quoteQuoted: customCommand.quoteQuoted)
          .catchError((e, s) => _kyaru.onError(update, e, s));
    }

    if (customCommand.commandType == CommandType.animation) {
      return _kyaru
          .replyAnimation(update, HttpFile.fromToken(customCommand.fileId), quoteQuoted: customCommand.quoteQuoted)
          .catchError((e, s) => _kyaru.onError(update, e, s));
    }

    if (customCommand.commandType == CommandType.document) {
      return _kyaru
          .replyDocument(update, HttpFile.fromToken(customCommand.fileId), quoteQuoted: customCommand.quoteQuoted)
          .catchError((e, s) => _kyaru.onError(update, e, s));
    }

    return _kyaru.reply(update, 'Something went wrong...').catchError((e, s) => _kyaru.onError(update, e, s));
  }

  Future welcome(Update update, Instruction instruction) async {
    if (update.message.chat.type == 'private') {
      return await _kyaru.reply(update, 'This command works only in groups');
    }

    var isAdmin = await AdminUtils.isAdmin(_kyaru, update.message.chat, update.message.from);
    if (!isAdmin) {
      return await _kyaru.reply(update, 'Sorry, you must be an admin to use that command');
    }

    var args = update.message.text.split(' ')..removeAt(0); // Remove user command

    if (args.isEmpty) {
      return await addCustomWelcome(update, instruction);
    }

    if (args[0].toLowerCase() == 'list') {
      return await customWelcomeList(update, instruction);
    }

    if (args[0].toLowerCase() == 'del') {
      return await removeCustomWelcome(update, instruction);
    }

    if (args[0].toLowerCase() == 'exec') {
      return await execCustomWelcome(update, instruction);
    }

    return await _kyaru.reply(update, 'Unknown argument supplied');
  }

  Future execCustomWelcome(Update update, Instruction instruction) async {
    var welcomeReplies = _kyaru.kyaruDB
        .getInstructions(InstructionType.event, update.message.chat.id, eventType: InstructionEventType.userJoined);

    if (welcomeReplies.isEmpty) {
      return await _kyaru.reply(update, 'No custom welcome set here yet');
    }

    var args = update.message.text.split(' ')..removeAt(0)..removeAt(0); // Remove user command

    if (args.isEmpty) {
      return await _kyaru.reply(
          update,
          'Wrong argument count:\n'
          'Please specify the command to be executed and which reply index');
    }

    var index = int.tryParse(args[0]);

    if (index == null) {
      return await _kyaru.reply(update, 'The index must be a number');
    }

    if (welcomeReplies.length < index - 1) {
      return await _kyaru.reply(
          update, 'Invalid index specified.\nThe maximum index seems to be ${welcomeReplies.length + 1}');
    }

    var instruction = welcomeReplies[index - 1];
    await executeCustomCommand(update, instruction);
    return await _kyaru.reply(
        update,
        'Executed custom welcome with index $index\n'
        'If you want me to forget this welcome use /welcome del $index');
  }

  Future removeCustomWelcome(Update update, Instruction instruction) async {
    var welcomeReplies = _kyaru.kyaruDB
        .getInstructions(InstructionType.event, update.message.chat.id, eventType: InstructionEventType.userJoined);

    if (welcomeReplies.isEmpty) {
      return await _kyaru.reply(update, 'No custom welcome set here yet');
    }

    var args = update.message.text.split(' ')..removeAt(0)..removeAt(0); // Remove user command

    if (args.isEmpty) {
      return await _kyaru.reply(
          update,
          'Wrong argument count:\n'
          'Please specify the command to be executed and which reply index');
    }

    var index = int.tryParse(args[0]);

    if (index == null) {
      return await _kyaru.reply(update, 'The index must be a number');
    }

    if (welcomeReplies.length < index - 1) {
      return await _kyaru.reply(
          update, 'Invalid index specified.\nThe maximum index seems to be ${welcomeReplies.length + 1}');
    }

    var instruction = welcomeReplies[index - 1];
    _kyaru.kyaruDB.deleteCustomInstruction(instruction);
    await _kyaru.reply(update, 'Custom welcome of type ${EnumHelper.encode(instruction.command.commandType)} removed!');
  }

  Future customWelcomeList(Update update, Instruction instruction) async {
    var welcomeReplies = _kyaru.kyaruDB
        .getInstructions(InstructionType.event, update.message.chat.id, eventType: InstructionEventType.userJoined);

    if (welcomeReplies.isEmpty) {
      return await _kyaru.reply(update, 'No custom welcome set here yet');
    }

    var index = 0;
    var listText = welcomeReplies.map((r) {
      index++;
      var type = EnumHelper.encode(r.command.commandType);
      return '($index) $type';
    }).join('\n ');
    var reply = 'Here\'s the custom welcome list:\n $listText';
    await _kyaru.reply(update, reply);
  }

  Future addCustomWelcome(Update update, Instruction instruction) async {
    if (update.message.replyToMessage == null) {
      return _kyaru.reply(update, 'Please quote a message that will be used as a welcome message');
    }

    var customText = update.message.text;

    var customFileId = MessageUtils.getMessageMediaFileId(update.message.replyToMessage);
    var commandType = MessageUtils.getMessageCommandType(update.message.replyToMessage);

    if (commandType == null) {
      return await _kyaru.reply(update, 'Unknown message type, sorry!');
    }

    var customCommand =
        CustomCommand(null, commandType, text: commandType == null ? customText : null, fileId: customFileId);

    var customInstruction = Instruction(
      update.message.chat.id,
      InstructionType.event,
      InstructionEventType.userJoined,
      customCommand,
      'executeCustomCommand',
      null,
      false,
      false,
    );

    _kyaru.kyaruDB.addCustomInstruction(customInstruction);
    await _kyaru.reply(update, 'I will send that when a new user joins this chat');
  }

  Future setNsfw(Update update, Instruction instruction) async {
    var isAdmin = await AdminUtils.isAdmin(_kyaru, update.message.chat, update.message.from);
    String replyText;
    if (!isAdmin) {
      replyText = 'Only an admin can use this command.';
    } else {
      var chatData = _kyaru.kyaruDB.getChatData(update.message.chat.id);
      chatData ??= ChatData(update.message.chat.id, nsfw: false);
      chatData.nsfw = !chatData.nsfw;
      _kyaru.kyaruDB.updateChatData(chatData);
      replyText = 'NSFW ${chatData.nsfw ? 'enabled' : 'disabled'}';
    }
    await _kyaru.reply(update, replyText).catchError((e, s) => _kyaru.onError(update, e, s));
  }
}
