class ConsoleLog {

  LogLevel logLevel;
  String log;
  ConsoleLog(this.logLevel, this.log);

  @override
  String toString() {
    return 'ConsoleLog{logLevel: $logLevel, log: $log}';
  }
}

enum LogLevel {
  VERBOSE, INFO, ERROR
}