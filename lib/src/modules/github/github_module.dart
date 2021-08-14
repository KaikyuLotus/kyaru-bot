import 'dart:async';

import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:logging/logging.dart';

import '../../../kyaru.dart';
import 'entities/db/db_repo.dart';
import 'entities/github_client.dart';
import 'entities/exceptions/github_not_found_exception.dart';
import 'entities/exceptions/github_not_changed_exception.dart';
import 'entities/exceptions/github_forbidden_exception.dart';
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

class GithubModule implements IModule {
  final _log = Logger('GithubModule');
  final Kyaru _kyaru;
  late GithubClient _githubClient;

  final etagStore = <String, String?>{};
  final readUpdates = <String, List<String>>{};
  int? rateLimitSeconds;

  late List<ModuleFunction> _moduleFunctions;

  GithubModule(this._kyaru) {
    _githubClient = GithubClient(_kyaru.brain.db.settings.githubToken);
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
        'List GitHub repositories saved for this chat',
        'gitlist',
        core: true,
      ),
    ];

    startWatcher();
  }

  @override
  List<ModuleFunction> get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

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
    var chatId = update.message!.chat.id;

    var isPresent = _kyaru.brain.db.getRepos().any((r) {
      return r.chatID == chatId &&
          r.user?.toLowerCase() == username.toLowerCase() &&
          r.repo?.toLowerCase() == repo.toLowerCase();
    });

    if (isPresent) {
      return _kyaru.reply(update, 'Repository already added');
    }

    var dbRepo = DBRepo(chatId, username, repo);

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

    etagStore.remove(repo.toString());
    readUpdates.remove(repo.toString());
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
      'Repositories in this chat:\n${repoList.join('\n')}',
    );
  }

  Future<void> startWatcher() async {
    _log.finer('First repository check');
    reposChecker(null);
    _log.info('Starting GitHub watcher');
    Timer.periodic(const Duration(minutes: 2), reposChecker);
  }

  Future<void> reposChecker(Timer? timer) async {
    _log.finer('Checking repos...');
    if (rateLimitSeconds != null) {
      _log.severe('Found API rate limit, waiting $rateLimitSeconds seconds');
      await Future.delayed(Duration(seconds: rateLimitSeconds!));
      rateLimitSeconds = null;
    }
    _kyaru.brain.db.getRepos().forEach(analyzeRepo);
  }

  Future analyzeRepo(DBRepo repo) async {
    _log.finer('Analyzing ${repo.repo}');
    try {
      var response = await _githubClient.events(
        repo.user,
        repo.repo,
        etag: etagStore[repo.toString()],
      );
      await elaborateResponse(repo, response);
      _log.finer('Left rate limit: ${response.rateLimitRemaining}');
    } on GithubNotFoundException {
      _log.info('Repository or user not found');
      _kyaru.brain.db.removeRepo(repo);
      return _kyaru.brain.bot.sendMessage(
        ChatID(repo.chatID!),
        'Hi, it seems that i can\'t access ${repo.user}/${repo.repo}, '
        'so I removed it',
      );
    } on GithubNotChangedException catch (e) {
      _log.finer(
          'Nothing changed in repo ${repo.repo}, left limit: ${e.rateLimitRemaining}');
    } on GithubForbiddenException catch (e) {
      var resetDateTime = DateTime.fromMillisecondsSinceEpoch(
        e.rateLimitReset! * 1000,
      );
      var seconds = resetDateTime.difference(DateTime.now()).inSeconds;
      _log.fine(
        'Stopping updates until ${resetDateTime.toIso8601String()}'
        ' ($seconds seconds)',
      );
      rateLimitSeconds = seconds;
    } on Exception catch (e, s) {
      _log.severe('Unknown exception in analyzeRepo:', e, s);
    }
  }

  Future elaborateResponse(
    DBRepo repo,
    GithubEventsResponse githubEventsResp,
  ) async {
    var events = githubEventsResp.events!.where(
      (e) {
        if (readUpdates.containsKey(repo.toString())) {
          return !readUpdates[repo.toString()]!.contains(e.id);
        }
        return true;
      },
    );

    if (events.isEmpty) return;

    _log.finer('Elaborating events for ${repo.repo}...');

    if (etagStore[repo.toString()] != null) {
      var message = '';
      if (events.length == 1) {
        message = 'New event for repository ${repo.user}/${repo.repo}:'
            '\n${events.first}';
      } else {
        var eventsString = events.map((e) => e.toString()).join('\n- ');
        message = 'New events for repository ${repo.user}/${repo.repo}:'
            '\n- $eventsString';
      }
      _kyaru.brain.bot.sendMessage(ChatID(repo.chatID), message);
    }

    etagStore[repo.toString()] = githubEventsResp.etag;
    readUpdates[repo.toString()] == null
        ? readUpdates[repo.toString()] =
            List<String>.from(events.map((e) => e.id))
        : readUpdates[repo.toString()]!
            .addAll(List<String>.from(events.map((e) => e.id)));
    _log.finer('Elaborating events for ${repo.repo} done');
  }
}
