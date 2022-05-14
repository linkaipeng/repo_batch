part of 'console_cubit.dart';

class ConsoleState {

  List<ConsoleLog> logList = [];
  bool isMinimize = false;

  ConsoleState init() {
    return ConsoleState()
      ..isMinimize = false
      ..logList = [];
  }

  ConsoleState clone() {
    return ConsoleState()
      ..isMinimize = isMinimize
      ..logList = logList;
  }
}
