import 'package:dart_telegram_bot/dart_telegram_bot.dart';

import '../../kyaru.dart';
import '../entities/i_module.dart';

class KyaruBrain extends Bot {
  KyaruBrain(this._kyaruDB) : super(_kyaruDB.getSettings().token) {
    // Find a better way to register modules
    modules.addAll(<IModule>[
      RegexModule(this as Kyaru),
      OwnerModule(this as Kyaru),
      AdminsModule(this as Kyaru),
      LoLModule(this as Kyaru),
      InsultsModule(this as Kyaru),
      DanbooruModule(this as Kyaru),
      YandereModule(this as Kyaru),
      JikanModule(this as Kyaru),
      ApexModule(this as Kyaru),
      GithubModule(this as Kyaru),
    ]);

    setupModules();
    updateTelegramCommands();
  }

  final Map<String, ModuleFunction> modulesFunctions = <String, ModuleFunction>{};
  final List<String> coreFunctions = <String>[];
  final List<IModule> modules = <IModule>[];
  final KyaruDB _kyaruDB;

  KyaruDB get kyaruDB => _kyaruDB;

  void updateTelegramCommands() {
    setMyCommands(
      List<BotCommand>.of(
        modulesFunctions.values.where((ModuleFunction m) => m.core).map(
              (ModuleFunction m) => BotCommand(m.name, m.description.length >= 3 ? m.description : 'No description'),
            ),
      ),
    ).catchError((Exception e, StackTrace s) => print('Could not update Telegram commands: $e\n$s'));
  }

  void setupModules() {
    for (final IModule module in modules) {
      print(module.runtimeType);
      final List<ModuleFunction> moduleFunctions = module.getModuleFunctions();
      for (final ModuleFunction moduleFunction in moduleFunctions) {
        print('- ${moduleFunction.name}');
        modulesFunctions[moduleFunction.name] = moduleFunction;
        if (moduleFunction.core) {
          coreFunctions.add(moduleFunction.name);
          onCommand(
            moduleFunction.name,
            (Update u) => moduleFunction.function(u, null).then((dynamic v) => print('Function executed')),
          );
        }
      }
    }
    print('------------------------------------------------');
    print('Loaded ${modulesFunctions.length} module functions');
  }

  Future<bool> readEvents(Update update) async {
    if (update?.message != null && update?.message?.newChatMembers != null) {
      if (update.message?.newChatMembers?.map((User u) => u.id)?.contains(id) == true) {
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

  Future<void> readMessage(Update update) async {
    final String text = update.message?.text;
    if (text == null) return;

    final int chatId = update.message?.chat?.id;
    if (chatId == null) {
      print('Cannot proceed if chat id is null');
      return;
    }

    final BotCommandParser botCommand = BotCommandParser.fromMessage(update.message);
    final bool isCommandToBot = botCommand != null && botCommand.isToBot(username);

    if (isCommandToBot) return onCommandToBot(update, botCommand, chatId);

    await onTextMessage(update, chatId);
  }

  bool runInstructionFunction(Update update, Instruction instruction) {
    if (instruction.function != null) {
      if (modulesFunctions.containsKey(instruction.function)) {
        modulesFunctions[instruction.function]
            .function(update, instruction)
            .catchError((Exception e, StackTrace s) => print('Function ${instruction.function} crashed: $e\n$s'));
        print('Function ${instruction.function} executed');
        return true; // Something got executed
      } else {
        print('Warning function ${instruction.function} not found in any module');
      }
    }
    return false;
  }

  List<Instruction> getInstructions(InstructionType instructionType, int chatId, {InstructionEventType eventType}) {
    return <Instruction>[
      ..._kyaruDB.getInstructions(instructionType, 0, eventType: eventType),
      ..._kyaruDB.getInstructions(instructionType, chatId, eventType: eventType)
    ];
  }

  Future<bool> execRegexInstructions(Update update, int chatId) async {
    final List<Instruction> regexInstructions = getInstructions(InstructionType.REGEX, chatId);

    final String text = update.message.text;

    final List<Instruction> validInstructions = regexInstructions.where((Instruction i) {
      return RegExp(i.regex).firstMatch(text) != null && i.checkRequirements(update, kyaruDB.getSettings());
    }).toList();

    if (validInstructions.isEmpty) return false;
    runInstructionFunction(update, RandomUtils.choose(validInstructions));
    return true;
  }

  Future<bool> execCommandInstructions(Update update, BotCommandParser botCommand, int chatId) async {
    final List<Instruction> commandInstructions = getInstructions(InstructionType.COMMAND, chatId);
    final List<Instruction> validInstructions = commandInstructions.where((Instruction i) {
      return botCommand.matchesCommand(i.command.command) && i.checkRequirements(update, kyaruDB.getSettings());
    }).toList();

    if (validInstructions.isEmpty) return false;

    runInstructionFunction(update, RandomUtils.choose(validInstructions));
    return true;
  }

  Future<void> execEventInstructions(Update update, InstructionEventType eventType, int chatId) async {
    final List<Instruction> instructions = getInstructions(InstructionType.EVENT, chatId, eventType: eventType);
    if (instructions.isEmpty) return false;

    runInstructionFunction(update, RandomUtils.choose(instructions));
    return true;
  }

  Future<void> onTextMessage(Update update, int chatId) async {
    // First check contents
    // Then check equals
    if (await execRegexInstructions(update, chatId)) return; // Then check regex
  }

  Future<void> onCommandToBot(Update update, BotCommandParser botCommand, int chatId) async {
    if (await execCommandInstructions(update, botCommand, chatId)) return;
  }

  Future<void> onLeftGroup(Update update) {
    return null;
  }

  Future<void> onNewGroup(Update update) async {
    await execEventInstructions(update, InstructionEventType.KYARU_JOINED, update.message.chat.id);
  }

  Future<void> onNewUsers(Update update) async {
    await execEventInstructions(update, InstructionEventType.USER_JOINED, update.message.chat.id);
  }
}
