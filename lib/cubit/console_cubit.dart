import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repo_batch/model/console_log.dart';

part 'console_state.dart';

class ConsoleCubit extends Cubit<ConsoleState> {
  ConsoleCubit() : super(ConsoleState().init());

  void appendLog(ConsoleLog consoleLog) {
    List<ConsoleLog> newList = List.of(state.logList);
    newList.add(consoleLog);
    emit(state.clone()..logList = newList);
  }

  void toggleConsole() {
    emit(state.clone()..isMinimize = !state.isMinimize);
  }

  static ConsoleCubit getConsoleCubit(BuildContext context) {
    return BlocProvider.of<ConsoleCubit>(context);
  }
}
