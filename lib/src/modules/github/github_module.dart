import 'dart:async';
import 'dart:isolate';

import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';
import 'entities/db/db_repo.dart';
import 'entities/exceptions/github_forbidden_exception.dart';
import 'entities/exceptions/github_not_changed_exception.dart';
import 'entities/exceptions/github_not_found_exception.dart';
import 'entities/github_client.dart';
import 'entities/github_events_response.dart';

extension on KyaruDB {
  static const _repositoryCollection = 'repositories';

  List<DBRepo> getRepos() {
    return database[_repositoryCollection].findAs(DBRepo.fromJson);
  }

  void addRepo(DBRepo repo) {
    return database[_repositoryCollection].insert(repo.toJson());
  }

  bool removeRepo(DBRepo repo) {
    return database[_repositoryCollection].delete(repo.toJson());
  }
}

Future eventsIsolateLoop(SendPort sendPort) async {
  // Always do db.syncDb() after updating data
  // Also this may case data loss with main isolate
  var db = KyaruDB();

  final _log = Logger('GithubIsolate');

  final githubClient = GithubClient();
  final etagStore = <String?, String?>{};
  final readUpdates = <String>[];

  int? rateLimitSeconds;

  Future elaborateResponse(
    DBRepo repo,
    GithubEventsResponse githubEventsResp,
  ) async {
    _log.info('Elaborating events for ${repo.repo}...');
    var events = githubEventsResp.events!.where(
      (e) => !readUpdates.contains(e.id),
    );

    if (events.isEmpty) return;

    if (etagStore.containsKey(repo.repo)) {
      var message = '';
      if (events.length == 1) {
        message = 'New event for repository ${repo.repo}:\n${events.first}';
      } else {
        var eventsString = events.map((e) => e.toString()).join('\n- ');
        message = 'New events for repository ${repo.repo}:\n- $eventsString';
      }
      sendPort.send(['sendMessage', repo.chatID, message]);
    }
    etagStore[repo.repo] = githubEventsResp.etag;
    readUpdates.addAll(List<String>.from(events.map((e) => e.id)));
    _log.info('Elaborating events for ${repo.repo} done');
  }

  Future analyzeRepo(DBRepo repo) async {
    try {
      var response = await githubClient.events(
        repo.user,
        repo.repo,
        etag: etagStore[repo.repo],
      );
      await elaborateResponse(repo, response);
      _log.info('Left rate limit: ${response.rateLimitRemaining}');
    } on GithubNotFoundException {
      _log.info('Repository or user not found');
      sendPort.send(['notFound', repo.toJson()]);
    } on GithubNotChangedException catch (e) {
      _log.info('Nothing changed, left limit: ${e.rateLimitRemaining}');
    } on GithubForbiddenException catch (e, s) {
      var resetDateTime = DateTime.fromMillisecondsSinceEpoch(
        e.rateLimitReset! * 1000,
      );
      var seconds = resetDateTime.difference(DateTime.now()).inSeconds;
      _log.info(
        'Stopping updates until ${resetDateTime.toIso8601String()}'
        ' ($seconds seconds)',
      );
      rateLimitSeconds = seconds;
    } on Exception catch (e, s) {
      _log.severe('Unknown exception in analyzeRepo: $e\n$s');
    }
  }

  void timerFunction() {
    _log.fine('Checking github updates...');
    db.syncDb();
    db.getRepos().forEach(analyzeRepo);
  }

  _log.info('Bootstrapping Github event isolate');
  while (true) {
    if (rateLimitSeconds != null) {
      _log.severe('Found API rate limit, waiting $rateLimitSeconds seconds');
      await Future.delayed(Duration(seconds: rateLimitSeconds!));
      rateLimitSeconds = null;
    }
    timerFunction();
    await Future.delayed(const Duration(minutes: 2));
  }
}

class GithubModule implements IModule {
  final _log = Logger('GithubModule');
  final Kyaru _kyaru;
  final _githubClient = GithubClient();

  late List<ModuleFunction> _moduleFunctions;

  GithubModule(this._kyaru) {
    _log.info('Github module started at ${DateTime.now().toIso8601String()}');
    _moduleFunctions = [
      ModuleFunction(
        registerRepo,
        'Register a GitHub repository watcher in this chat',
        'git',
        core: true,
      ),
      ModuleFunction(
        removeRepo,
        'Remove a GitHub repository',
        'gitremove',
        core: true,
      ),
      ModuleFunction(
        listRepo,
        'List GitHub repositories in this chat',
        'gitlist',
        core: true,
      )
    ];

    startEventsIsolate();
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  Future onSendMessageEvent(int chatId, String message) {
    return _kyaru.brain.bot.sendMessage(ChatID(chatId), message);
  }

  Future onRepoNotFoundEvent(DBRepo repo) {
    _kyaru.brain.db.removeRepo(repo);
    return _kyaru.brain.bot.sendMessage(
      ChatID(repo.chatID!),
      'Hi, it seems that i can\'t access ${repo.user}/${repo.repo}, '
      'so I removed it',
    );
  }

  void onSocketMessage(dynamic data) async {
    try {
      if (data[0] == 'sendMessage') {
        await onSendMessageEvent(data[1], data[2]);
      } else if (data[0] == 'notFound') {
        var repo = DBRepo.fromJson(data[1]);
        await onRepoNotFoundEvent(repo);
      }
    } on Exception catch (e, s) {
      _log.severe('Error onSocketMessage', e, s);
    }
  }

  void startEventsIsolate() {
    var receivePort = ReceivePort();
    Isolate.spawn(
      eventsIsolateLoop,
      receivePort.sendPort,
      errorsAreFatal: false,
    );
    receivePort.listen(onSocketMessage);
  }

  Future registerRepo(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.length < 2) {
      return _kyaru.reply(
        update,
        'This command needs two parameters, '
        'a Github username and a repository name',
      );
    }

    var username = args[0];
    var repo = args[1];
    var dbRepo = DBRepo(update.message!.chat.id, username, repo);

    try {
      await _githubClient.events(username, repo);
    } on GithubNotFoundException {
      return _kyaru.reply(update, 'Repository or user not found');
    } on GithubNotChangedException {
      return _kyaru.reply(
        update,
        'There are no new events for this repository',
      );
    }

    _kyaru.brain.db.addRepo(dbRepo);
    return _kyaru.reply(
      update,
      'From now on i\'ll send updates on '
      'new events for this repository in this chat',
    );
  }

  Future removeRepo(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.length < 2) {
      return _kyaru.reply(
        update,
        'This command needs two parameters, '
        'a Github username and a repository name',
      );
    }

    var username = args[0];
    var repo = args[1];

    var dbRepo = DBRepo(update.message!.chat.id, username, repo);

    if (!_kyaru.brain.db.removeRepo(dbRepo)) {
      return _kyaru.reply(update, 'There is no repository with that name');
    }

    return _kyaru.reply(update, 'Repository $username/$repo removed');
  }

  Future listRepo(Update update, _) async {
    var repoList = _kyaru.brain.db
        .getRepos()
        .where((repo) => repo.chatID == update.message!.chat.id)
        .map((repo) => '- ${repo.user}/${repo.repo}')
        .toList();

    if (repoList.isEmpty) {
      return _kyaru.reply(update, 'There are no repositories in this chat');
    }

    return _kyaru.reply(
      update,
      'Repositories in this chat:\n'
      '${repoList.join('\n')}',
    );
  }
}
