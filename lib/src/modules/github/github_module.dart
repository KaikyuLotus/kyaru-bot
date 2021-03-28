import 'dart:async';
import 'dart:isolate';

import 'package:dart_telegram_bot/telegram_entities.dart';

import '../../../kyaru.dart';
import 'entities/db/db_repo.dart';
import 'entities/exceptions/github_forbidden_exception.dart';
import 'entities/exceptions/github_not_changed_exception.dart';
import 'entities/exceptions/github_not_found_exception.dart';
import 'entities/github_client.dart';
import 'entities/github_events_response.dart';

void eventsIsolateLoop(SendPort sendPort) {
  // TODO maybe it would be better to use async and await?
  var db = KyaruDB();
  final githubClient = GithubClient();
  final etagStore = <String?, String?>{};
  final readUpdates = <String>[];

  void elaborateResponse(DBRepo repo, GithubEventsResponse githubEventsResp) {
    print('Elaborating events for ${repo.repo}...');
    var events =
        githubEventsResp.events!.where((e) => !readUpdates.contains(e.id));

    if (events.isEmpty) {
      return;
    }
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
    print('Elaborating events for ${repo.repo} done');
  }

  void timerFunction(t) {
    print('Checking github updates...');
    db.syncDb();
    for (var repo in db.getRepos()) {
      githubClient
          .events(repo.user, repo.repo, etag: etagStore[repo.repo])
          .then((response) {
        elaborateResponse(repo, response);
        print('Left rate limit: ${response.rateLimitRemaining}');
      }).catchError(
        (e) {
          print('Repository or user not found');
          sendPort.send(['notFound', repo.toJson()]);
        },
        test: (e) => e.runtimeType == GithubNotFoundException,
      ).catchError(
        (e) {
          print(
            'Nothing changed in the repo, left limit: ${e.rateLimitRemaining}',
          );
        },
        test: (e) => e.runtimeType == GithubNotChangedException,
      ).catchError(
        (e, s) {
          print('Critical error $e\n$s');
        },
        test: (e) => e.runtimeType != GithubForbiddenException,
      );
    }
  }

  Function()? loopBootstrapperFoo;
  loopBootstrapperFoo = () {
    var repoFutures = db
        .getRepos()
        .map((repo) => githubClient
                .events(repo.user, repo.repo, etag: etagStore[repo.repo])
                .then((r) {
              etagStore[repo.repo] = r.etag;
              readUpdates.addAll(List<String>.from(r.events!.map((e) => e.id)));
            }))
        .toList();

    Future.wait(repoFutures)
        .then((nothing) => {
              timerFunction(null),
              Timer.periodic(Duration(minutes: 2), timerFunction)
            })
        .catchError(
      (e) {
        var resetDateTime = DateTime.fromMillisecondsSinceEpoch(
          e.rateLimitReset * 1000,
        );
        var seconds = resetDateTime.difference(DateTime.now()).inSeconds;
        print(
          'Stopping updates until ${resetDateTime.toIso8601String()} ($seconds seconds)',
        );
        Future.delayed(Duration(seconds: seconds), loopBootstrapperFoo);
      },
      test: (e) => e.runtimeType == GithubForbiddenException,
    );
  };

  loopBootstrapperFoo();
}

class GithubModule implements IModule {
  final Kyaru _kyaru;
  final _githubClient = GithubClient();

  List<ModuleFunction>? _moduleFunctions;

  GithubModule(this._kyaru) {
    print('Github module started at ${DateTime.now().toIso8601String()}');
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
      )
    ];

    startEventsIsolate();
  }

  @override
  List<ModuleFunction>? get moduleFunctions => _moduleFunctions;

  @override
  bool isEnabled() => true;

  void startEventsIsolate() {
    var receivePort = ReceivePort();
    Isolate.spawn(eventsIsolateLoop, receivePort.sendPort);
    receivePort.listen((data) {
      if (data[0] == 'sendMessage') {
        int chatId = data[1];
        String message = data[2];
        _kyaru.brain.bot
            .sendMessage(ChatID(chatId), message)
            .catchError((e, s) {
          print('$e\n$s');
        });
      } else if (data[0] == 'notFound') {
        var repo = DBRepo.fromJson(data[1]);
        _kyaru.brain.db.removeRepo(repo);
        _kyaru.brain.bot
            .sendMessage(
                ChatID(repo.chatID!),
                'Hi, it seems that i can\'t access ${repo.user}/${repo.repo}, '
                'so I removed it')
            .catchError((e, s) {
          print('$e\n$s');
        });
        ;
      }
    });
  }

  Future registerRepo(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.length < 2) {
      return await _kyaru.reply(update,
          'This command needs two parameters, a Github username and a repository name');
    }

    var username = args[0];
    var repo = args[1];

    try {
      await _githubClient.events(username, repo);
      _kyaru.brain.db.addRepo(DBRepo(update.message!.chat.id, username, repo));
      await _kyaru.reply(update,
          'From now on i\'ll send updates on new events for this repository in this chat');
    } on GithubNotFoundException {
      await _kyaru.reply(update, 'Repository or user not found');
    } on GithubNotChangedException {
      await _kyaru.reply(update, 'There are no new events for this repository');
    } on Exception catch (e, s) {
      print('Could not get repo events: $e\n$s');
      await _kyaru.reply(update, 'Something went terribly wrong...');
    }
  }

  Future removeRepo(Update update, _) async {
    var args = update.message!.text!.split(' ')..removeAt(0);

    if (args.length < 2) {
      return await _kyaru.reply(
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

    await _kyaru.reply(update, 'Repository $username/$repo removed');
  }
}
