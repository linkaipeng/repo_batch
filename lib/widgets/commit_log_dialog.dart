import 'package:flutter/material.dart';
import 'package:repo_batch/model/recent_commit_log.dart';

class CommitLogDialog extends StatelessWidget {
  final List<CommitLog> recentCommitLogList;
  final List<CommitLogLine> _lineList = [];

  CommitLogDialog({Key? key, required this.recentCommitLogList}) : super(key: key);

  void _initLogLines() {
    _lineList.clear();
    for (var commitLog in recentCommitLogList) {
      _lineList.add(CommitLogLine(commitLog.repo, '', true, ''));
      for (var line in commitLog.logList) {
        List<String> contents = line.split(' ');
        if (contents.isEmpty || contents.first.length <= 8) {
          _lineList.add(CommitLogLine(null, line, false, ''));
        } else {
          String result = '';
          for (int i = 1; i< contents.length; i++) {
            result += contents[i];
          }
          _lineList.add(CommitLogLine(null, result, false, contents.first.substring(0, 8)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initLogLines();
    return Dialog(
      child: Container(
        width: 700,
        height: 800,
        color: const Color(0XFF2B2B2B),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 70),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 25),
                itemCount: _lineList.length,
                itemBuilder: (context, index) {
                  CommitLogLine line = _lineList[index];
                  return line.isHeader ? _buildHeaderWidget(line) : _buildLogLineWidget(line);
                },
              ),
            ),
            _buildTitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 20, left: 20),
        child: const Text(
          '🧰 最近提交日志',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWidget(CommitLogLine line) {
    return Container(
      margin: const EdgeInsets.only(top: 25, bottom: 10, left: 20, right: 20),
      child: Text(
        line.repo?.name ?? 'Log',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLogLineWidget(CommitLogLine line) {
    return Container(
      margin: const EdgeInsets.only(top: 3, bottom: 3, left: 30, right: 20),
      child: RichText(
        text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: line.commitCode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const TextSpan(
                text: '  ',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: line.log,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ]
        ),
      ),
    );
  }
}
