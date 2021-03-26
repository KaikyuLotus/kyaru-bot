import 'dart:async';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../kyaru.dart';

class KyaruBrain {
  KyaruBrain({
    required database,
    required this.bot,
  }) : db = database;

  final KyaruDB db;
  final Bot bot;

  var modulesFunctions = <String, ModuleFunction>{};
  var coreFunctions = <String>[];
  var modules = <IModule>[];

  Future updateTelegramCommands() {
    return bot.setMyCommands(
      List<BotCommand>.of(
        modulesFunctions.values.where((m) => m.core).map(
              (m) => BotCommand(
                command: m.name,
                description: m.description!.length >= 3
                    ? m.description
                    : 'No description',
              ),
            ),
      ),
    );
  }

  Future moduleFunctionWrapper(
    ModuleFunction moduleFunction,
    Update update,
  ) async {
    try {
      await moduleFunction.function(update, null);
      print('Function ${moduleFunction.name} executed');
    } catch (e, s) {
      print('Error executing function ${moduleFunction.name}: $e\n$s');
      await bot.sendMessage(
        ChatID(db.settings.ownerId),
        'Command ${moduleFunction.name} crashed: $e',
      );
    }
  }

  void useModules(List<IModule> modules) {
    this.modules = modules;
    for (var module in modules) {
      print(module.runtimeType);
      var moduleFunctions = module.moduleFunctions ?? [];
      for (var moduleFunction in moduleFunctions) {
        print('- ${moduleFunction.name}');
        modulesFunctions[moduleFunction.name] = moduleFunction;
        if (!moduleFunction.core) continue;
        coreFunctions.add(moduleFunction.name);
        bot.onCommand(
          moduleFunction.name,
          (bot, update) => moduleFunctionWrapper(moduleFunction, update),
        );
      }
    }
    updateTelegramCommands();
    print('------------------------------------------------');
    print('Loaded ${modulesFunctions.length} module functions');
  }

  Future<bool> readEvents(Update update) async {
    if (update.message?.newChatMembers != null) {
      var joinedMembersIds = update.message?.newChatMembers?.map((u) => u.id);
      if (joinedMembersIds?.contains(bot.id) ?? false) {
        await onNewGroup(update);
        return true;
      }
      await onNewUsers(update);
      return true;
    }

    var leftChatMember = update.message?.leftChatMember;
    if (leftChatMember != null) {
      if (leftChatMember.id == bot.id) {
        await onLeftGroup(update);
        return true;
      }
    }

    // Other events here

    return false;
  }

  Future readMessage(Update update) async {
    final text = update.message?.text;
    if (text == null) return;

    final chatId = update.message?.chat.id;
    if (chatId == null) return print('Cannot proceed if chat id is null');

    final botCommand = BotCommandParser.fromMessage(update.message!);

    final isCommandToBot = botCommand?.isToBot(bot.username!) ?? false;

    if (isCommandToBot) return onCommandToBot(update, botCommand!, chatId);

    await onTextMessage(update, chatId);
  }

  Future<bool> runInstructionFunction(
    Update update,
    Instruction instruction,
  ) async {
    if (instruction.function == null) return false;

    if (!modulesFunctions.containsKey(instruction.function)) {
      print('Warning function ${instruction.function} not found in any module');
      return false;
    }

    var function = instruction.function;
    if (function == null) return false;

    await modulesFunctions[function]?.function(update, instruction);
    print('Function ${instruction.function} executed');
    return true;
  }

  List<Instruction> getInstructions(
    InstructionType instructionType,
    int chatId, {
    InstructionEventType? eventType,
  }) {
    return <Instruction>[
      ...db.getInstructions(instructionType, 0, eventType: eventType),
      ...db.getInstructions(instructionType, chatId, eventType: eventType),
    ];
  }

  Future<bool> execRegexInstructions(Update update, int chatId) async {
    final regexInstructions = getInstructions(InstructionType.regex, chatId);

    final text = update.message!.text;

    final validInstructions = regexInstructions.where(
      (i) {
        return RegExp(i.regex!).firstMatch(text!) != null &&
            i.checkRequirements(update, db.settings);
      },
    ).toList();

    if (validInstructions.isEmpty) return false;

    await runInstructionFunction(update, choose(validInstructions));
    return true;
  }

  Future<bool> execCommandInstructions(
    Update update,
    BotCommandParser botCommand,
    int chatId,
  ) async {
    final commandInstructions = getInstructions(
      InstructionType.command,
      chatId,
    );
    final validInstructions = commandInstructions.where(
      (i) {
        return i.command != null &&
            botCommand.matchesCommand(i.command!.command!) &&
            i.checkRequirements(update, db.settings);
      },
    ).toList();

    if (validInstructions.isEmpty) return false;

    await runInstructionFunction(update, choose(validInstructions));
    return true;
  }

  Future<bool> execEventInstructions(
    Update update,
    InstructionEventType eventType,
    int chatId,
  ) async {
    final instructions = getInstructions(
      InstructionType.event,
      chatId,
      eventType: eventType,
    );
    if (instructions.isEmpty) return false;

    await runInstructionFunction(update, choose(instructions));
    return true;
  }

  Future onTextMessage(Update update, int chatId) {
    return execRegexInstructions(update, chatId);
  }

  Future onCommandToBot(
    Update update,
    BotCommandParser botCommand,
    int chatId,
  ) {
    return execCommandInstructions(update, botCommand, chatId);
  }

  Future onLeftGroup(Update update) async {}

  Future onNewGroup(Update update) {
    return execEventInstructions(
      update,
      InstructionEventType.kyaruJoined,
      update.message!.chat.id,
    );
  }

  Future onNewUsers(Update update) {
    return execEventInstructions(
      update,
      InstructionEventType.userJoined,
      update.message!.chat.id,
    );
  }
}
