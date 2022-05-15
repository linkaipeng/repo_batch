import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:git/git.dart';
import 'package:repo_batch/model/console_log.dart';
import 'package:repo_batch/model/recent_commit_log.dart';
import 'package:repo_batch/model/repo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/utils/process_result_extension.dart';

class GitRepository {

  static Function(ConsoleLog)? logCallback;

  Future<String> get _rootPath async => (await getApplicationDocumentsDirectory()).path + '/RepoBatch';
  Future<String> get _repoUrlFilePath async => (await _rootPath) + '/repos.txt';

  Future<Directory> getRootDirectory() async {
    Directory directory = const LocalFileSystem().directory(await _rootPath);
    if (!await directory.exists()) {
      await directory.create();
    }
    return directory;
  }

  Future<void> checkRepoValidAndUpdate({
    required List<Repo> repoList,
    required List<String> selectedList,
    required Function updateCallback,
  }) async {
    List<Repo> selectedRepoList = repoList.where((repo) => selectedList.contains(repo.url)).toList();
    if (selectedRepoList.isEmpty) {
      logCallback?.call(ConsoleLog(LogLevel.ERROR, 'selectedRepoList is empty.'));
      return;
    }
    await cloneAllRepo(
      repoList: selectedRepoList,
      fetchTagInfo: false,
      selectedList: selectedList,
      updateCallback: updateCallback,
    );
  }

  Future<void> cloneAllRepo({
    required List<Repo> repoList,
    required bool fetchTagInfo,
    required List<String> selectedList,
    required Function updateCallback,
  }) async {
    Directory repoRootDir = await getRootDirectory();
    for (var repo in repoList) {
      if (repo.url == null) {
        continue;
      }
      if (!selectedList.contains(repo.url)) {
        continue;
      }
      logCallback?.call(ConsoleLog(LogLevel.VERBOSE, 'git clone ${repo.url}'));
      logCallback?.call(ConsoleLog(LogLevel.INFO, 'cloning...'));
      ProcessResult result = await runGit(
        ['clone', repo.url!],
        processWorkingDir: repoRootDir.absolute.path,
        throwOnError: false,
      );
      print('clone $repo done. exitCode = ${result.exitCode}');
      if (result.exitCode == 0) {
        logCallback?.call(ConsoleLog(LogLevel.INFO, 'clone succeed.'));
      } else if (result.exitCode == 128) {
        logCallback?.call(ConsoleLog(LogLevel.ERROR, result.errText));
      } else {
        logCallback?.call(ConsoleLog(LogLevel.ERROR, 'clone error, error code = ${result.exitCode},${result.errText}'));
      }
      updateCallback();
    }
    await _fetchGitRepoDetailInfo(
      repoList: repoList,
      fetchTagInfo: fetchTagInfo,
      updateCallback: updateCallback,
      selectedList: selectedList,
    );
  }

  Future<void> _fetchGitRepoDetailInfo({
    required List<Repo> repoList,
    required bool fetchTagInfo,
    required Function updateCallback,
    List<String>? selectedList,
  }) async {
    Directory repoDir = await getRootDirectory();
    List<FileSystemEntity> fileList = repoDir.listSync(recursive: false);
    for (var file in fileList) {
      if (!await GitDir.isGitDir(file.absolute.path)) {
        logCallback?.call(ConsoleLog(LogLevel.ERROR, '${file.path} 不是 git 仓库'));
        continue;
      }
      GitDir gitDir = await GitDir.fromExisting(file.absolute.path);
      String remote = await _getRemoteName(gitDir);
      String remoteUrl = await _getRemoteUrl(gitDir, remote);
      if (selectedList != null && !selectedList.contains(remoteUrl)) {
        continue;
      }
      print('_fetchGitRepoDetailInfo remote = $remote, url = $remoteUrl');

      // 连接仓库和文件夹的关系
      Repo? repo = await _updateRepoDirInfo(gitDir, remote, repoList, file);
      if (repo == null) {
        logCallback?.call(ConsoleLog(LogLevel.ERROR, '${file.path} 无效'));
        continue;
      }
      // 更新 branch
      await _updateBranchInfo(gitDir, repo, remote);
      // 更新 tag
      if (fetchTagInfo) {
        await _updateTagInfo(gitDir, repo, remote);
      }
      updateCallback();
    }
  }

  Future<Repo?> _updateRepoDirInfo(GitDir gitDir, String remote, List<Repo> repoList, FileSystemEntity file) async {
    ProcessResult? finalResult = await _runCommands(gitDir, [
      ['fetch', remote],
      ['remote', 'get-url', remote],
    ]);
    if (finalResult != null && finalResult.exitCode == 0) {
      String url = finalResult.outText;
      print('url = $url');
      Repo? repo = repoList.firstWhereOrNull((repo) => repo.url == url);
      repo?.dirPath = gitDir.path;
      repo?.name = file.basename;
      return repo;
    }
    return null;
  }

  Future<void> _updateBranchInfo(GitDir gitDir, Repo repo, String remote) async {
    String currentBranch = (await _runCommand(gitDir, ['branch', '--show-current'])).outText;
    print('currentBranch = $currentBranch');
    repo.currentBranch = currentBranch;
    repo.branchList.clear();
    ProcessResult branchListResult = await _runCommand(gitDir, ['branch', '--all']);
    for (var branchName in branchListResult.outLines) {
      // print('branchName = $branchName');
      if (branchName.contains('/HEAD') || branchName.contains('*') || !branchName.contains('/$remote/')) {
        continue;
      }
      repo.branchList.add(branchName.split('/').last);
    }
  }

  Future<void> _updateTagInfo(GitDir gitDir, Repo repo, String remote) async {
    if (repo.dirPath == null) {
      logCallback?.call(ConsoleLog(LogLevel.ERROR, '${repo.url} local dir not exist.'));
      return;
    }
    var gitCommandList = [
      ['fetch', remote, '--prune'],
      ['tag', '-l'],
    ];
    ProcessResult? finalResult = await _runCommands(gitDir, gitCommandList);
    if (finalResult?.exitCode == 0) {
      repo.tagList.clear();
      for (var tag in finalResult!.outLines) {
        repo.tagList.add(tag);
      }
    }
  }

  Future<void> checkoutReposBranch({
    required List<Repo> repoList,
    required List<String> selectedList,
    required String branchName,
  }) async {
    for (var repo in repoList) {
      if (!selectedList.contains(repo.url)) {
        continue;
      }
      await checkoutBranch(repo, branchName, repoList);
    }
  }

  Future<void> checkoutBranch(Repo repo, String branchName, List<Repo> repoList) async {
    if (repo.dirPath == null) {
      logCallback?.call(ConsoleLog(LogLevel.ERROR, '${repo.url} local dir not exist.'));
      return;
    }
    if (repo.url == null) {
      logCallback?.call(ConsoleLog(LogLevel.ERROR, '${repo.name} url is null'));
      return;
    }
    if (!repo.branchList.contains(branchName)) {
      logCallback?.call(ConsoleLog(LogLevel.ERROR, '${repo.name} can not find $branchName'));
      return;
    }
    if (repo.dirPath == null || !await GitDir.isGitDir(repo.dirPath!)) {
      return;
    }
    GitDir gitDir = await GitDir.fromExisting(repo.dirPath!);
    await _runCommand(gitDir, ['checkout', branchName]);
    await _updateBranchInfo(gitDir, repo, await _getRemoteName(gitDir));
  }

  Future<String> _getRemoteName(GitDir gitDir) async {
    return (await _runCommand(gitDir, ['remote'])).outText;
  }

  Future<String> _getRemoteUrl(GitDir gitDir, String remote) async {
    return (await _runCommand(gitDir, ['remote', 'get-url', remote])).outText;
  }

  Future<void> pushReposTag(List<Repo> repoList, List<String> selectedList, String tagName, String tagCommitInfo) async {
    for (Repo repo in repoList) {
      if (!selectedList.contains(repo.url)) {
        continue;
      }
      await _pushTag(repo, tagName, tagCommitInfo);
    }
  }

  Future<void> _pushTag(Repo repo, String tagName, String tagCommitInfo) async {
    // git tag -l | xargs git tag -d
    // git fetch origin --prune
    // git fetch origin release
    // git checkout release
    // git pull
    // git tag -a "$1" -m "$1"
    // git push origin "$1"
    // git tag

    if (repo.dirPath == null) {
      logCallback?.call(ConsoleLog(LogLevel.ERROR, '${repo.url} local dir not exist.'));
      return;
    }

    GitDir gitDir = await GitDir.fromExisting(repo.dirPath!);

    String remote = await _getRemoteName(gitDir);
    String? currentBranch = repo.currentBranch;
    print('pushTag tagName = $tagName, current tagCommitInfo = $tagCommitInfo');
    print('pushTag remote = $remote, current branch = $currentBranch');
    if (currentBranch == null) {
      return;
    }

    // 移除掉已有的 tag
    ProcessResult? existTagsResult = await _runCommand(gitDir, ['tag', '-l']);
    for (var tagName in existTagsResult.outLines) {
      await _runCommand(gitDir, ['tag', '-d', tagName]);
    }
    var gitCommandList = [
      ['fetch', remote, '--prune'],
      ['fetch', remote, currentBranch],
      ['checkout', currentBranch],
      ['pull'],
      ['tag', '-a', tagName, '-m', tagCommitInfo],
      ['push', remote, tagName],
      ['tag', '-l'],
    ];
    ProcessResult? finalResult = await _runCommands(gitDir, gitCommandList);
    if (finalResult?.exitCode == 0) {
      repo.tagList.clear();
      for (var tag in finalResult!.outLines) {
        repo.tagList.add(tag);
      }
    }
  }

  Future<List<CommitLog>> fetchReposRecentLog(List<Repo> repoList, List<String> selectedList) async {
    List<CommitLog> recentCommitLogList = [];
    for (Repo repo in repoList) {
      if (!selectedList.contains(repo.url)) {
        continue;
      }
      await _fetchRecentLog(repo, recentCommitLogList);
    }
    return recentCommitLogList;
  }

  Future<void> _fetchRecentLog(Repo repo, List<CommitLog> recentCommitLogList) async {
    // git fetch origin release
    // git checkout release
    // git pull
    // git log --pretty=oneline --max-count=10
    if (repo.dirPath == null) {
      logCallback?.call(ConsoleLog(LogLevel.ERROR, '${repo.url} local dir not exist.'));
      return;
    }
    if (!await GitDir.isGitDir(repo.dirPath!)) {
      return;
    }
    GitDir gitDir = await GitDir.fromExisting(repo.dirPath!);
    String remote = await _getRemoteName(gitDir);
    String? currentBranch = repo.currentBranch;
    if (currentBranch == null) {
      return;
    }
    var gitCommandList = [
      ['fetch', remote, currentBranch],
      ['pull'],
      ['log', '--pretty=oneline', '--max-count=10'],
    ];
    ProcessResult? finalResult = await _runCommands(gitDir, gitCommandList);
    if (finalResult?.exitCode == 0) {
      recentCommitLogList.add(CommitLog(repo, finalResult!.outLines.toList()));
    }
  }

  Future<ProcessResult?> _runCommands(GitDir gitDir, Iterable<Iterable<String>> gitCommandList) async {
    ProcessResult? finalResult;
    for(Iterable<String> args in gitCommandList) {
      logCallback?.call(ConsoleLog(LogLevel.VERBOSE, '${gitDir.path}, git ${args.join(' ')}'));
      ProcessResult result = await gitDir.runCommand(args, throwOnError: false);
      print('$args, exitCode = ${result.exitCode}');
      if (result.exitCode != 0) {
        logCallback?.call(ConsoleLog(LogLevel.ERROR, 'git ${args.join(' ')} failed. result: error code = ${result.exitCode}, ${result.errText}\n'));
        return result;
      }
      logCallback?.call(ConsoleLog(LogLevel.INFO, 'git ${args.join(' ')} succeed. result: \n${result.outText}\n'));
      finalResult = result;
    }
    return finalResult;
  }

  Future<ProcessResult> _runCommand(GitDir gitDir, Iterable<String> gitCommandArgs) async {
    logCallback?.call(ConsoleLog(LogLevel.VERBOSE, '${gitDir.path}, git ${gitCommandArgs.join(' ')}'));
    ProcessResult result = await gitDir.runCommand(gitCommandArgs, throwOnError: false);
    print('$gitCommandArgs, exitCode = ${result.exitCode}');
    if (result.exitCode != 0) {
      logCallback?.call(ConsoleLog(LogLevel.ERROR, 'git ${gitCommandArgs.join(' ')} failed. result: error code = ${result.exitCode}, ${result.errText}\n'));
      return result;
    }
    logCallback?.call(ConsoleLog(LogLevel.INFO, 'git ${gitCommandArgs.join(' ')} succeed. result: \n${result.outText}\n'));
    return result;
  }

  Future<void> writeRepoListToFile(String contents) async {
    await getRootDirectory();
    String repoUrlFilePath = await _repoUrlFilePath;
    var file = const LocalFileSystem().file(repoUrlFilePath);
    if (await file.exists()) {
      await file.delete();
    }
    String result = '';
    for (var value in contents.split('\n')) {
      if (!_verifyInputUrl(value)) {
        continue;
      }
      result += (value.trim() + '\n');
    }
    await file.writeAsString(result);
  }

  Future<List<String>> readRepoListFromFile() async {
    await getRootDirectory();
    List<String> repoUrlList = [];
    String repoUrlFilePath = await _repoUrlFilePath;
    var file = const LocalFileSystem().file(repoUrlFilePath);
    if (!await file.exists()) {
      return repoUrlList;
    }
    List<String> lines = await file.readAsLines();
    for (var line in lines) {
      if (line.trim().isNotEmpty && _verifyInputUrl(line)) {
        repoUrlList.add(line.trim());
      }
    }
    return repoUrlList;
  }

  bool _verifyInputUrl(String line) {
    return line.startsWith('https://') || line.startsWith('git@');
  }
}