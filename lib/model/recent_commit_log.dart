import 'package:repo_batch/model/repo.dart';

class CommitLog {

  Repo repo;
  List<String> logList;

  CommitLog(this.repo, this.logList);

  @override
  String toString() {
    return 'CommitLog{repo: $repo, logList: $logList}';
  }
}

class CommitLogLine {
  Repo? repo;

  String commitCode;
  String log;
  bool isHeader = false;

  CommitLogLine(this.repo, this.log, this.isHeader, this.commitCode);

  @override
  String toString() {
    return 'CommitLogLine{repo: $repo, log: $log, commitCode: $commitCode, isHeader: $isHeader}';
  }
}