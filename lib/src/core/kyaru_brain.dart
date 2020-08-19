import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../kyaru.dart';
import '../entities/i_module.dart';

class KyaruBrain extends Bot {
  final Map<String, ModuleFunction> modulesFunctions = {};
  final List<String> coreFunctions = [];
  final List<IModule> modules = [];
  final KyaruDB _kyaruDB;

  KyaruDB get kyaruDB => _kyaruDB;

  KyaruBrain(this._kyaruDB) : super(_kyaruDB.getSettings().token) {
    // Find a better way to register modules
    modules.addAll([
      RegexModule(this),
      OwnerModule(this),
      AdminsModule(this),
      LoLModule(this),
      InsultsModule(this),
      DanbooruModule(this),
      YandereModule(this),
      JikanModule(this),
      ApexModule(this),
      GithubModule(this),
    ]);

    setupModules();
    updateTelegramCommands();
  }

  void updateTelegramCommands() {
    setMyCommands(List.of(modulesFunctions.values.where((m) => m.core).map((m) => BotCommand(
          m.name,
          m.description.length >= 3 ? m.description : 'No description',
        )))).catchError((e, s) => print('Could not update Telegram commands: $e\n$s'));
  }

  void setupModules() {
    for (var module in modules) {
      print(module.runtimeType);
      var moduleFunctions = module.getModuleFunctions();
      for (var moduleFunction in moduleFunctions) {
        print('- ${moduleFunction.name}');
        modulesFunctions[moduleFunction.name] = moduleFunction;
        if (moduleFunction.core) {
          coreFunctions.add(moduleFunction.name);
          onCommand(
              moduleFunction.name, (u) => moduleFunction.function(u, null).then((v) => print('Function executed')));
        }
      }
    }
    print('------------------------------------------------');
    print('Loaded ${modulesFunctions.length} module functions');
  }

  Future<bool> readEvents(Update update) async {
    if (update?.message != null && update?.message?.newChatMembers != null) {
      if (update.message?.newChatMembers?.map((m) => m.id)?.contains(id) == true) {
        await onNewGroup(update);
        return true;
      }
      await onNewUsers(update);
      return true;
    } else if (update?.message != null && update?.message?.leftChatMember != null) {
      if (update.message.leftChatMember.id == id) {
        await onLeftGroup(update);
        return true;
      }
    }
    return false;
  }

  Future readMessage(Update update) async {
    var text = update.message?.text;
    if (text == null) return;

    var chatId = update.message?.chat?.id;
    if (chatId == null) {
      print('Cannot proceed if chat id is null');
      return;
    }

    var botCommand = BotCommandParser.fromMessage(update.message);
    var isCommandToBot = botCommand != null && botCommand.isToBot(username);

    if (isCommandToBot) return onCommandToBot(update, botCommand, chatId);

    await onTextMessage(update, chatId);
  }

  bool runInstructionFunction(Update update, Instruction instruction) {
    if (instruction.function != null) {
      if (modulesFunctions.containsKey(instruction.function)) {
        modulesFunctions[instruction.function]
            .function(update, instruction)
            .catchError((e, s) => print('Function ${instruction.function} crashed: $e\n$s'));
        print('Function ${instruction.function} executed');
        return true; // Something got executed
      } else {
        print('Warning function ${instruction.function} not found in any module');
      }
    }
    return false;
  }

  List<Instruction> getInstructions(InstructionType instructionType, int chatId, {InstructionEventType eventType}) {
    return [
      ..._kyaruDB.getInstructions(instructionType, 0, eventType: eventType),
      ..._kyaruDB.getInstructions(instructionType, chatId, eventType: eventType)
    ];
  }

  Future<bool> execRegexInstructions(Update update, int chatId) async {
    var regexInstructions = getInstructions(InstructionType.REGEX, chatId);

    var text = update.message.text;

    var validInstructions = regexInstructions.where((i) {
      return RegExp(i.regex).firstMatch(text) != null && i.checkRequirements(update, kyaruDB.getSettings());
    });

    if (validInstructions.isEmpty) return false;
    runInstructionFunction(update, RandomUtils.choose(List.from(validInstructions)));
    return true;
  }

  Future<bool> execCommandInstructions(Update update, BotCommandParser botCommand, int chatId) async {
    var commandInstructions = getInstructions(InstructionType.COMMAND, chatId);
    var validInstructions = commandInstructions.where((i) {
      return botCommand.matchesCommand(i.command.command) && i.checkRequirements(update, kyaruDB.getSettings());
    });

    if (validInstructions.isEmpty) return false;

    runInstructionFunction(update, RandomUtils.choose(List.from(validInstructions)));
    return true;
  }

  Future execEventInstructions(Update update, InstructionEventType eventType, int chatId) async {
    var instructions = getInstructions(InstructionType.EVENT, chatId, eventType: eventType);
    if (instructions.isEmpty) return false;

    runInstructionFunction(update, RandomUtils.choose(List.of(instructions)));
    return true;
  }

  Future onTextMessage(Update update, int chatId) async {
    // First check contents
    // Then check equals
    if (await execRegexInstructions(update, chatId)) return; // Then check regex
  }

  Future onCommandToBot(Update update, BotCommandParser botCommand, int chatId) async {
    if (await execCommandInstructions(update, botCommand, chatId)) return;
  }

  void onLeftGroup(Update update) {}

  void onNewGroup(Update update) async {
    await execEventInstructions(update, InstructionEventType.KYARU_JOINED, update.message.chat.id);
  }

  void onNewUsers(Update update) async {
    await execEventInstructions(update, InstructionEventType.USER_JOINED, update.message.chat.id);
  }
}
